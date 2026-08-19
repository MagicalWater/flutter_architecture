import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:flutter_architecture/features/catalog/presentation/catalog_presentation_localization.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';

bool shouldShowCatalogCacheStatus(CatalogState state) {
  return state.isUsingCachedData ||
      state.isStale ||
      state.isRevalidating ||
      state.revalidationFailure != null;
}

class CatalogReconnectStatus extends StatelessWidget {
  const CatalogReconnectStatus({required this.state, super.key});

  final CatalogState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final failure = state.reconnectFailure;
    return Padding(
      padding: EdgeInsets.fromLTRB(DsSpace.lg, 0, DsSpace.lg, DsSpace.sm),
      child: DsStatusBanner(
        key: Key(
          failure == null
              ? 'catalog-reconnect-loading'
              : 'catalog-reconnect-failure',
        ),
        tone: failure == null ? DsStatusTone.info : DsStatusTone.warning,
        title: failure == null
            ? l10n.catalogReconnectUpdatingTitle
            : l10n.catalogReconnectFailureTitle,
        message: failure == null
            ? l10n.catalogReconnectUpdatingMessage
            : localizedCatalogFailure(
                l10n,
                failure: failure,
                surface: CatalogFailureSurface.reconnect,
              ),
        icon: failure == null ? Icons.sync : Icons.sync_problem_outlined,
      ),
    );
  }
}

class CatalogCacheStatus extends StatelessWidget {
  const CatalogCacheStatus({required this.state, super.key});

  final CatalogState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isStale = state.isStale;
    final title = isStale
        ? l10n.catalogStaleCacheTitle
        : l10n.catalogCachedDataTitle;
    final localeName = Localizations.localeOf(context).toLanguageTag();
    final details = <String>[
      if (state.lastUpdatedAt != null)
        l10n.catalogLastUpdated(
          formatCatalogUpdatedAt(state.lastUpdatedAt!, localeName),
        ),
      if (state.revalidationFailure != null)
        localizedCatalogFailure(
          l10n,
          failure: state.revalidationFailure!,
          surface: CatalogFailureSurface.revalidation,
        ),
    ];

    return Padding(
      key: const Key('catalog-cache-status'),
      padding: EdgeInsets.fromLTRB(DsSpace.lg, 0, DsSpace.lg, DsSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          DsStatusBanner(
            key: Key(
              isStale ? 'catalog-stale-notice' : 'catalog-cached-notice',
            ),
            tone: state.revalidationFailure != null || isStale
                ? DsStatusTone.warning
                : DsStatusTone.info,
            title: title,
            message: details.isEmpty ? null : details.join('\n'),
            icon: isStale
                ? Icons.cloud_off_outlined
                : Icons.offline_pin_outlined,
          ),
          if (state.isRevalidating) ...<Widget>[
            SizedBox(height: DsSpace.xs),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: DsButtonContent(
                key: const Key('catalog-revalidation-loading'),
                label: l10n.catalogUpdatingCacheLabel,
                isLoading: true,
                progressSemanticsLabel:
                    l10n.catalogRevalidationProgressSemanticsLabel,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
