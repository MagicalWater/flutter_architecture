import 'package:auto_route/auto_route.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/catalog/presentation/bloc/catalog_bloc.dart';
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

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(DsSpace.lg),
          child: TextField(
            key: const Key('catalog-search-field'),
            onChanged: (value) => bloc.add(CatalogEvent.queryChanged(value)),
            decoration: const InputDecoration(
              labelText: 'Search catalog',
              prefixIcon: Icon(Icons.search),
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
    if (state.isInitialLoading) {
      return const DsLoadingState(
        key: Key('catalog-initial-loading'),
        title: 'Loading catalog',
        message: 'Fetching the latest catalog items.',
        progressSemanticsLabel: 'Catalog loading progress',
      );
    }

    if (state.initialFailure != null) {
      return DsBlockingErrorState(
        key: const Key('catalog-initial-failure'),
        title: 'Unable to load catalog',
        message: state.initialFailure!.message,
        primaryAction: DsPageStateAction(
          label: 'Retry',
          onPressed: onRetryInitial,
        ),
      );
    }

    return Column(
      children: <Widget>[
        if (_shouldShowCacheStatus(state)) _CatalogCacheStatus(state: state),
        Expanded(
          child: state.hasCompletedInitialLoad && state.items.isEmpty
              ? RefreshIndicator(
                  onRefresh: onRefresh,
                  child: CustomScrollView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: <Widget>[
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: DsEmptyState(
                          key: Key('catalog-empty'),
                          title: 'No catalog items',
                          message: 'Try another search or pull to refresh.',
                          scrollable: false,
                        ),
                      ),
                      if (state.refreshFailure != null)
                        SliverPadding(
                          padding: const EdgeInsets.all(DsSpace.lg),
                          sliver: SliverToBoxAdapter(
                            child: DsStatusBanner(
                              key: const Key('catalog-refresh-failure'),
                              tone: DsStatusTone.error,
                              title: 'Refresh failed',
                              message: state.refreshFailure!.message,
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
                        return const Padding(
                          padding: EdgeInsets.all(DsSpace.lg),
                          child: Center(
                            child: DsButtonContent(
                              key: Key('catalog-append-loading'),
                              label: 'Loading more',
                              isLoading: true,
                              progressSemanticsLabel:
                                  'Catalog load more progress',
                            ),
                          ),
                        );
                      }

                      if (state.appendFailure != null) {
                        return Padding(
                          padding: const EdgeInsets.all(DsSpace.lg),
                          child: DsStatusBanner(
                            key: const Key('catalog-append-failure'),
                            tone: DsStatusTone.error,
                            title: 'Unable to load more items',
                            message: state.appendFailure!.message,
                            action: DsStatusBannerAction(
                              label: 'Retry load more',
                              onPressed: onRetryAppend,
                            ),
                          ),
                        );
                      }

                      if (state.refreshFailure != null) {
                        return Padding(
                          padding: const EdgeInsets.all(DsSpace.lg),
                          child: DsStatusBanner(
                            key: const Key('catalog-refresh-failure'),
                            tone: DsStatusTone.error,
                            title: 'Refresh failed',
                            message: state.refreshFailure!.message,
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

bool _shouldShowCacheStatus(CatalogState state) {
  return state.isUsingCachedData ||
      state.isStale ||
      state.isRevalidating ||
      state.revalidationFailure != null;
}

class _CatalogCacheStatus extends StatelessWidget {
  const _CatalogCacheStatus({required this.state});

  final CatalogState state;

  @override
  Widget build(BuildContext context) {
    final isStale = state.isStale;
    final title = isStale ? 'Showing stale cached data' : 'Showing cached data';
    final details = <String>[
      if (state.lastUpdatedAt != null)
        'Last updated: ${_formatUtcTimestamp(state.lastUpdatedAt!)}',
      if (state.revalidationFailure != null) state.revalidationFailure!.message,
    ];

    return Padding(
      key: const Key('catalog-cache-status'),
      padding: const EdgeInsets.fromLTRB(DsSpace.lg, 0, DsSpace.lg, DsSpace.sm),
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
            const SizedBox(height: DsSpace.xs),
            const Align(
              alignment: AlignmentDirectional.centerEnd,
              child: DsButtonContent(
                key: Key('catalog-revalidation-loading'),
                label: 'Updating cached data',
                isLoading: true,
                progressSemanticsLabel: 'Catalog revalidation progress',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatUtcTimestamp(DateTime value) {
  final utc = value.toUtc();
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${utc.year}-${twoDigits(utc.month)}-${twoDigits(utc.day)} '
      '${twoDigits(utc.hour)}:${twoDigits(utc.minute)} UTC';
}
