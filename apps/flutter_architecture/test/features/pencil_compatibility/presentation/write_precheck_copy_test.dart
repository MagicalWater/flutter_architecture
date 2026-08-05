import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/write_precheck_copy.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/visual_spec/pencil_compatibility_visual_spec.dart';
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

  test('visual spec 鎖定 accepted canonical viewport 與核心色票', () {
    expect(PencilCompatibilityVisualSpec.canonicalSize, const Size(941, 1672));
    expect(PencilCompatibilityVisualSpec.canonicalDevicePixelRatio, 1);
    expect(PencilCompatibilityVisualSpec.background, const Color(0xFF020B14));
    expect(PencilCompatibilityVisualSpec.cyan, const Color(0xFF3DAEFF));
    expect(PencilCompatibilityVisualSpec.gold, const Color(0xFFF5B941));
  });
}
