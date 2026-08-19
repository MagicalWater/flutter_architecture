import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/write_precheck_copy.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_palette.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_typography.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WritePrecheckCopy', () {
    test(
      'English copy is meaningful and has the accepted item counts',
      () async {
        final l10n = await AppLocalizations.delegate.load(const Locale('en'));
        final copy = WritePrecheckCopy.from(l10n);

        expect(copy.title, 'Write pre-check');
        expect(copy.flowStep, 'Safe write flow · Step 3 of 4');
        expect(copy.steps, hasLength(4));
        expect(copy.summaryRows, hasLength(5));
        expect(copy.resultRows, hasLength(5));
        expect(copy.records, hasLength(2));
        expect(copy.guidanceLines, hasLength(3));
        expect(copy.secondaryActions, hasLength(2));
        expect(copy.visibleStrings, everyElement(isNotEmpty));
      },
    );

    test(
      'Traditional Chinese copy matches the accepted Pencil content',
      () async {
        final l10n = await AppLocalizations.delegate.load(
          const Locale('zh', 'TW'),
        );
        final copy = WritePrecheckCopy.from(l10n);

        expect(copy.title, '寫前檢查');
        expect(copy.flowStep, '安全寫入流程 · 步驟 3/4');
        expect(copy.steps, <String>['已準備內容', '已偵測標籤', '寫前檢查', '寫入與驗證']);
        expect(copy.heroTitle, '已通過寫前檢查');
        expect(copy.heroStatus, '可開始寫入');
        expect(copy.summaryRows, hasLength(5));
        expect(copy.resultRows, hasLength(5));
        expect(copy.records, hasLength(2));
        expect(copy.guidanceLines, hasLength(3));
        expect(copy.primaryAction, '確認並開始寫入');
        expect(copy.secondaryActions, <String>['查看技術詳情', '返回修改內容']);
        expect(copy.endFlowAction, '結束此次流程');
        expect(copy.visibleStrings, everyElement(isNotEmpty));
      },
    );
  });

  test(
    'focused local palette and typography preserve accepted proof identity',
    () {
      expect(WritePrecheckPalette.background, const Color(0xFF020B14));
      expect(WritePrecheckPalette.text, const Color(0xFFEAF2F8));
      expect(WritePrecheckPalette.muted, const Color(0xFFB8C4CF));
      expect(WritePrecheckPalette.dim, const Color(0xFF7F94A7));
      expect(WritePrecheckPalette.goldAccent, const Color(0xFFF5B941));
      expect(WritePrecheckPalette.blueAccent, const Color(0xFF3DAEFF));
      expect(WritePrecheckPalette.cyanAccent, const Color(0xFF74D8FF));
      expect(WritePrecheckPalette.subtleOutline, const Color(0xFF244056));
      expect(WritePrecheckTypography.fontFamily, 'Noto Sans TC');
      expect(WritePrecheckTypography.fontFamilyFallback, const <String>[
        'Microsoft JhengHei',
        'PingFang TC',
        'Roboto',
      ]);
    },
  );
}
