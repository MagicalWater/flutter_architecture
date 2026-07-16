part of 'catalog_bloc.dart';

/// Catalog 畫面的完整 state shape。
///
/// Loading 與 Failure 依 Initial / Refresh / Append 分離，避免未來 UI 混用。
@freezed
abstract class CatalogState with _$CatalogState {
  const factory CatalogState({
    required String query,
    required List<CatalogItem> items,
    required String? nextCursor,
    required bool isInitialLoading,
    required bool isRefreshing,
    required bool isLoadingMore,
    required bool hasCompletedInitialLoad,
    required Failure? initialFailure,
    required Failure? refreshFailure,
    required Failure? appendFailure,
  }) = _CatalogState;

  const CatalogState._();

  factory CatalogState.initial() => const CatalogState(
    query: '',
    items: <CatalogItem>[],
    nextCursor: null,
    isInitialLoading: false,
    isRefreshing: false,
    isLoadingMore: false,
    hasCompletedInitialLoad: false,
    initialFailure: null,
    refreshFailure: null,
    appendFailure: null,
  );

  bool get hasMore => nextCursor != null;

  bool get isEmpty =>
      hasCompletedInitialLoad &&
      !isInitialLoading &&
      initialFailure == null &&
      refreshFailure == null &&
      items.isEmpty;
}
