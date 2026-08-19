import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_scope.dart';
import 'package:flutter_architecture/features/catalog/presentation/catalog_presentation_localization.dart';
import 'package:flutter_architecture/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:flutter_architecture/features/catalog/presentation/widgets/catalog_status_surfaces.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';

@RoutePage()
class CatalogPage extends HookWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = useBloc<CatalogBloc>();
    final state = useBlocBuilder(bloc);
    final scrollController = useScrollController();
    final l10n = AppLocalizations.of(context);
    final connectivityController = ConnectivityScope.of(context);

    useEffect(() {
      bloc.add(const CatalogEvent.initialRequested());

      void onScroll() {
        if (!scrollController.hasClients) return;
        final position = scrollController.position;
        if (position.pixels >= position.maxScrollExtent - 200) {
          bloc.add(const CatalogEvent.loadMoreRequested());
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, <Object?>[bloc, scrollController]);

    useEffect(() {
      final subscription = connectivityController.reconnects.listen((_) {
        bloc.add(const CatalogEvent.reconnectObserved());
      });
      return () => unawaited(subscription.cancel());
    }, <Object?>[bloc, connectivityController]);

    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(DsSpace.lg),
          child: TextField(
            key: const Key('catalog-search-field'),
            onChanged: (value) => bloc.add(CatalogEvent.queryChanged(value)),
            decoration: InputDecoration(
              labelText: l10n.catalogSearchLabel,
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: CatalogView(
            state: state,
            scrollController: scrollController,
            onRetryInitial: () =>
                bloc.add(const CatalogEvent.initialRequested()),
            onRetryAppend: () =>
                bloc.add(const CatalogEvent.loadMoreRequested()),
            onRefresh: () => requestCatalogRefresh(bloc),
          ),
        ),
      ],
    );
  }
}

/// 先建立單一 refresh lifecycle subscription，再送出 event。
Future<void> requestCatalogRefresh(CatalogBloc bloc) {
  if (bloc.state.isRefreshing) {
    return bloc.stream.firstWhere((state) => !state.isRefreshing);
  }

  final refreshCompleted = bloc.stream
      .skipWhile((state) => !state.isRefreshing)
      .firstWhere((state) => !state.isRefreshing);

  bloc.add(const CatalogEvent.refreshRequested());
  return refreshCompleted;
}

class CatalogView extends StatelessWidget {
  const CatalogView({
    super.key,
    required this.state,
    required this.scrollController,
    required this.onRetryInitial,
    required this.onRetryAppend,
    required this.onRefresh,
  });

  final CatalogState state;
  final ScrollController scrollController;
  final VoidCallback onRetryInitial;
  final VoidCallback onRetryAppend;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (state.isInitialLoading) {
      return DsLoadingState(
        key: const Key('catalog-initial-loading'),
        title: l10n.catalogLoadingTitle,
        message: l10n.catalogLoadingMessage,
        progressSemanticsLabel: l10n.catalogLoadingProgressSemanticsLabel,
      );
    }

    if (state.initialFailure != null) {
      return DsBlockingErrorState(
        key: const Key('catalog-initial-failure'),
        title: l10n.catalogInitialFailureTitle,
        message: localizedCatalogFailure(
          l10n,
          failure: state.initialFailure!,
          surface: CatalogFailureSurface.initial,
        ),
        primaryAction: DsPageStateAction(
          label: l10n.commonRetryAction,
          onPressed: onRetryInitial,
        ),
      );
    }

    return Column(
      children: <Widget>[
        if (shouldShowCatalogCacheStatus(state))
          CatalogCacheStatus(state: state),
        if (state.isReconnectRevalidating || state.reconnectFailure != null)
          CatalogReconnectStatus(state: state),
        Expanded(
          child: state.hasCompletedInitialLoad && state.items.isEmpty
              ? RefreshIndicator(
                  onRefresh: onRefresh,
                  child: CustomScrollView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: <Widget>[
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: DsEmptyState(
                          key: const Key('catalog-empty'),
                          title: l10n.catalogEmptyTitle,
                          message: l10n.catalogEmptyMessage,
                          scrollable: false,
                        ),
                      ),
                      if (state.refreshFailure != null)
                        SliverPadding(
                          padding: EdgeInsets.all(DsSpace.lg),
                          sliver: SliverToBoxAdapter(
                            child: DsStatusBanner(
                              key: const Key('catalog-refresh-failure'),
                              tone: DsStatusTone.error,
                              title: l10n.catalogRefreshFailureTitle,
                              message: localizedCatalogFailure(
                                l10n,
                                failure: state.refreshFailure!,
                                surface: CatalogFailureSurface.refresh,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView.builder(
                    key: const Key('catalog-list'),
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: state.items.length + 1,
                    itemBuilder: (context, index) {
                      if (index < state.items.length) {
                        final item = state.items[index];
                        return ListTile(
                          key: ValueKey<String>('catalog-item-${item.id}'),
                          title: Text(item.name),
                          subtitle: Text(item.description),
                        );
                      }

                      if (state.isLoadingMore) {
                        return Padding(
                          padding: EdgeInsets.all(DsSpace.lg),
                          child: Center(
                            child: DsButtonContent(
                              key: const Key('catalog-append-loading'),
                              label: l10n.catalogLoadingMoreLabel,
                              isLoading: true,
                              progressSemanticsLabel:
                                  l10n.catalogLoadMoreProgressSemanticsLabel,
                            ),
                          ),
                        );
                      }

                      if (state.appendFailure != null) {
                        return Padding(
                          padding: EdgeInsets.all(DsSpace.lg),
                          child: DsStatusBanner(
                            key: const Key('catalog-append-failure'),
                            tone: DsStatusTone.error,
                            title: l10n.catalogAppendFailureTitle,
                            message: localizedCatalogFailure(
                              l10n,
                              failure: state.appendFailure!,
                              surface: CatalogFailureSurface.append,
                            ),
                            action: DsStatusBannerAction(
                              label: l10n.catalogRetryLoadMoreAction,
                              onPressed: onRetryAppend,
                            ),
                          ),
                        );
                      }

                      if (state.refreshFailure != null) {
                        return Padding(
                          padding: EdgeInsets.all(DsSpace.lg),
                          child: DsStatusBanner(
                            key: const Key('catalog-refresh-failure'),
                            tone: DsStatusTone.error,
                            title: l10n.catalogRefreshFailureTitle,
                            message: localizedCatalogFailure(
                              l10n,
                              failure: state.refreshFailure!,
                              surface: CatalogFailureSurface.refresh,
                            ),
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
