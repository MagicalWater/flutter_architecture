/// Catalog Cache 的 freshness / retention policy。
class CatalogCachePolicy {
  CatalogCachePolicy({
    this.freshFor = const Duration(minutes: 5),
    this.retainFor = const Duration(days: 7),
  }) {
    if (freshFor.isNegative || retainFor.isNegative || retainFor < freshFor) {
      throw ArgumentError('Catalog Cache duration policy 不合法');
    }
  }

  final Duration freshFor;
  final Duration retainFor;
}
