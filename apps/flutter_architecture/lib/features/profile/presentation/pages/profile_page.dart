import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_architecture/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';

/// Profile 頁面。
///
/// ## 頁面行為
///
/// - 未登入：顯示尚未登入。
/// - 已登入：呼叫 GetProfileUseCase，顯示目前用戶名稱。
@RoutePage()
class ProfilePage extends HookWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = useBloc<AuthBloc>();
    final authState = useBlocBuilder(authBloc);

    final profileBloc = useBloc<ProfileBloc>();
    final profileState = useBlocBuilder(profileBloc);

    useEffect(
      () {
        if (authState.isAuthenticated) {
          profileBloc.add(const ProfileEvent.requested());
        }
        return null;
      },
      <Object?>[authState.user?.id],
    );

    if (!authState.isAuthenticated) {
      return const Center(
        child: Text('尚未登入'),
      );
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
          Text('目前登入用戶：${profile?.name ?? authState.user?.name ?? '未知'}'),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () {
              authBloc.add(const AuthEvent.logoutRequested());
              context.tabsRouter.setActiveIndex(0);
            },
            child: const Text('登出'),
          ),
        ],
      ),
    );
  }
}
