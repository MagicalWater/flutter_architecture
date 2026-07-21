import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// Application title shown by the operating system and task switcher.
  ///
  /// In en, this message translates to:
  /// **'Flutter Architecture'**
  String get appTitle;

  /// No description provided for @localeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get localeDialogTitle;

  /// No description provided for @localeSelectorTooltip.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get localeSelectorTooltip;

  /// No description provided for @localeSystemLabel.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get localeSystemLabel;

  /// No description provided for @localeEnglishLabel.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get localeEnglishLabel;

  /// No description provided for @localeTraditionalChineseLabel.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get localeTraditionalChineseLabel;

  /// No description provided for @shellTitle.
  ///
  /// In en, this message translates to:
  /// **'Flutter Architecture'**
  String get shellTitle;

  /// No description provided for @shellAppearanceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get shellAppearanceTooltip;

  /// No description provided for @shellProtectedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Protected Page'**
  String get shellProtectedTooltip;

  /// No description provided for @localUnlockSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Local unlock settings'**
  String get localUnlockSettingsTooltip;

  /// No description provided for @navigationLoginLabel.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get navigationLoginLabel;

  /// No description provided for @navigationCatalogLabel.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get navigationCatalogLabel;

  /// No description provided for @navigationProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navigationProfileLabel;

  /// No description provided for @appearanceDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceDialogTitle;

  /// No description provided for @appearanceThemeSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get appearanceThemeSectionLabel;

  /// No description provided for @appearanceModeSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get appearanceModeSectionLabel;

  /// No description provided for @appearanceModeSystemLabel.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get appearanceModeSystemLabel;

  /// No description provided for @appearanceModeLightLabel.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceModeLightLabel;

  /// No description provided for @appearanceModeDarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceModeDarkLabel;

  /// No description provided for @themeDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get themeDefaultName;

  /// No description provided for @themeOceanName.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get themeOceanName;

  /// No description provided for @commonDoneAction.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDoneAction;

  /// No description provided for @commonRetryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetryAction;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get loginAccountLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginSubmitLabel.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginSubmitLabel;

  /// No description provided for @loginSubmittingLabel.
  ///
  /// In en, this message translates to:
  /// **'Logging in'**
  String get loginSubmittingLabel;

  /// No description provided for @loginProgressSemanticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Login progress'**
  String get loginProgressSemanticsLabel;

  /// No description provided for @loginOpenProtectedAction.
  ///
  /// In en, this message translates to:
  /// **'Open protected page'**
  String get loginOpenProtectedAction;

  /// No description provided for @localUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock saved session'**
  String get localUnlockTitle;

  /// No description provided for @localUnlockRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Verify that it is you before restoring the saved session.'**
  String get localUnlockRequiredMessage;

  /// No description provided for @localUnlockUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Local verification is unavailable. Try again or log in with your account.'**
  String get localUnlockUnavailableMessage;

  /// No description provided for @localUnlockFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'The saved session could not be unlocked safely.'**
  String get localUnlockFailureMessage;

  /// No description provided for @localUnlockRetryAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get localUnlockRetryAction;

  /// No description provided for @localUnlockPromptingLabel.
  ///
  /// In en, this message translates to:
  /// **'Waiting for verification'**
  String get localUnlockPromptingLabel;

  /// No description provided for @localUnlockUseLoginAction.
  ///
  /// In en, this message translates to:
  /// **'Log in with account instead'**
  String get localUnlockUseLoginAction;

  /// No description provided for @localUnlockSemanticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved session unlock screen'**
  String get localUnlockSemanticsLabel;

  /// No description provided for @localUnlockIconSemanticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Locked session'**
  String get localUnlockIconSemanticsLabel;

  /// No description provided for @localUnlockPromptProgressSemanticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Local verification in progress'**
  String get localUnlockPromptProgressSemanticsLabel;

  /// No description provided for @localUnlockSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Local unlock'**
  String get localUnlockSettingsTitle;

  /// No description provided for @localUnlockSettingsToggleLabel.
  ///
  /// In en, this message translates to:
  /// **'Use local unlock'**
  String get localUnlockSettingsToggleLabel;

  /// No description provided for @localUnlockSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Require biometric verification before restoring a saved session.'**
  String get localUnlockSettingsDescription;

  /// No description provided for @localUnlockSettingsFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to update local unlock settings.'**
  String get localUnlockSettingsFailureMessage;

  /// No description provided for @localUnlockEnableReason.
  ///
  /// In en, this message translates to:
  /// **'Verify to enable local unlock'**
  String get localUnlockEnableReason;

  /// No description provided for @authInvalidCredentialsMessage.
  ///
  /// In en, this message translates to:
  /// **'The account or password is incorrect.'**
  String get authInvalidCredentialsMessage;

  /// No description provided for @authLoginFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to log in. Please try again.'**
  String get authLoginFailureMessage;

  /// No description provided for @authRestoreFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to restore the previous session.'**
  String get authRestoreFailureMessage;

  /// No description provided for @authLogoutFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to log out. Please try again.'**
  String get authLogoutFailureMessage;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get otpTitle;

  /// No description provided for @otpInstruction.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to {destination}.'**
  String otpInstruction(String destination);

  /// No description provided for @otpCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get otpCodeLabel;

  /// No description provided for @otpVerifyAction.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerifyAction;

  /// No description provided for @otpVerifyingLabel.
  ///
  /// In en, this message translates to:
  /// **'Verifying'**
  String get otpVerifyingLabel;

  /// No description provided for @otpVerifyProgressSemanticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification progress'**
  String get otpVerifyProgressSemanticsLabel;

  /// No description provided for @otpResendAction.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get otpResendAction;

  /// No description provided for @otpResendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Resending code'**
  String get otpResendingLabel;

  /// No description provided for @otpResendCountdown.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String otpResendCountdown(int seconds);

  /// No description provided for @otpInvalidCodeMessage.
  ///
  /// In en, this message translates to:
  /// **'The verification code is incorrect.'**
  String get otpInvalidCodeMessage;

  /// No description provided for @otpInvalidCodeAttemptsMessage.
  ///
  /// In en, this message translates to:
  /// **'The code is incorrect. {attempts} attempts remaining.'**
  String otpInvalidCodeAttemptsMessage(int attempts);

  /// No description provided for @otpExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'This verification code has expired. Request a new code.'**
  String get otpExpiredMessage;

  /// No description provided for @otpTooManyAttemptsMessage.
  ///
  /// In en, this message translates to:
  /// **'Too many incorrect attempts. Request a new code.'**
  String get otpTooManyAttemptsMessage;

  /// No description provided for @otpResendCooldownMessage.
  ///
  /// In en, this message translates to:
  /// **'Please wait before requesting another code.'**
  String get otpResendCooldownMessage;

  /// No description provided for @otpInvalidatedMessage.
  ///
  /// In en, this message translates to:
  /// **'This verification request is no longer valid.'**
  String get otpInvalidatedMessage;

  /// No description provided for @otpGenericFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to verify the code. Please try again.'**
  String get otpGenericFailureMessage;

  /// No description provided for @profileUnauthenticatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get profileUnauthenticatedTitle;

  /// No description provided for @profileUnauthenticatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Log in to view the current account profile.'**
  String get profileUnauthenticatedMessage;

  /// No description provided for @profileLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading profile'**
  String get profileLoadingTitle;

  /// No description provided for @profileLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Retrieving the latest account information.'**
  String get profileLoadingMessage;

  /// No description provided for @profileLoadingProgressSemanticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile loading progress'**
  String get profileLoadingProgressSemanticsLabel;

  /// No description provided for @profileLoadFailureTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile'**
  String get profileLoadFailureTitle;

  /// No description provided for @profileLoadFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to load the profile. Please try again.'**
  String get profileLoadFailureMessage;

  /// No description provided for @profileSessionExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Your session is no longer valid. Please log in again.'**
  String get profileSessionExpiredMessage;

  /// No description provided for @profileLogoutFailureTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout failed'**
  String get profileLogoutFailureTitle;

  /// No description provided for @profileLogoutFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to log out. Please try again.'**
  String get profileLogoutFailureMessage;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileCurrentUser.
  ///
  /// In en, this message translates to:
  /// **'Current user: {name}'**
  String profileCurrentUser(String name);

  /// No description provided for @profileUnknownUserLabel.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get profileUnknownUserLabel;

  /// No description provided for @profileLogoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogoutLabel;

  /// No description provided for @profileLoggingOutLabel.
  ///
  /// In en, this message translates to:
  /// **'Logging out'**
  String get profileLoggingOutLabel;

  /// No description provided for @profileLogoutProgressSemanticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Logout progress'**
  String get profileLogoutProgressSemanticsLabel;

  /// No description provided for @protectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Protected Page'**
  String get protectedTitle;

  /// No description provided for @protectedAccessGrantedTitle.
  ///
  /// In en, this message translates to:
  /// **'Route Guard passed'**
  String get protectedAccessGrantedTitle;

  /// No description provided for @protectedAccessGrantedMessage.
  ///
  /// In en, this message translates to:
  /// **'This page is shown only after AuthGuard confirms a valid authenticated session.'**
  String get protectedAccessGrantedMessage;

  /// No description provided for @catalogSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search catalog'**
  String get catalogSearchLabel;

  /// No description provided for @catalogLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading catalog'**
  String get catalogLoadingTitle;

  /// No description provided for @catalogLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Fetching the latest catalog items.'**
  String get catalogLoadingMessage;

  /// No description provided for @catalogLoadingProgressSemanticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Catalog loading progress'**
  String get catalogLoadingProgressSemanticsLabel;

  /// No description provided for @catalogInitialFailureTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load catalog'**
  String get catalogInitialFailureTitle;

  /// No description provided for @catalogInitialFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to load the catalog. Please try again.'**
  String get catalogInitialFailureMessage;

  /// No description provided for @catalogEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No catalog items'**
  String get catalogEmptyTitle;

  /// No description provided for @catalogEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Try another search or pull to refresh.'**
  String get catalogEmptyMessage;

  /// No description provided for @catalogLoadingMoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading more'**
  String get catalogLoadingMoreLabel;

  /// No description provided for @catalogLoadMoreProgressSemanticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Catalog load more progress'**
  String get catalogLoadMoreProgressSemanticsLabel;

  /// No description provided for @catalogAppendFailureTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load more items'**
  String get catalogAppendFailureTitle;

  /// No description provided for @catalogAppendFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to load more catalog items. Please try again.'**
  String get catalogAppendFailureMessage;

  /// No description provided for @catalogRetryLoadMoreAction.
  ///
  /// In en, this message translates to:
  /// **'Retry load more'**
  String get catalogRetryLoadMoreAction;

  /// No description provided for @catalogRefreshFailureTitle.
  ///
  /// In en, this message translates to:
  /// **'Refresh failed'**
  String get catalogRefreshFailureTitle;

  /// No description provided for @catalogRefreshFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to refresh the catalog. Please try again.'**
  String get catalogRefreshFailureMessage;

  /// No description provided for @catalogCachedDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Showing cached data'**
  String get catalogCachedDataTitle;

  /// No description provided for @catalogStaleCacheTitle.
  ///
  /// In en, this message translates to:
  /// **'Showing stale cached data'**
  String get catalogStaleCacheTitle;

  /// No description provided for @catalogLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {value}'**
  String catalogLastUpdated(String value);

  /// No description provided for @catalogUpdatingCacheLabel.
  ///
  /// In en, this message translates to:
  /// **'Updating cached data'**
  String get catalogUpdatingCacheLabel;

  /// No description provided for @catalogRevalidationProgressSemanticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Catalog revalidation progress'**
  String get catalogRevalidationProgressSemanticsLabel;

  /// No description provided for @catalogRevalidationFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to update the cached catalog right now.'**
  String get catalogRevalidationFailureMessage;

  /// No description provided for @catalogRequestTimeoutMessage.
  ///
  /// In en, this message translates to:
  /// **'The catalog request timed out. Please try again.'**
  String get catalogRequestTimeoutMessage;

  /// No description provided for @catalogRateLimitedMessage.
  ///
  /// In en, this message translates to:
  /// **'Too many catalog requests. Please try again later.'**
  String get catalogRateLimitedMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
