abstract interface class CatalogClock {
  DateTime nowUtc();
}

class SystemCatalogClock implements CatalogClock {
  const SystemCatalogClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}
