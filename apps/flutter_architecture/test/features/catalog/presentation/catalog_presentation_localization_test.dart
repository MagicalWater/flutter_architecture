import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/catalog/presentation/catalog_presentation_localization.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('zh_TW');
  });

  test('maps stable 408 and 429 codes without exposing diagnostics', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    expect(
      localizedCatalogFailure(
        l10n,
        failure: const Failure(
          httpStatus: 408,
          message: 'diagnostic timeout detail',
        ),
        surface: CatalogFailureSurface.initial,
      ),
      'The catalog request timed out. Please try again.',
    );
    expect(
      localizedCatalogFailure(
        l10n,
        failure: const Failure(
          httpStatus: 429,
          message: 'diagnostic rate detail',
        ),
        surface: CatalogFailureSurface.append,
      ),
      'Too many catalog requests. Please try again later.',
    );
  });

  test('uses a surface-specific fallback for unknown codes', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    const failure = Failure(httpStatus: 599, message: 'must not reach UI');

    expect(
      localizedCatalogFailure(
        l10n,
        failure: failure,
        surface: CatalogFailureSurface.initial,
      ),
      'Unable to load the catalog. Please try again.',
    );
    expect(
      localizedCatalogFailure(
        l10n,
        failure: failure,
        surface: CatalogFailureSurface.refresh,
      ),
      'Unable to refresh the catalog. Please try again.',
    );
    expect(
      localizedCatalogFailure(
        l10n,
        failure: failure,
        surface: CatalogFailureSurface.append,
      ),
      'Unable to load more catalog items. Please try again.',
    );
    expect(
      localizedCatalogFailure(
        l10n,
        failure: failure,
        surface: CatalogFailureSurface.revalidation,
      ),
      'Unable to update the cached catalog right now.',
    );
  });

  test('formats timestamps with locale-specific date and time conventions', () {
    final value = DateTime(2026, 7, 17, 15, 5);

    final english = formatCatalogUpdatedAt(value, 'en');
    final chinese = formatCatalogUpdatedAt(value, 'zh-TW');

    expect(english, contains('PM'));
    expect(chinese, isNot(equals(english)));
    expect(english, isNot(contains('UTC')));
    expect(chinese, isNot(contains('UTC')));
  });
}
