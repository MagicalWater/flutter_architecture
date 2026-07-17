import 'package:core/core.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_item.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_load_policy.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page.dart'
    as domain;
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page_snapshot.dart';
import 'package:flutter_architecture/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:flutter_architecture/features/catalog/domain/use_cases/search_catalog_use_case.dart';
import 'package:flutter_architecture/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:flutter_architecture/features/catalog/presentation/pages/catalog_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('快速完成的 refresh callback 仍會正常結束', () async {
    final bloc = CatalogBloc(
      SearchCatalogUseCase(_ImmediateCatalogRepository()),
      debounceDuration: Duration.zero,
    );
    addTearDown(bloc.close);

    bloc.add(const CatalogEvent.initialRequested());
    await bloc.stream.firstWhere((state) => state.hasCompletedInitialLoad);

    await requestCatalogRefresh(bloc).timeout(const Duration(seconds: 1));

    expect(bloc.state.isRefreshing, isFalse);
    expect(bloc.state.hasCompletedInitialLoad, isTrue);
  });
}

class _ImmediateCatalogRepository implements CatalogRepository {
  @override
  Stream<Result<CatalogPageSnapshot>> watchCatalog({
    required String query,
    required String? cursor,
    required int limit,
    required CatalogLoadPolicy policy,
  }) async* {
    yield Success<CatalogPageSnapshot>(
      CatalogPageSnapshot(
        page: const domain.CatalogPage(items: <CatalogItem>[]),
        source: CatalogDataSource.remote,
        freshness: CatalogFreshness.fresh,
        lastUpdatedAt: DateTime.utc(2026, 7, 17),
      ),
    );
  }
}
