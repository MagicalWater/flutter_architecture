import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
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

    if (!profileState.isAuthenticated) {
      return const Center(child: Text('尚未登入'));
    }

    if (profileState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profileState.errorMessage != null) {
      return Center(child: Text(profileState.errorMessage!));
    }

    final profile = profileState.profile;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'Profile Page',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text('目前登入用戶：${profile?.name ?? '未知'}'),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () {
              profileBloc.add(const ProfileEvent.logoutRequested());
            },
            child: const Text('登出'),
          ),
        ],
      ),
    );
  }
}
