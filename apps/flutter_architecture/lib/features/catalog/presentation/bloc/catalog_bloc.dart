import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_item.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_load_policy.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page_snapshot.dart';
import 'package:flutter_architecture/features/catalog/domain/use_cases/search_catalog_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'catalog_bloc.freezed.dart';
part 'catalog_event.dart';
part 'catalog_state.dart';

/// Catalog 搜尋與分頁流程的狀態管理。
///
/// Milestone 13-4 先處理 initial search、debounce、query switching 與 stale
/// response guard；Refresh 與 Append workflow 於 Milestone 13-5 補上。
class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc(
    this._searchCatalogUseCase, {
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
    on<CatalogRefreshRequested>(_onRefreshRequested);
  }

  final SearchCatalogUseCase _searchCatalogUseCase;

  /// 預設 300ms，可於測試注入較短 duration。
  final Duration debounceDuration;

  /// Initial search 每頁筆數；後續 Append 共用。
  final int pageSize;

  int _searchGeneration = 0;
  StreamSubscription<Result<CatalogPageSnapshot>>? _firstPageSubscription;
  Completer<void>? _firstPageCompleter;

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
        initialFailure: null,
        revalidationFailure: null,
        refreshFailure: null,
        appendFailure: null,
      ),
    );

    var hasDisplayableSnapshot = false;
    var isAwaitingRevalidation = false;
    final completer = Completer<void>();
    _firstPageCompleter = completer;

    final subscription = _searchCatalogUseCase
        .watch(
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
                if (error is! Failure) {
                  throw error;
                }
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
        state.isLoadingMore ||
        state.items.isEmpty ||
        requestedCursor == null) {
      return;
    }

    final generation = _searchGeneration;
    final query = state.query;

    emit(state.copyWith(isLoadingMore: true, appendFailure: null));

    late final Result<CatalogPageSnapshot> result;
    try {
      result = await _loadSingleSnapshot(
        _searchCatalogUseCase.watch(
          query: query,
          cursor: requestedCursor,
          limit: pageSize,
          policy: CatalogLoadPolicy.append,
        ),
        operation: 'append',
      );
    } catch (error, stackTrace) {
      if (generation == _searchGeneration &&
          query == state.query &&
          requestedCursor == state.nextCursor) {
        emit(state.copyWith(isLoadingMore: false));
      }
      Error.throwWithStackTrace(error, stackTrace);
    }

    if (generation != _searchGeneration ||
        query != state.query ||
        requestedCursor != state.nextCursor) {
      return;
    }

    result.when(
      success: (snapshot) {
        final page = snapshot.page;
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
        if (error is! Failure) {
          emit(state.copyWith(isLoadingMore: false));
          throw error;
        }
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
    final generation = ++_searchGeneration;
    final query = state.query;

    emit(
      state.copyWith(
        isInitialLoading: false,
        isRefreshing: true,
        isLoadingMore: false,
        isRevalidating: false,
        initialFailure: null,
        revalidationFailure: null,
        refreshFailure: null,
        appendFailure: null,
      ),
    );

    late final Result<CatalogPageSnapshot> result;
    try {
      result = await _loadSingleSnapshot(
        _searchCatalogUseCase.watch(
          query: query,
          cursor: null,
          limit: pageSize,
          policy: CatalogLoadPolicy.refresh,
        ),
        operation: 'refresh',
      );
    } catch (error, stackTrace) {
      if (generation == _searchGeneration && query == state.query) {
        emit(state.copyWith(isRefreshing: false));
      }
      Error.throwWithStackTrace(error, stackTrace);
    }

    if (generation != _searchGeneration || query != state.query) {
      return;
    }

    result.when(
      success: (snapshot) {
        final page = snapshot.page;
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
        if (error is! Failure) {
          emit(state.copyWith(isRefreshing: false));
          throw error;
        }
        emit(state.copyWith(isRefreshing: false, refreshFailure: error));
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

  @override
  Future<void> close() async {
    await _cancelFirstPageSearch();
    return super.close();
  }
}

Future<Result<CatalogPageSnapshot>> _loadSingleSnapshot(
  Stream<Result<CatalogPageSnapshot>> stream, {
  required String operation,
}) async {
  final iterator = StreamIterator<Result<CatalogPageSnapshot>>(stream);
  try {
    if (!await iterator.moveNext()) {
      throw StateError('Catalog $operation stream completed without a result');
    }
    final result = iterator.current;
    if (await iterator.moveNext()) {
      throw StateError(
        'Catalog $operation stream emitted more than one result',
      );
    }
    return result;
  } finally {
    await iterator.cancel();
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
