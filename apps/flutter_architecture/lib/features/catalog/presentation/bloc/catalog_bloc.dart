import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_item.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_load_policy.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page_snapshot.dart';
import 'package:flutter_architecture/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'catalog_bloc.freezed.dart';
part 'catalog_event.dart';
part 'catalog_state.dart';

/// Catalog 搜尋與分頁流程的狀態管理。
///
/// 負責initial search、debounce、query switching、stale response guard、Refresh、
/// Append與reconnect後的資料重新驗證流程。
class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc(
    this._repository, {
    this.debounceDuration = const Duration(milliseconds: 300),
    this.pageSize = 20,
  }) : super(CatalogState.initial()) {
    if (pageSize <= 0) {
      throw ArgumentError.value(pageSize, 'pageSize', 'must be greater than 0');
    }

    on<CatalogInitialRequested>(_onInitialRequested);
    on<CatalogQueryChanged>(
      _onQueryChanged,
      transformer: _debounceDistinctQuery(debounceDuration),
    );
    on<CatalogLoadMoreRequested>(
      _onLoadMoreRequested,
      transformer: _exhaustEvents(),
    );
    on<CatalogRefreshRequested>(
      _onRefreshRequested,
      transformer: _exhaustEvents(),
    );
    on<CatalogReconnectObserved>(
      _onReconnectObserved,
      transformer: _exhaustEvents(),
    );
  }

  final CatalogRepository _repository;

  /// 預設 300ms，可於測試注入較短 duration。
  final Duration debounceDuration;

  /// Initial search 每頁筆數；後續 Append 共用。
  final int pageSize;

  int _searchGeneration = 0;
  StreamSubscription<Result<CatalogPageSnapshot>>? _firstPageSubscription;
  Completer<void>? _firstPageCompleter;
  _SingleSnapshotRequest? _refreshRequest;
  _SingleSnapshotRequest? _appendRequest;
  _SingleSnapshotRequest? _reconnectRequest;
  final Set<String> _consumedAppendCursors = <String>{};

  Future<void> _onInitialRequested(
    CatalogInitialRequested event,
    Emitter<CatalogState> emit,
  ) {
    return _startInitialSearch(query: state.query, emit: emit);
  }

  Future<void> _onQueryChanged(
    CatalogQueryChanged event,
    Emitter<CatalogState> emit,
  ) async {
    final normalizedQuery = event.query.trim();

    if (normalizedQuery == state.query) {
      return;
    }

    await _startInitialSearch(query: normalizedQuery, emit: emit);
  }

  Future<void> _startInitialSearch({
    required String query,
    required Emitter<CatalogState> emit,
  }) async {
    await _cancelFirstPageSearch();
    await _cancelTransientOperations();
    _consumedAppendCursors.clear();
    // searchGeneration 是 query/search lifecycle identity；所有 async completion
    // 都只能 commit 到建立它的 generation，避免舊搜尋污染新 query state。
    final generation = ++_searchGeneration;

    emit(
      state.copyWith(
        query: query,
        items: const <CatalogItem>[],
        nextCursor: null,
        isInitialLoading: true,
        isRefreshing: false,
        isLoadingMore: false,
        hasCompletedInitialLoad: false,
        isUsingCachedData: false,
        isStale: false,
        lastUpdatedAt: null,
        isRevalidating: false,
        isReconnectRevalidating: false,
        initialFailure: null,
        revalidationFailure: null,
        reconnectFailure: null,
        refreshFailure: null,
        appendFailure: null,
      ),
    );

    var hasDisplayableSnapshot = false;
    var isAwaitingRevalidation = false;
    final completer = Completer<void>();
    _firstPageCompleter = completer;

    final subscription = _repository
        .watchCatalog(
          query: query,
          cursor: null,
          limit: pageSize,
          policy: CatalogLoadPolicy.initial,
        )
        .listen(
          (result) {
            if (generation != _searchGeneration || query != state.query) {
              return;
            }
            result.when(
              success: (snapshot) {
                hasDisplayableSnapshot = true;
                final isCache = snapshot.source == CatalogDataSource.cache;
                final isStale = snapshot.freshness == CatalogFreshness.stale;
                isAwaitingRevalidation = isCache && isStale;
                emit(
                  state.copyWith(
                    items: snapshot.page.items,
                    nextCursor: snapshot.page.nextCursor,
                    isInitialLoading: false,
                    hasCompletedInitialLoad: true,
                    isUsingCachedData: isCache,
                    isStale: isStale,
                    lastUpdatedAt: snapshot.lastUpdatedAt,
                    isRevalidating: isAwaitingRevalidation,
                    initialFailure: null,
                    revalidationFailure: null,
                  ),
                );
              },
              failure: (error) {
                if (hasDisplayableSnapshot) {
                  isAwaitingRevalidation = false;
                  emit(
                    state.copyWith(
                      isInitialLoading: false,
                      isRevalidating: false,
                      revalidationFailure: error,
                    ),
                  );
                  return;
                }
                emit(
                  state.copyWith(
                    items: const <CatalogItem>[],
                    nextCursor: null,
                    isInitialLoading: false,
                    hasCompletedInitialLoad: true,
                    isUsingCachedData: false,
                    isStale: false,
                    lastUpdatedAt: null,
                    isRevalidating: false,
                    initialFailure: error,
                    revalidationFailure: null,
                  ),
                );
              },
            );
          },
          onError: (Object error, StackTrace stackTrace) {
            if (generation == _searchGeneration && query == state.query) {
              emit(
                state.copyWith(
                  isInitialLoading: false,
                  isRevalidating: false,
                  hasCompletedInitialLoad: hasDisplayableSnapshot,
                ),
              );
            }
            if (!completer.isCompleted) {
              completer.completeError(error, stackTrace);
            }
          },
          onDone: () {
            if (isAwaitingRevalidation) {
              if (generation == _searchGeneration && query == state.query) {
                emit(state.copyWith(isRevalidating: false));
              }
              if (!completer.isCompleted) {
                completer.completeError(
                  StateError(
                    'Catalog initial SWR stream closed before revalidation result',
                  ),
                  StackTrace.current,
                );
              }
              return;
            }
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
          cancelOnError: true,
        );
    _firstPageSubscription = subscription;

    try {
      await completer.future;
    } finally {
      if (identical(_firstPageSubscription, subscription)) {
        _firstPageSubscription = null;
      }
      if (identical(_firstPageCompleter, completer)) {
        _firstPageCompleter = null;
      }
    }
  }

  Future<void> _onLoadMoreRequested(
    CatalogLoadMoreRequested event,
    Emitter<CatalogState> emit,
  ) async {
    final requestedCursor = state.nextCursor;
    if (state.isInitialLoading ||
        state.isRefreshing ||
        state.isReconnectRevalidating ||
        state.isLoadingMore ||
        state.items.isEmpty ||
        requestedCursor == null) {
      return;
    }

    final generation = _searchGeneration;
    final query = state.query;

    emit(state.copyWith(isLoadingMore: true, appendFailure: null));

    late final Result<CatalogPageSnapshot> result;
    final request = _SingleSnapshotRequest(
      _repository.watchCatalog(
        query: query,
        cursor: requestedCursor,
        limit: pageSize,
        policy: CatalogLoadPolicy.append,
      ),
    );
    _appendRequest = request;
    try {
      result = await request.load(operation: 'append');
    } catch (error, stackTrace) {
      if (request.isCancelled) {
        return;
      }
      if (generation == _searchGeneration &&
          query == state.query &&
          requestedCursor == state.nextCursor) {
        emit(state.copyWith(isLoadingMore: false));
      }
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      if (identical(_appendRequest, request)) {
        _appendRequest = null;
      }
    }

    if (generation != _searchGeneration ||
        query != state.query ||
        requestedCursor != state.nextCursor) {
      // Append completion 還必須擁有同一 cursor slot；同 generation 內 refresh
      // 也可能已換掉 nextCursor，因此不能只檢查 query/generation。
      return;
    }

    result.when(
      success: (snapshot) {
        final page = snapshot.page;
        final nextCursor = page.nextCursor;
        if (nextCursor != null &&
            (nextCursor == requestedCursor ||
                _consumedAppendCursors.contains(nextCursor))) {
          emit(
            state.copyWith(
              isLoadingMore: false,
              appendFailure: const Failure(
                kind: FailureKind.protocol,
                message: 'Catalog 分頁 cursor 形成循環',
                diagnosticCode: 'cyclic_catalog_cursor',
              ),
            ),
          );
          return;
        }
        _consumedAppendCursors.add(requestedCursor);
        emit(
          state.copyWith(
            items: _mergeItems(state.items, page.items),
            nextCursor: page.nextCursor,
            isLoadingMore: false,
            appendFailure: null,
          ),
        );
      },
      failure: (error) {
        emit(state.copyWith(isLoadingMore: false, appendFailure: error));
      },
    );
  }

  Future<void> _onRefreshRequested(
    CatalogRefreshRequested event,
    Emitter<CatalogState> emit,
  ) async {
    if (state.isRefreshing) {
      return;
    }

    await _cancelFirstPageSearch();
    await _cancelAppendRequest();
    await _cancelReconnectRequest();
    final generation = ++_searchGeneration;
    final query = state.query;

    emit(
      state.copyWith(
        isInitialLoading: false,
        isRefreshing: true,
        isLoadingMore: false,
        isRevalidating: false,
        isReconnectRevalidating: false,
        initialFailure: null,
        revalidationFailure: null,
        reconnectFailure: null,
        refreshFailure: null,
        appendFailure: null,
      ),
    );

    late final Result<CatalogPageSnapshot> result;
    final request = _SingleSnapshotRequest(
      _repository.watchCatalog(
        query: query,
        cursor: null,
        limit: pageSize,
        policy: CatalogLoadPolicy.refresh,
      ),
    );
    _refreshRequest = request;
    try {
      result = await request.load(operation: 'refresh');
    } catch (error, stackTrace) {
      if (request.isCancelled) {
        return;
      }
      if (generation == _searchGeneration && query == state.query) {
        emit(state.copyWith(isRefreshing: false));
      }
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      if (identical(_refreshRequest, request)) {
        _refreshRequest = null;
      }
    }

    if (generation != _searchGeneration || query != state.query) {
      return;
    }

    result.when(
      success: (snapshot) {
        final page = snapshot.page;
        _consumedAppendCursors.clear();
        emit(
          state.copyWith(
            items: page.items,
            nextCursor: page.nextCursor,
            isRefreshing: false,
            hasCompletedInitialLoad: true,
            isUsingCachedData: snapshot.source == CatalogDataSource.cache,
            isStale: snapshot.freshness == CatalogFreshness.stale,
            lastUpdatedAt: snapshot.lastUpdatedAt,
            isRevalidating: false,
            revalidationFailure: null,
            refreshFailure: null,
          ),
        );
      },
      failure: (error) {
        emit(state.copyWith(isRefreshing: false, refreshFailure: error));
      },
    );
  }

  Future<void> _onReconnectObserved(
    CatalogReconnectObserved event,
    Emitter<CatalogState> emit,
  ) async {
    if (!state.hasCompletedInitialLoad ||
        state.items.isEmpty ||
        state.isInitialLoading ||
        state.isRefreshing ||
        state.isLoadingMore ||
        state.isReconnectRevalidating) {
      return;
    }

    final generation = _searchGeneration;
    final query = state.query;
    emit(
      state.copyWith(
        isReconnectRevalidating: true,
        reconnectFailure: null,
      ),
    );

    late final Result<CatalogPageSnapshot> result;
    final request = _SingleSnapshotRequest(
      _repository.watchCatalog(
        query: query,
        cursor: null,
        limit: pageSize,
        policy: CatalogLoadPolicy.refresh,
      ),
    );
    _reconnectRequest = request;
    try {
      result = await request.load(operation: 'reconnect');
    } catch (error, stackTrace) {
      if (request.isCancelled) return;
      if (generation == _searchGeneration && query == state.query) {
        emit(state.copyWith(isReconnectRevalidating: false));
      }
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      if (identical(_reconnectRequest, request)) {
        _reconnectRequest = null;
      }
    }

    if (generation != _searchGeneration || query != state.query) return;

    result.when(
      success: (snapshot) {
        _consumedAppendCursors.clear();
        emit(
          state.copyWith(
            items: snapshot.page.items,
            nextCursor: snapshot.page.nextCursor,
            isReconnectRevalidating: false,
            isUsingCachedData:
                snapshot.source == CatalogDataSource.cache,
            isStale: snapshot.freshness == CatalogFreshness.stale,
            lastUpdatedAt: snapshot.lastUpdatedAt,
            reconnectFailure: null,
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            isReconnectRevalidating: false,
            reconnectFailure: error,
          ),
        );
      },
    );
  }

  Future<void> _cancelFirstPageSearch() async {
    final subscription = _firstPageSubscription;
    final completer = _firstPageCompleter;
    _firstPageSubscription = null;
    _firstPageCompleter = null;
    await subscription?.cancel();
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  Future<void> _cancelAppendRequest() async {
    final request = _appendRequest;
    _appendRequest = null;
    await request?.cancel();
  }

  Future<void> _cancelRefreshRequest() async {
    final request = _refreshRequest;
    _refreshRequest = null;
    await request?.cancel();
  }

  Future<void> _cancelReconnectRequest() async {
    final request = _reconnectRequest;
    _reconnectRequest = null;
    await request?.cancel();
  }

  Future<void> _cancelTransientOperations() async {
    await Future.wait<void>(<Future<void>>[
      _cancelAppendRequest(),
      _cancelRefreshRequest(),
      _cancelReconnectRequest(),
    ]);
  }

  @override
  Future<void> close() async {
    await _cancelFirstPageSearch();
    await _cancelTransientOperations();
    return super.close();
  }
}

class _SingleSnapshotRequest {
  _SingleSnapshotRequest(Stream<Result<CatalogPageSnapshot>> stream)
    : _iterator = StreamIterator<Result<CatalogPageSnapshot>>(stream);

  final StreamIterator<Result<CatalogPageSnapshot>> _iterator;
  bool isCancelled = false;

  Future<Result<CatalogPageSnapshot>> load({required String operation}) async {
    try {
      if (!await _iterator.moveNext()) {
        throw StateError(
          'Catalog $operation stream completed without a result',
        );
      }
      final result = _iterator.current;
      if (await _iterator.moveNext()) {
        throw StateError(
          'Catalog $operation stream emitted more than one result',
        );
      }
      return result;
    } finally {
      if (!isCancelled) {
        await _iterator.cancel();
      }
    }
  }

  Future<void> cancel() async {
    if (isCancelled) return;
    isCancelled = true;
    await _iterator.cancel();
  }
}

EventTransformer<CatalogQueryChanged> _debounceDistinctQuery(
  Duration duration,
) {
  return (events, mapper) {
    return events
        .debounceTime(duration)
        .distinct(
          (previous, next) => previous.query.trim() == next.query.trim(),
        )
        .switchMap(mapper);
  };
}

EventTransformer<Event> _exhaustEvents<Event>() {
  return (events, mapper) => events.exhaustMap(mapper);
}

List<CatalogItem> _mergeItems(
  List<CatalogItem> existingItems,
  List<CatalogItem> incomingItems,
) {
  final existingIds = existingItems.map((item) => item.id).toSet();
  return <CatalogItem>[
    ...existingItems,
    for (final item in incomingItems)
      if (existingIds.add(item.id)) item,
  ];
}
