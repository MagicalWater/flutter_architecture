import 'package:core/core.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

/// Catalog 哪一個使用者操作失敗，決定畫面要顯示哪種錯誤文案。
enum CatalogFailureSurface {
  /// 第一次進入頁面就載入失敗。
  initial,

  /// 使用者主動重新整理失敗。
  refresh,

  /// 載入下一頁失敗。
  append,

  /// 已先顯示 cache，背景更新遠端資料時失敗。
  revalidation,

  /// 網路恢復後自動重新取得資料失敗。
  reconnect,
}

String localizedCatalogFailure(
  AppLocalizations l10n, {
  required Failure failure,
  required CatalogFailureSurface surface,
}) {
  if (failure.httpStatus == 408) {
    return l10n.catalogRequestTimeoutMessage;
  }
  if (failure.httpStatus == 429) {
    return l10n.catalogRateLimitedMessage;
  }

  return switch (surface) {
    CatalogFailureSurface.initial => l10n.catalogInitialFailureMessage,
    CatalogFailureSurface.refresh => l10n.catalogRefreshFailureMessage,
    CatalogFailureSurface.append => l10n.catalogAppendFailureMessage,
    CatalogFailureSurface.revalidation =>
      l10n.catalogRevalidationFailureMessage,
    CatalogFailureSurface.reconnect => l10n.catalogReconnectFailureMessage,
  };
}

String formatCatalogUpdatedAt(DateTime value, String localeName) {
  return DateFormat.yMd(localeName).add_jm().format(value.toLocal());
}
