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
  String get authInvalidCredentialsMessage => '帳號或密碼不正確。';

  @override
  String get authLoginFailureMessage => '目前無法登入，請稍後再試。';

  @override
  String get authRestoreFailureMessage => '無法恢復先前的登入狀態。';

  @override
  String get authLogoutFailureMessage => '目前無法登出，請稍後再試。';

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
  String get authInvalidCredentialsMessage => '帳號或密碼不正確。';

  @override
  String get authLoginFailureMessage => '目前無法登入，請稍後再試。';

  @override
  String get authRestoreFailureMessage => '無法恢復先前的登入狀態。';

  @override
  String get authLogoutFailureMessage => '目前無法登出，請稍後再試。';

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
}
