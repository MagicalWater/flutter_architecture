import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/router/app_router.dart';
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_architecture/features/shell/presentation/shell_tab.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';

/// Login 頁面。
///
/// ## 為什麼使用 HookWidget？
///
/// 帳號與密碼欄位需要 `TextEditingController`。
///
/// 如果使用 StatefulWidget，需要手動 init/dispose。
/// flutter_hooks 可以把這類 UI 暫態變得更簡潔。
@RoutePage()
class LoginPage extends HookWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accountController = useTextEditingController(text: 'demo');
    final passwordController = useTextEditingController(text: 'password');

    // hooked_bloc 用來降低 BlocBuilder / BlocListener 的巢狀。
    // Bloc 仍然是業務狀態來源，Hook 只負責 UI 綁定。
    final authBloc = useBloc<AuthBloc>();
    final authState = useBlocBuilder(authBloc);

    useBlocListener<AuthBloc, AuthState>(authBloc, (_, state, _) {
      if (state.isAuthenticated) {
        context.tabsRouter.setActiveIndex(ShellTab.profile.index);
      }
    });

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Login Page',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: accountController,
                  decoration: const InputDecoration(
                    labelText: 'Account',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                if (authState.errorMessage != null) ...<Widget>[
                  Text(
                    authState.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                FilledButton(
                  onPressed: authState.isLoading
                      ? null
                      : () {
                          authBloc.add(
                            AuthEvent.loginRequested(
                              account: accountController.text,
                              password: passwordController.text,
                            ),
                          );
                        },
                  child: authState.isLoading
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('登入'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.pushRoute(const ProtectedRoute()),
                  child: const Text('嘗試進入需要登入的頁面'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
