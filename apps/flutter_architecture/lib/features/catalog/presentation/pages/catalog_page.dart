import 'package:auto_route/auto_route.dart';
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
          padding: const EdgeInsets.all(16),
          child: TextField(
            key: const Key('catalog-search-field'),
            onChanged: (value) => bloc.add(CatalogEvent.queryChanged(value)),
            decoration: const InputDecoration(
              labelText: 'Search catalog',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
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
      return const Center(
        child: CircularProgressIndicator(key: Key('catalog-initial-loading')),
      );
    }

    if (state.initialFailure != null) {
      return _FailureView(
        key: const Key('catalog-initial-failure'),
        message: state.initialFailure!.message,
        onRetry: onRetryInitial,
      );
    }

    return Column(
      children: <Widget>[
        if (_shouldShowCacheStatus(state)) _CatalogCacheStatus(state: state),
        Expanded(
          child: state.hasCompletedInitialLoad && state.items.isEmpty
              ? RefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: <Widget>[
                      const SizedBox(height: 160),
                      const Center(
                        child: Text(
                          'No catalog items',
                          key: Key('catalog-empty'),
                        ),
                      ),
                      if (state.refreshFailure != null) ...<Widget>[
                        const SizedBox(height: 12),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              state.refreshFailure!.message,
                              key: const Key('catalog-refresh-failure'),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
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
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              key: Key('catalog-append-loading'),
                            ),
                          ),
                        );
                      }

                      if (state.appendFailure != null) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: <Widget>[
                              Text(
                                state.appendFailure!.message,
                                key: const Key('catalog-append-failure'),
                              ),
                              TextButton(
                                onPressed: onRetryAppend,
                                child: const Text('Retry load more'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state.refreshFailure != null) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            state.refreshFailure!.message,
                            key: const Key('catalog-refresh-failure'),
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
    final colorScheme = Theme.of(context).colorScheme;
    final isStale = state.isStale;

    return Material(
      key: const Key('catalog-cache-status'),
      color: isStale
          ? colorScheme.errorContainer
          : colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              isStale ? Icons.cloud_off_outlined : Icons.offline_pin_outlined,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    isStale
                        ? 'Showing stale cached data'
                        : 'Showing cached data',
                    key: Key(
                      isStale
                          ? 'catalog-stale-notice'
                          : 'catalog-cached-notice',
                    ),
                  ),
                  if (state.lastUpdatedAt != null) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      'Last updated: ${_formatUtcTimestamp(state.lastUpdatedAt!)}',
                      key: const Key('catalog-last-updated'),
                    ),
                  ],
                  if (state.revalidationFailure != null) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      state.revalidationFailure!.message,
                      key: const Key('catalog-revalidation-failure'),
                    ),
                  ],
                ],
              ),
            ),
            if (state.isRevalidating)
              const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  key: Key('catalog-revalidation-loading'),
                  strokeWidth: 2,
                ),
              ),
          ],
        ),
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

class _FailureView extends StatelessWidget {
  const _FailureView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(message),
          const SizedBox(height: 12),
          FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
