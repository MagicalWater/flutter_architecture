part of 'catalog_bloc.dart';

/// CatalogBloc 可接收的事件。
@freezed
sealed class CatalogEvent with _$CatalogEvent {
  /// 首次進入畫面或 retry initial failure。
  const factory CatalogEvent.initialRequested() = CatalogInitialRequested;

  /// 搜尋欄文字變更；由 Bloc event pipeline 處理 debounce 與 distinct。
  const factory CatalogEvent.queryChanged(String query) = CatalogQueryChanged;

  const factory CatalogEvent.loadMoreRequested() = CatalogLoadMoreRequested;

  const factory CatalogEvent.refreshRequested() = CatalogRefreshRequested;

  /// App-owned connectivity authority觀察到真正offline→online transition。
  const factory CatalogEvent.reconnectObserved() = CatalogReconnectObserved;
}
