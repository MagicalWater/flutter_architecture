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
          child: _CatalogBody(
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
  final refreshCompleted = bloc.stream
      .skipWhile((state) => !state.isRefreshing)
      .firstWhere((state) => !state.isRefreshing);

  bloc.add(const CatalogEvent.refreshRequested());
  return refreshCompleted;
}

class _CatalogBody extends StatelessWidget {
  const _CatalogBody({
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

    if (state.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          children: const <Widget>[
            SizedBox(height: 160),
            Center(child: Text('No catalog items', key: Key('catalog-empty'))),
          ],
        ),
      );
    }

    return RefreshIndicator(
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
    );
  }
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
