import 'package:core/core.dart';
import 'package:flutter_architecture/features/catalog/data/cache/catalog_cache_policy.dart';
import 'package:flutter_architecture/features/catalog/data/cache/catalog_clock.dart';
import 'package:flutter_architecture/features/catalog/data/data_sources/catalog_local_data_source.dart';
import 'package:flutter_architecture/features/catalog/data/data_sources/catalog_remote_data_source.dart';
import 'package:flutter_architecture/features/catalog/data/mappers/catalog_cache_page_mapper.dart';
import 'package:flutter_architecture/features/catalog/data/mappers/catalog_page_response_dto_mapper.dart';
import 'package:flutter_architecture/features/catalog/data/models/catalog_cache_page_entity.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_load_policy.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page_snapshot.dart';
import 'package:flutter_architecture/features/catalog/domain/repositories/catalog_repository.dart';

/// CatalogRepository 的 Data Layer 實作。
class CatalogRepositoryImpl implements CatalogRepository {
  const CatalogRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._cachePolicy,
    this._clock,
  );

  final CatalogRemoteDataSource _remoteDataSource;
  final CatalogLocalDataSource _localDataSource;
  final CatalogCachePolicy _cachePolicy;
  final CatalogClock _clock;

  @override
  Stream<Result<CatalogPageSnapshot>> watchCatalog({
    required String query,
    required String? cursor,
    required int limit,
    required CatalogLoadPolicy policy,
  }) async* {
    _validateRequest(cursor: cursor, limit: limit, policy: policy);
    final normalizedQuery = query.trim();

    if (policy != CatalogLoadPolicy.refresh) {
      final cached = await _readCache(
        query: normalizedQuery,
        cursor: cursor,
        limit: limit,
      );
      if (cached != null) {
        final freshness = _freshness(cached.updatedAt);
        yield Success(
          CatalogPageSnapshot(
            page: cached.toDomain(),
            source: CatalogDataSource.cache,
            freshness: freshness,
            lastUpdatedAt: cached.updatedAt,
          ),
        );

        if (policy == CatalogLoadPolicy.append ||
            freshness == CatalogFreshness.fresh) {
          return;
        }
      }
    }

    final expectedChainRevision = policy == CatalogLoadPolicy.append
        ? await _readLinkedChainRevision(
            query: normalizedQuery,
            cursor: cursor!,
            limit: limit,
          )
        : null;

    yield await _loadRemote(
      query: normalizedQuery,
      cursor: cursor,
      limit: limit,
      expectedChainRevision: expectedChainRevision,
    );
  }

  Future<Result<CatalogPageSnapshot>> _loadRemote({
    required String query,
    required String? cursor,
    required int limit,
    required int? expectedChainRevision,
  }) async {
    try {
      final response = await _remoteDataSource.searchCatalog(
        query: query,
        cursor: cursor,
        limit: limit,
      );
      final page = response.toDomain();

      if (cursor != null &&
          cursor.trim().isNotEmpty &&
          page.nextCursor == cursor) {
        throw const AppException(
          message: 'Catalog pagination cursor 無法前進',
          code: 'non_advancing_catalog_cursor',
        );
      }

      final updatedAt = _nowUtc();
      try {
        final cachePage = page.toCacheEntity(
          query: query,
          requestCursor: cursor,
          requestLimit: limit,
          updatedAt: updatedAt,
          chainRevision: expectedChainRevision ?? 0,
        );
        if (cursor == null) {
          await _localDataSource.replacePage(
            cachePage,
            resetFollowingPages: true,
          );
        } else {
          await _localDataSource.replaceAppendPageIfLinked(
            cachePage,
            expectedChainRevision: expectedChainRevision,
          );
        }
      } on AppException {
        // Catalog Cache 是可重建 read model；寫入失敗不覆蓋 Remote success。
      }

      return Success(
        CatalogPageSnapshot(
          page: page,
          source: CatalogDataSource.remote,
          freshness: CatalogFreshness.fresh,
          lastUpdatedAt: updatedAt,
        ),
      );
    } on AppException catch (error) {
      return FailureResult(
        mapAppExceptionToFailure(error, fallbackMessage: '取得 Catalog 失敗'),
      );
    }
  }

  Future<int?> _readLinkedChainRevision({
    required String query,
    required String cursor,
    required int limit,
  }) async {
    try {
      return await _localDataSource.readLinkedChainRevision(
        query: query,
        cursor: cursor,
        limit: limit,
      );
    } on AppException {
      return null;
    }
  }

  Future<CatalogCachePageEntity?> _readCache({
    required String query,
    required String? cursor,
    required int limit,
  }) async {
    try {
      return await _localDataSource.readPage(
        query: query,
        cursor: cursor,
        limit: limit,
        now: _nowUtc(),
        retainFor: _cachePolicy.retainFor,
      );
    } on AppException {
      return null;
    }
  }

  CatalogFreshness _freshness(DateTime updatedAt) {
    final age = _nowUtc().difference(updatedAt.toUtc());
    if (age.isNegative) {
      return CatalogFreshness.stale;
    }
    return age <= _cachePolicy.freshFor
        ? CatalogFreshness.fresh
        : CatalogFreshness.stale;
  }

  DateTime _nowUtc() => _clock.nowUtc();

  void _validateRequest({
    required String? cursor,
    required int limit,
    required CatalogLoadPolicy policy,
  }) {
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', 'must be greater than 0');
    }

    final valid = switch (policy) {
      CatalogLoadPolicy.initial || CatalogLoadPolicy.refresh => cursor == null,
      CatalogLoadPolicy.append => cursor != null && cursor.trim().isNotEmpty,
    };
    if (!valid) {
      throw ArgumentError('CatalogLoadPolicy 與 cursor 組合不合法');
    }
  }
}
