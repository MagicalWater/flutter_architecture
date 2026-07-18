import 'package:core/core.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

enum CatalogFailureSurface { initial, refresh, append, revalidation }

String localizedCatalogFailure(
  AppLocalizations l10n, {
  required Failure failure,
  required CatalogFailureSurface surface,
}) {
  if (failure.code == '408') {
    return l10n.catalogRequestTimeoutMessage;
  }
  if (failure.code == '429') {
    return l10n.catalogRateLimitedMessage;
  }

  return switch (surface) {
    CatalogFailureSurface.initial => l10n.catalogInitialFailureMessage,
    CatalogFailureSurface.refresh => l10n.catalogRefreshFailureMessage,
    CatalogFailureSurface.append => l10n.catalogAppendFailureMessage,
    CatalogFailureSurface.revalidation =>
      l10n.catalogRevalidationFailureMessage,
  };
}

String formatCatalogUpdatedAt(DateTime value, String localeName) {
  return DateFormat.yMd(localeName).add_jm().format(value.toLocal());
}
