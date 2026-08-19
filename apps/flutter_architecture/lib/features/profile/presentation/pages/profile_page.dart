import 'package:auto_route/auto_route.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/profile/domain/entities/profile.dart';
import 'package:flutter_architecture/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_architecture/features/profile/presentation/profile_failure_localization.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';

/// Profile 頁面。
///
/// ## 頁面行為
///
/// - 未登入：顯示尚未登入。
/// - 已登入：呼叫 GetProfileUseCase，顯示目前用戶名稱。
///
/// ProfilePage 不直接讀 AuthBloc。
/// 跨 feature 的登入狀態由 ProfileBloc 透過 SessionManager 判斷。
@RoutePage()
class ProfilePage extends HookWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileBloc = useBloc<ProfileBloc>();
    final profileState = useBlocBuilder(profileBloc);
    final l10n = AppLocalizations.of(context);

    useEffect(() {
      profileBloc.add(const ProfileEvent.requested());
      return null;
    }, const <Object?>[]);

    return ProfileView(
      isAuthenticated: profileState.isAuthenticated,
      isLoading: profileState.isLoading,
      failureMessage:
          profileState.failure != null && profileState.failureOperation != null
          ? localizedProfileFailure(
              l10n,
              failure: profileState.failure!,
              operation: profileState.failureOperation!,
            )
          : null,
      failureOperation: profileState.failureOperation,
      profile: profileState.profile,
      onRetry: () => profileBloc.add(const ProfileEvent.requested()),
      onLogout: () => profileBloc.add(const ProfileEvent.logoutRequested()),
    );
  }
}

final class ProfileView extends StatelessWidget {
  const ProfileView({
    required this.isAuthenticated,
    required this.isLoading,
    required this.onRetry,
    required this.onLogout,
    this.failureMessage,
    this.failureOperation,
    this.profile,
    super.key,
  });

  final bool isAuthenticated;
  final bool isLoading;
  final String? failureMessage;
  final ProfileFailureOperation? failureOperation;
  final Profile? profile;
  final VoidCallback onRetry;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!isAuthenticated) {
      return DsMessageState(
        title: l10n.profileUnauthenticatedTitle,
        message: l10n.profileUnauthenticatedMessage,
        icon: Icon(Icons.person_off_outlined, size: DsIconSize.hero),
      );
    }

    if (isLoading && profile == null) {
      return DsLoadingState(
        title: l10n.profileLoadingTitle,
        message: l10n.profileLoadingMessage,
        progressSemanticsLabel: l10n.profileLoadingProgressSemanticsLabel,
      );
    }

    if (failureMessage != null && profile == null) {
      return DsBlockingErrorState(
        title: l10n.profileLoadFailureTitle,
        message: failureMessage,
        primaryAction: DsPageStateAction(
          label: l10n.commonRetryAction,
          onPressed: onRetry,
        ),
      );
    }

    return DsConstrainedContent(
      maxWidth: 560,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (failureMessage != null &&
              failureOperation == ProfileFailureOperation.logout) ...<Widget>[
            DsStatusBanner(
              tone: DsStatusTone.error,
              title: l10n.profileLogoutFailureTitle,
              message: failureMessage!,
            ),
            SizedBox(height: DsSpace.lg),
          ],
          Text(
            l10n.profileTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: DsSpace.lg),
          Text(
            l10n.profileCurrentUser(
              profile?.name ?? l10n.profileUnknownUserLabel,
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: DsSpace.lg),
          FilledButton.tonal(
            onPressed: isLoading ? null : onLogout,
            child: DsButtonContent(
              label: isLoading
                  ? l10n.profileLoggingOutLabel
                  : l10n.profileLogoutLabel,
              isLoading: isLoading,
              progressSemanticsLabel: l10n.profileLogoutProgressSemanticsLabel,
            ),
          ),
        ],
      ),
    );
  }
}
