// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Flutter 架構模板';

  @override
  String get localeDialogTitle => '語言';

  @override
  String get localeSelectorTooltip => '語言';

  @override
  String get localeSystemLabel => '跟隨系統';

  @override
  String get localeEnglishLabel => '英文';

  @override
  String get localeTraditionalChineseLabel => '繁體中文';

  @override
  String get shellTitle => 'Flutter 架構模板';

  @override
  String get shellAppearanceTooltip => '外觀';

  @override
  String get shellProtectedTooltip => '受保護頁面';

  @override
  String get localUnlockSettingsTooltip => '本機解鎖設定';

  @override
  String get navigationLoginLabel => '登入';

  @override
  String get navigationCatalogLabel => '目錄';

  @override
  String get navigationProfileLabel => '個人資料';

  @override
  String get appearanceDialogTitle => '外觀';

  @override
  String get appearanceThemeSectionLabel => '主題';

  @override
  String get appearanceModeSectionLabel => '模式';

  @override
  String get appearanceModeSystemLabel => '跟隨系統';

  @override
  String get appearanceModeLightLabel => '淺色';

  @override
  String get appearanceModeDarkLabel => '深色';

  @override
  String get themeDefaultName => '預設';

  @override
  String get themeOceanName => '海洋';

  @override
  String get commonDoneAction => '完成';

  @override
  String get commonRetryAction => '重試';

  @override
  String get connectivityOfflineMessage => '目前沒有網路連線，部分內容可能不是最新資料。';

  @override
  String get loginTitle => '登入';

  @override
  String get loginAccountLabel => '帳號';

  @override
  String get loginPasswordLabel => '密碼';

  @override
  String get loginSubmitLabel => '登入';

  @override
  String get loginSubmittingLabel => '登入中';

  @override
  String get loginProgressSemanticsLabel => '登入進度';

  @override
  String get loginOpenProtectedAction => '開啟需要登入的頁面';

  @override
  String get localUnlockTitle => '解鎖已儲存的工作階段';

  @override
  String get localUnlockRequiredMessage => '請先驗證是您本人，再還原已儲存的工作階段。';

  @override
  String get localUnlockUnavailableMessage => '目前無法使用本機驗證，請重試或改用帳號登入。';

  @override
  String get localUnlockFailureMessage => '無法安全解鎖已儲存的工作階段。';

  @override
  String get localUnlockRetryAction => '再試一次';

  @override
  String get localUnlockPromptingLabel => '等待驗證';

  @override
  String get localUnlockUseLoginAction => '改用帳號登入';

  @override
  String get localUnlockSemanticsLabel => '已儲存工作階段解鎖畫面';

  @override
  String get localUnlockIconSemanticsLabel => '工作階段已鎖定';

  @override
  String get localUnlockPromptProgressSemanticsLabel => '正在進行本機驗證';

  @override
  String get localUnlockSettingsTitle => '本機解鎖';

  @override
  String get localUnlockSettingsToggleLabel => '使用本機解鎖';

  @override
  String get localUnlockSettingsDescription => '還原已儲存的登入狀態前，必須先完成生物辨識驗證。';

  @override
  String get localUnlockSettingsFailureMessage => '無法更新本機解鎖設定。';

  @override
  String get localUnlockEnableReason => '請驗證以啟用本機解鎖';

  @override
  String get authInvalidCredentialsMessage => '帳號或密碼不正確。';

  @override
  String get authLoginFailureMessage => '目前無法登入，請稍後再試。';

  @override
  String get authRestoreFailureMessage => '無法恢復先前的登入狀態。';

  @override
  String get authLogoutFailureMessage => '目前無法登出，請稍後再試。';

  @override
  String get otpTitle => 'Verification code';

  @override
  String otpInstruction(String destination) {
    return 'Enter the code sent to $destination.';
  }

  @override
  String get otpCodeLabel => 'Verification code';

  @override
  String get otpVerifyAction => 'Verify';

  @override
  String get otpVerifyingLabel => 'Verifying';

  @override
  String get otpVerifyProgressSemanticsLabel => 'Verification progress';

  @override
  String get otpResendAction => 'Resend code';

  @override
  String get otpResendingLabel => 'Resending code';

  @override
  String otpResendCountdown(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get otpInvalidCodeMessage => 'The verification code is incorrect.';

  @override
  String otpInvalidCodeAttemptsMessage(int attempts) {
    return 'The code is incorrect. $attempts attempts remaining.';
  }

  @override
  String get otpExpiredMessage =>
      'This verification code has expired. Request a new code.';

  @override
  String get otpTooManyAttemptsMessage =>
      'Too many incorrect attempts. Request a new code.';

  @override
  String get otpResendCooldownMessage =>
      'Please wait before requesting another code.';

  @override
  String get otpInvalidatedMessage =>
      'This verification request is no longer valid.';

  @override
  String get otpGenericFailureMessage =>
      'Unable to verify the code. Please try again.';

  @override
  String get profileUnauthenticatedTitle => '尚未登入';

  @override
  String get profileUnauthenticatedMessage => '登入後即可查看目前帳號的個人資料。';

  @override
  String get profileLoadingTitle => '載入個人資料';

  @override
  String get profileLoadingMessage => '正在取得最新的帳號資訊。';

  @override
  String get profileLoadingProgressSemanticsLabel => '個人資料載入進度';

  @override
  String get profileLoadFailureTitle => '無法載入個人資料';

  @override
  String get profileLoadFailureMessage => '目前無法載入個人資料，請稍後再試。';

  @override
  String get profileSessionExpiredMessage => '登入狀態已失效，請重新登入。';

  @override
  String get profileLogoutFailureTitle => '登出失敗';

  @override
  String get profileLogoutFailureMessage => '目前無法登出，請稍後再試。';

  @override
  String get profileTitle => '個人資料';

  @override
  String profileCurrentUser(String name) {
    return '目前登入用戶：$name';
  }

  @override
  String get profileUnknownUserLabel => '未知';

  @override
  String get profileLogoutLabel => '登出';

  @override
  String get profileLoggingOutLabel => '登出中';

  @override
  String get profileLogoutProgressSemanticsLabel => '登出進度';

  @override
  String get protectedTitle => '受保護頁面';

  @override
  String get protectedAccessGrantedTitle => '你已通過 Route Guard';

  @override
  String get protectedAccessGrantedMessage =>
      '此頁面只會在 AuthGuard 確認目前已有有效登入 Session 後顯示。';

  @override
  String get catalogSearchLabel => '搜尋目錄';

  @override
  String get catalogLoadingTitle => '載入目錄';

  @override
  String get catalogLoadingMessage => '正在取得最新的目錄項目。';

  @override
  String get catalogLoadingProgressSemanticsLabel => '目錄載入進度';

  @override
  String get catalogInitialFailureTitle => '無法載入目錄';

  @override
  String get catalogInitialFailureMessage => '目前無法載入目錄，請稍後再試。';

  @override
  String get catalogEmptyTitle => '沒有目錄項目';

  @override
  String get catalogEmptyMessage => '請嘗試其他搜尋條件，或下拉重新整理。';

  @override
  String get catalogLoadingMoreLabel => '載入更多';

  @override
  String get catalogLoadMoreProgressSemanticsLabel => '目錄載入更多進度';

  @override
  String get catalogAppendFailureTitle => '無法載入更多項目';

  @override
  String get catalogAppendFailureMessage => '目前無法載入更多目錄項目，請稍後再試。';

  @override
  String get catalogRetryLoadMoreAction => '重試載入更多';

  @override
  String get catalogRefreshFailureTitle => '重新整理失敗';

  @override
  String get catalogRefreshFailureMessage => '目前無法重新整理目錄，請稍後再試。';

  @override
  String get catalogReconnectUpdatingTitle => '網路連線已恢復';

  @override
  String get catalogReconnectUpdatingMessage => '正在背景更新目錄資料。';

  @override
  String get catalogReconnectFailureTitle => '背景更新失敗';

  @override
  String get catalogReconnectFailureMessage => '目前資料仍可使用，但暫時無法完成更新。';

  @override
  String get catalogCachedDataTitle => '正在顯示快取資料';

  @override
  String get catalogStaleCacheTitle => '正在顯示過期的快取資料';

  @override
  String catalogLastUpdated(String value) {
    return '最後更新：$value';
  }

  @override
  String get catalogUpdatingCacheLabel => '正在更新快取資料';

  @override
  String get catalogRevalidationProgressSemanticsLabel => '目錄背景更新進度';

  @override
  String get catalogRevalidationFailureMessage => '目前無法更新快取目錄。';

  @override
  String get catalogRequestTimeoutMessage => '目錄請求逾時，請再試一次。';

  @override
  String get catalogRateLimitedMessage => '目錄請求過於頻繁，請稍後再試。';

  @override
  String get pencilPrecheckTitle => '寫前檢查';

  @override
  String get pencilPrecheckFlowStep => '安全寫入流程 · 步驟 3/4';

  @override
  String get pencilPrecheckStepPrepared => '已準備內容';

  @override
  String get pencilPrecheckStepDetected => '已偵測標籤';

  @override
  String get pencilPrecheckStepActive => '寫前檢查';

  @override
  String get pencilPrecheckStepVerification => '寫入與驗證';

  @override
  String get pencilPrecheckHeroTitle => '已通過寫前檢查';

  @override
  String get pencilPrecheckHeroDescription =>
      '系統已確認目標標籤可讀取、可寫入且容量足夠，並已完成本次交易的安全檢查。請在下一步開始前保持標籤穩定靠近裝置。';

  @override
  String get pencilPrecheckHeroStatus => '可開始寫入';

  @override
  String get pencilPrecheckSummaryTitle => '本次交易摘要';

  @override
  String get pencilPrecheckSummaryTargetLabel => '目標標籤';

  @override
  String get pencilPrecheckSummaryTargetValue =>
      'Type 2 Tag / MIFARE Ultralight';

  @override
  String get pencilPrecheckSummaryRecordsLabel => '寫入內容';

  @override
  String get pencilPrecheckSummaryRecordsValue => '2 筆記錄';

  @override
  String get pencilPrecheckSummarySizeLabel => '預估大小';

  @override
  String get pencilPrecheckSummarySizeValue => '186 bytes';

  @override
  String get pencilPrecheckSummaryModeLabel => '寫入模式';

  @override
  String get pencilPrecheckSummaryModeValue => '覆寫既有 NDEF';

  @override
  String get pencilPrecheckSummaryBackupLabel => '備份狀態';

  @override
  String get pencilPrecheckSummaryBackupValue => '將建立加密備份';

  @override
  String get pencilPrecheckResultsTitle => '寫前檢查結果';

  @override
  String get pencilPrecheckResultCompatibilityLabel => '標籤相容性';

  @override
  String get pencilPrecheckResultCompatibilityValue => '符合本次寫入格式';

  @override
  String get pencilPrecheckResultCapacityLabel => '可用容量';

  @override
  String get pencilPrecheckResultCapacityValue => '仍有足夠空間';

  @override
  String get pencilPrecheckResultPermissionLabel => '寫入權限';

  @override
  String get pencilPrecheckResultPermissionValue => '可寫入，未偵測鎖定';

  @override
  String get pencilPrecheckResultStabilityLabel => '連線穩定性';

  @override
  String get pencilPrecheckResultStabilityValue => '已穩定偵測';

  @override
  String get pencilPrecheckResultDecisionLabel => '目前判定';

  @override
  String get pencilPrecheckResultDecisionValue => '可以安全開始寫入';

  @override
  String get pencilPrecheckTechnicalDetail => '技術細節：UID 已確認、NDEF 會話已就緒';

  @override
  String get pencilPrecheckRecordsTitle => '預期寫入內容';

  @override
  String get pencilPrecheckRecordTextTitle => '文字記錄（zh-TW）';

  @override
  String get pencilPrecheckRecordTextValue => 'NFC Lab 測試內容';

  @override
  String get pencilPrecheckRecordTextBadge => '記錄 1';

  @override
  String get pencilPrecheckRecordUrlTitle => '網址連結';

  @override
  String get pencilPrecheckRecordUrlValue => 'https://example.com/demo';

  @override
  String get pencilPrecheckRecordUrlBadge => '記錄 2';

  @override
  String get pencilPrecheckRecordsNotice => '以上為預期寫入內容，將於下一步正式寫入標籤';

  @override
  String get pencilPrecheckGuidanceTitle => '建議下一步';

  @override
  String get pencilPrecheckGuidanceKeepNear => '請在寫入完成前保持同一張標籤靠近裝置';

  @override
  String get pencilPrecheckGuidanceDoNotMove => '寫入期間請勿移動標籤或離開此畫面';

  @override
  String get pencilPrecheckGuidanceBackup => '若寫入失敗，可使用此次建立的加密備份進行還原';

  @override
  String get pencilPrecheckCommitmentNotice =>
      '寫入開始後，系統將立即執行寫入與驗證流程，並於完成後回報最終結果。';

  @override
  String get pencilPrecheckPrimaryAction => '確認並開始寫入';

  @override
  String get pencilPrecheckTechnicalAction => '查看技術詳情';

  @override
  String get pencilPrecheckEditAction => '返回修改內容';

  @override
  String get pencilPrecheckEndFlowAction => '結束此次流程';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => 'Flutter 架構模板';

  @override
  String get localeDialogTitle => '語言';

  @override
  String get localeSelectorTooltip => '語言';

  @override
  String get localeSystemLabel => '跟隨系統';

  @override
  String get localeEnglishLabel => '英文';

  @override
  String get localeTraditionalChineseLabel => '繁體中文';

  @override
  String get shellTitle => 'Flutter 架構模板';

  @override
  String get shellAppearanceTooltip => '外觀';

  @override
  String get shellProtectedTooltip => '受保護頁面';

  @override
  String get localUnlockSettingsTooltip => '本機解鎖設定';

  @override
  String get navigationLoginLabel => '登入';

  @override
  String get navigationCatalogLabel => '目錄';

  @override
  String get navigationProfileLabel => '個人資料';

  @override
  String get appearanceDialogTitle => '外觀';

  @override
  String get appearanceThemeSectionLabel => '主題';

  @override
  String get appearanceModeSectionLabel => '模式';

  @override
  String get appearanceModeSystemLabel => '跟隨系統';

  @override
  String get appearanceModeLightLabel => '淺色';

  @override
  String get appearanceModeDarkLabel => '深色';

  @override
  String get themeDefaultName => '預設';

  @override
  String get themeOceanName => '海洋';

  @override
  String get commonDoneAction => '完成';

  @override
  String get commonRetryAction => '重試';

  @override
  String get connectivityOfflineMessage => '目前沒有網路連線，部分內容可能不是最新資料。';

  @override
  String get loginTitle => '登入';

  @override
  String get loginAccountLabel => '帳號';

  @override
  String get loginPasswordLabel => '密碼';

  @override
  String get loginSubmitLabel => '登入';

  @override
  String get loginSubmittingLabel => '登入中';

  @override
  String get loginProgressSemanticsLabel => '登入進度';

  @override
  String get loginOpenProtectedAction => '開啟需要登入的頁面';

  @override
  String get localUnlockTitle => '解鎖已儲存的工作階段';

  @override
  String get localUnlockRequiredMessage => '請先驗證是您本人，再還原已儲存的工作階段。';

  @override
  String get localUnlockUnavailableMessage => '目前無法使用本機驗證，請重試或改用帳號登入。';

  @override
  String get localUnlockFailureMessage => '無法安全解鎖已儲存的工作階段。';

  @override
  String get localUnlockRetryAction => '再試一次';

  @override
  String get localUnlockPromptingLabel => '等待驗證';

  @override
  String get localUnlockUseLoginAction => '改用帳號登入';

  @override
  String get localUnlockSemanticsLabel => '已儲存工作階段解鎖畫面';

  @override
  String get localUnlockIconSemanticsLabel => '工作階段已鎖定';

  @override
  String get localUnlockPromptProgressSemanticsLabel => '正在進行本機驗證';

  @override
  String get localUnlockSettingsTitle => '本機解鎖';

  @override
  String get localUnlockSettingsToggleLabel => '使用本機解鎖';

  @override
  String get localUnlockSettingsDescription => '還原已儲存的登入狀態前，必須先完成生物辨識驗證。';

  @override
  String get localUnlockSettingsFailureMessage => '無法更新本機解鎖設定。';

  @override
  String get localUnlockEnableReason => '請驗證以啟用本機解鎖';

  @override
  String get authInvalidCredentialsMessage => '帳號或密碼不正確。';

  @override
  String get authLoginFailureMessage => '目前無法登入，請稍後再試。';

  @override
  String get authRestoreFailureMessage => '無法恢復先前的登入狀態。';

  @override
  String get authLogoutFailureMessage => '目前無法登出，請稍後再試。';

  @override
  String get otpTitle => '驗證碼';

  @override
  String otpInstruction(String destination) {
    return '請輸入傳送至 $destination 的驗證碼。';
  }

  @override
  String get otpCodeLabel => '驗證碼';

  @override
  String get otpVerifyAction => '驗證';

  @override
  String get otpVerifyingLabel => '驗證中';

  @override
  String get otpVerifyProgressSemanticsLabel => '驗證進度';

  @override
  String get otpResendAction => '重新傳送驗證碼';

  @override
  String get otpResendingLabel => '重新傳送中';

  @override
  String otpResendCountdown(int seconds) {
    return '$seconds 秒後可重新傳送';
  }

  @override
  String get otpInvalidCodeMessage => '驗證碼不正確。';

  @override
  String otpInvalidCodeAttemptsMessage(int attempts) {
    return '驗證碼不正確，剩餘 $attempts 次機會。';
  }

  @override
  String get otpExpiredMessage => '驗證碼已過期，請重新取得。';

  @override
  String get otpTooManyAttemptsMessage => '錯誤次數過多，請重新取得驗證碼。';

  @override
  String get otpResendCooldownMessage => '請稍候再重新傳送驗證碼。';

  @override
  String get otpInvalidatedMessage => '此驗證流程已失效。';

  @override
  String get otpGenericFailureMessage => '無法驗證，請稍後再試。';

  @override
  String get profileUnauthenticatedTitle => '尚未登入';

  @override
  String get profileUnauthenticatedMessage => '登入後即可查看目前帳號的個人資料。';

  @override
  String get profileLoadingTitle => '載入個人資料';

  @override
  String get profileLoadingMessage => '正在取得最新的帳號資訊。';

  @override
  String get profileLoadingProgressSemanticsLabel => '個人資料載入進度';

  @override
  String get profileLoadFailureTitle => '無法載入個人資料';

  @override
  String get profileLoadFailureMessage => '目前無法載入個人資料，請稍後再試。';

  @override
  String get profileSessionExpiredMessage => '登入狀態已失效，請重新登入。';

  @override
  String get profileLogoutFailureTitle => '登出失敗';

  @override
  String get profileLogoutFailureMessage => '目前無法登出，請稍後再試。';

  @override
  String get profileTitle => '個人資料';

  @override
  String profileCurrentUser(String name) {
    return '目前登入用戶：$name';
  }

  @override
  String get profileUnknownUserLabel => '未知';

  @override
  String get profileLogoutLabel => '登出';

  @override
  String get profileLoggingOutLabel => '登出中';

  @override
  String get profileLogoutProgressSemanticsLabel => '登出進度';

  @override
  String get protectedTitle => '受保護頁面';

  @override
  String get protectedAccessGrantedTitle => '你已通過 Route Guard';

  @override
  String get protectedAccessGrantedMessage =>
      '此頁面只會在 AuthGuard 確認目前已有有效登入 Session 後顯示。';

  @override
  String get catalogSearchLabel => '搜尋目錄';

  @override
  String get catalogLoadingTitle => '載入目錄';

  @override
  String get catalogLoadingMessage => '正在取得最新的目錄項目。';

  @override
  String get catalogLoadingProgressSemanticsLabel => '目錄載入進度';

  @override
  String get catalogInitialFailureTitle => '無法載入目錄';

  @override
  String get catalogInitialFailureMessage => '目前無法載入目錄，請稍後再試。';

  @override
  String get catalogEmptyTitle => '沒有目錄項目';

  @override
  String get catalogEmptyMessage => '請嘗試其他搜尋條件，或下拉重新整理。';

  @override
  String get catalogLoadingMoreLabel => '載入更多';

  @override
  String get catalogLoadMoreProgressSemanticsLabel => '目錄載入更多進度';

  @override
  String get catalogAppendFailureTitle => '無法載入更多項目';

  @override
  String get catalogAppendFailureMessage => '目前無法載入更多目錄項目，請稍後再試。';

  @override
  String get catalogRetryLoadMoreAction => '重試載入更多';

  @override
  String get catalogRefreshFailureTitle => '重新整理失敗';

  @override
  String get catalogRefreshFailureMessage => '目前無法重新整理目錄，請稍後再試。';

  @override
  String get catalogReconnectUpdatingTitle => '網路連線已恢復';

  @override
  String get catalogReconnectUpdatingMessage => '正在背景更新目錄資料。';

  @override
  String get catalogReconnectFailureTitle => '背景更新失敗';

  @override
  String get catalogReconnectFailureMessage => '目前資料仍可使用，但暫時無法完成更新。';

  @override
  String get catalogCachedDataTitle => '正在顯示快取資料';

  @override
  String get catalogStaleCacheTitle => '正在顯示過期的快取資料';

  @override
  String catalogLastUpdated(String value) {
    return '最後更新：$value';
  }

  @override
  String get catalogUpdatingCacheLabel => '正在更新快取資料';

  @override
  String get catalogRevalidationProgressSemanticsLabel => '目錄背景更新進度';

  @override
  String get catalogRevalidationFailureMessage => '目前無法更新快取目錄。';

  @override
  String get catalogRequestTimeoutMessage => '目錄請求逾時，請再試一次。';

  @override
  String get catalogRateLimitedMessage => '目錄請求過於頻繁，請稍後再試。';

  @override
  String get pencilPrecheckTitle => '寫前檢查';

  @override
  String get pencilPrecheckFlowStep => '安全寫入流程 · 步驟 3/4';

  @override
  String get pencilPrecheckStepPrepared => '已準備內容';

  @override
  String get pencilPrecheckStepDetected => '已偵測標籤';

  @override
  String get pencilPrecheckStepActive => '寫前檢查';

  @override
  String get pencilPrecheckStepVerification => '寫入與驗證';

  @override
  String get pencilPrecheckHeroTitle => '已通過寫前檢查';

  @override
  String get pencilPrecheckHeroDescription =>
      '系統已確認目標標籤可讀取、可寫入且容量足夠，並已完成本次交易的安全檢查。請在下一步開始前保持標籤穩定靠近裝置。';

  @override
  String get pencilPrecheckHeroStatus => '可開始寫入';

  @override
  String get pencilPrecheckSummaryTitle => '本次交易摘要';

  @override
  String get pencilPrecheckSummaryTargetLabel => '目標標籤';

  @override
  String get pencilPrecheckSummaryTargetValue =>
      'Type 2 Tag / MIFARE Ultralight';

  @override
  String get pencilPrecheckSummaryRecordsLabel => '寫入內容';

  @override
  String get pencilPrecheckSummaryRecordsValue => '2 筆記錄';

  @override
  String get pencilPrecheckSummarySizeLabel => '預估大小';

  @override
  String get pencilPrecheckSummarySizeValue => '186 bytes';

  @override
  String get pencilPrecheckSummaryModeLabel => '寫入模式';

  @override
  String get pencilPrecheckSummaryModeValue => '覆寫既有 NDEF';

  @override
  String get pencilPrecheckSummaryBackupLabel => '備份狀態';

  @override
  String get pencilPrecheckSummaryBackupValue => '將建立加密備份';

  @override
  String get pencilPrecheckResultsTitle => '寫前檢查結果';

  @override
  String get pencilPrecheckResultCompatibilityLabel => '標籤相容性';

  @override
  String get pencilPrecheckResultCompatibilityValue => '符合本次寫入格式';

  @override
  String get pencilPrecheckResultCapacityLabel => '可用容量';

  @override
  String get pencilPrecheckResultCapacityValue => '仍有足夠空間';

  @override
  String get pencilPrecheckResultPermissionLabel => '寫入權限';

  @override
  String get pencilPrecheckResultPermissionValue => '可寫入，未偵測鎖定';

  @override
  String get pencilPrecheckResultStabilityLabel => '連線穩定性';

  @override
  String get pencilPrecheckResultStabilityValue => '已穩定偵測';

  @override
  String get pencilPrecheckResultDecisionLabel => '目前判定';

  @override
  String get pencilPrecheckResultDecisionValue => '可以安全開始寫入';

  @override
  String get pencilPrecheckTechnicalDetail => '技術細節：UID 已確認、NDEF 會話已就緒';

  @override
  String get pencilPrecheckRecordsTitle => '預期寫入內容';

  @override
  String get pencilPrecheckRecordTextTitle => '文字記錄（zh-TW）';

  @override
  String get pencilPrecheckRecordTextValue => 'NFC Lab 測試內容';

  @override
  String get pencilPrecheckRecordTextBadge => '記錄 1';

  @override
  String get pencilPrecheckRecordUrlTitle => '網址連結';

  @override
  String get pencilPrecheckRecordUrlValue => 'https://example.com/demo';

  @override
  String get pencilPrecheckRecordUrlBadge => '記錄 2';

  @override
  String get pencilPrecheckRecordsNotice => '以上為預期寫入內容，將於下一步正式寫入標籤';

  @override
  String get pencilPrecheckGuidanceTitle => '建議下一步';

  @override
  String get pencilPrecheckGuidanceKeepNear => '請在寫入完成前保持同一張標籤靠近裝置';

  @override
  String get pencilPrecheckGuidanceDoNotMove => '寫入期間請勿移動標籤或離開此畫面';

  @override
  String get pencilPrecheckGuidanceBackup => '若寫入失敗，可使用此次建立的加密備份進行還原';

  @override
  String get pencilPrecheckCommitmentNotice =>
      '寫入開始後，系統將立即執行寫入與驗證流程，並於完成後回報最終結果。';

  @override
  String get pencilPrecheckPrimaryAction => '確認並開始寫入';

  @override
  String get pencilPrecheckTechnicalAction => '查看技術詳情';

  @override
  String get pencilPrecheckEditAction => '返回修改內容';

  @override
  String get pencilPrecheckEndFlowAction => '結束此次流程';
}
