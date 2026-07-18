import 'package:auto_route/auto_route.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/profile/domain/entities/profile.dart';
import 'package:flutter_architecture/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_architecture/features/shell/presentation/shell_tab.dart';
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

    useEffect(() {
      profileBloc.add(const ProfileEvent.requested());
      return null;
    }, const <Object?>[]);

    useBlocListener<ProfileBloc, ProfileState>(profileBloc, (_, state, _) {
      if (state.logoutSucceeded) {
        context.tabsRouter.setActiveIndex(ShellTab.login.index);
      }
    });

    return ProfileView(
      isAuthenticated: profileState.isAuthenticated,
      isLoading: profileState.isLoading,
      errorMessage: profileState.errorMessage,
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
    this.errorMessage,
    this.profile,
    super.key,
  });

  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final Profile? profile;
  final VoidCallback onRetry;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    if (!isAuthenticated) {
      return const DsMessageState(
        title: '尚未登入',
        message: '登入後即可查看目前帳號的個人資料。',
        icon: Icon(Icons.person_off_outlined, size: DsIconSize.hero),
      );
    }

    if (isLoading && profile == null) {
      return const DsLoadingState(
        title: '載入個人資料',
        message: '正在取得最新的帳號資訊。',
        progressSemanticsLabel: '個人資料載入進度',
      );
    }

    if (errorMessage != null && profile == null) {
      return DsBlockingErrorState(
        title: '無法載入個人資料',
        message: errorMessage,
        primaryAction: DsPageStateAction(label: '重試', onPressed: onRetry),
      );
    }

    return DsConstrainedContent(
      maxWidth: 560,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (errorMessage != null) ...<Widget>[
            DsStatusBanner(
              tone: DsStatusTone.error,
              title: '登出失敗',
              message: errorMessage!,
            ),
            const SizedBox(height: DsSpace.lg),
          ],
          Text(
            'Profile Page',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: DsSpace.lg),
          Text(
            '目前登入用戶：${profile?.name ?? '未知'}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: DsSpace.lg),
          FilledButton.tonal(
            onPressed: isLoading ? null : onLogout,
            child: DsButtonContent(
              label: isLoading ? '登出中' : '登出',
              isLoading: isLoading,
              progressSemanticsLabel: '登出進度',
            ),
          ),
        ],
      ),
    );
  }
}
