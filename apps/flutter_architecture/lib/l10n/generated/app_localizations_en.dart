// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Architecture';

  @override
  String get localeDialogTitle => 'Language';

  @override
  String get localeSelectorTooltip => 'Language';

  @override
  String get localeSystemLabel => 'System';

  @override
  String get localeEnglishLabel => 'English';

  @override
  String get localeTraditionalChineseLabel => 'Traditional Chinese';

  @override
  String get shellTitle => 'Flutter Architecture';

  @override
  String get shellAppearanceTooltip => 'Appearance';

  @override
  String get shellProtectedTooltip => 'Protected Page';

  @override
  String get localUnlockSettingsTooltip => 'Local unlock settings';

  @override
  String get navigationLoginLabel => 'Login';

  @override
  String get navigationCatalogLabel => 'Catalog';

  @override
  String get navigationProfileLabel => 'Profile';

  @override
  String get appearanceDialogTitle => 'Appearance';

  @override
  String get appearanceThemeSectionLabel => 'Theme';

  @override
  String get appearanceModeSectionLabel => 'Mode';

  @override
  String get appearanceModeSystemLabel => 'System';

  @override
  String get appearanceModeLightLabel => 'Light';

  @override
  String get appearanceModeDarkLabel => 'Dark';

  @override
  String get themeDefaultName => 'Default';

  @override
  String get themeOceanName => 'Ocean';

  @override
  String get commonDoneAction => 'Done';

  @override
  String get commonRetryAction => 'Retry';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginAccountLabel => 'Account';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginSubmitLabel => 'Log in';

  @override
  String get loginSubmittingLabel => 'Logging in';

  @override
  String get loginProgressSemanticsLabel => 'Login progress';

  @override
  String get loginOpenProtectedAction => 'Open protected page';

  @override
  String get localUnlockTitle => 'Unlock saved session';

  @override
  String get localUnlockRequiredMessage =>
      'Verify that it is you before restoring the saved session.';

  @override
  String get localUnlockUnavailableMessage =>
      'Local verification is unavailable. Try again or log in with your account.';

  @override
  String get localUnlockFailureMessage =>
      'The saved session could not be unlocked safely.';

  @override
  String get localUnlockRetryAction => 'Try again';

  @override
  String get localUnlockPromptingLabel => 'Waiting for verification';

  @override
  String get localUnlockUseLoginAction => 'Log in with account instead';

  @override
  String get localUnlockSemanticsLabel => 'Saved session unlock screen';

  @override
  String get localUnlockIconSemanticsLabel => 'Locked session';

  @override
  String get localUnlockPromptProgressSemanticsLabel =>
      'Local verification in progress';

  @override
  String get localUnlockSettingsTitle => 'Local unlock';

  @override
  String get localUnlockSettingsToggleLabel => 'Use local unlock';

  @override
  String get localUnlockSettingsDescription =>
      'Require biometric verification before restoring a saved session.';

  @override
  String get localUnlockSettingsFailureMessage =>
      'Unable to update local unlock settings.';

  @override
  String get localUnlockEnableReason => 'Verify to enable local unlock';

  @override
  String get authInvalidCredentialsMessage =>
      'The account or password is incorrect.';

  @override
  String get authLoginFailureMessage => 'Unable to log in. Please try again.';

  @override
  String get authRestoreFailureMessage =>
      'Unable to restore the previous session.';

  @override
  String get authLogoutFailureMessage => 'Unable to log out. Please try again.';

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
  String get profileUnauthenticatedTitle => 'Not logged in';

  @override
  String get profileUnauthenticatedMessage =>
      'Log in to view the current account profile.';

  @override
  String get profileLoadingTitle => 'Loading profile';

  @override
  String get profileLoadingMessage =>
      'Retrieving the latest account information.';

  @override
  String get profileLoadingProgressSemanticsLabel => 'Profile loading progress';

  @override
  String get profileLoadFailureTitle => 'Unable to load profile';

  @override
  String get profileLoadFailureMessage =>
      'Unable to load the profile. Please try again.';

  @override
  String get profileSessionExpiredMessage =>
      'Your session is no longer valid. Please log in again.';

  @override
  String get profileLogoutFailureTitle => 'Logout failed';

  @override
  String get profileLogoutFailureMessage =>
      'Unable to log out. Please try again.';

  @override
  String get profileTitle => 'Profile';

  @override
  String profileCurrentUser(String name) {
    return 'Current user: $name';
  }

  @override
  String get profileUnknownUserLabel => 'Unknown';

  @override
  String get profileLogoutLabel => 'Log out';

  @override
  String get profileLoggingOutLabel => 'Logging out';

  @override
  String get profileLogoutProgressSemanticsLabel => 'Logout progress';

  @override
  String get protectedTitle => 'Protected Page';

  @override
  String get protectedAccessGrantedTitle => 'Route Guard passed';

  @override
  String get protectedAccessGrantedMessage =>
      'This page is shown only after AuthGuard confirms a valid authenticated session.';

  @override
  String get catalogSearchLabel => 'Search catalog';

  @override
  String get catalogLoadingTitle => 'Loading catalog';

  @override
  String get catalogLoadingMessage => 'Fetching the latest catalog items.';

  @override
  String get catalogLoadingProgressSemanticsLabel => 'Catalog loading progress';

  @override
  String get catalogInitialFailureTitle => 'Unable to load catalog';

  @override
  String get catalogInitialFailureMessage =>
      'Unable to load the catalog. Please try again.';

  @override
  String get catalogEmptyTitle => 'No catalog items';

  @override
  String get catalogEmptyMessage => 'Try another search or pull to refresh.';

  @override
  String get catalogLoadingMoreLabel => 'Loading more';

  @override
  String get catalogLoadMoreProgressSemanticsLabel =>
      'Catalog load more progress';

  @override
  String get catalogAppendFailureTitle => 'Unable to load more items';

  @override
  String get catalogAppendFailureMessage =>
      'Unable to load more catalog items. Please try again.';

  @override
  String get catalogRetryLoadMoreAction => 'Retry load more';

  @override
  String get catalogRefreshFailureTitle => 'Refresh failed';

  @override
  String get catalogRefreshFailureMessage =>
      'Unable to refresh the catalog. Please try again.';

  @override
  String get catalogCachedDataTitle => 'Showing cached data';

  @override
  String get catalogStaleCacheTitle => 'Showing stale cached data';

  @override
  String catalogLastUpdated(String value) {
    return 'Last updated: $value';
  }

  @override
  String get catalogUpdatingCacheLabel => 'Updating cached data';

  @override
  String get catalogRevalidationProgressSemanticsLabel =>
      'Catalog revalidation progress';

  @override
  String get catalogRevalidationFailureMessage =>
      'Unable to update the cached catalog right now.';

  @override
  String get catalogRequestTimeoutMessage =>
      'The catalog request timed out. Please try again.';

  @override
  String get catalogRateLimitedMessage =>
      'Too many catalog requests. Please try again later.';
}
