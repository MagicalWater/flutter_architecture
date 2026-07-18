import 'package:auto_route/auto_route.dart';
import 'package:design_system/design_system.dart';
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

    return LoginView(
      accountController: accountController,
      passwordController: passwordController,
      isLoading: authState.isLoading,
      errorMessage: authState.errorMessage,
      onLogin: () {
        authBloc.add(
          AuthEvent.loginRequested(
            account: accountController.text,
            password: passwordController.text,
          ),
        );
      },
      onOpenProtected: () => context.pushRoute(const ProtectedRoute()),
    );
  }
}

final class LoginView extends StatelessWidget {
  const LoginView({
    required this.accountController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
    required this.onOpenProtected,
    this.errorMessage,
    super.key,
  });

  final TextEditingController accountController;
  final TextEditingController passwordController;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onLogin;
  final VoidCallback onOpenProtected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: DsConstrainedContent(
            maxWidth: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Login Page',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: DsSpace.xl),
                TextField(
                  controller: accountController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Account'),
                ),
                const SizedBox(height: DsSpace.md),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: isLoading ? null : (_) => onLogin(),
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: DsSpace.lg),
                if (errorMessage != null) ...<Widget>[
                  Text(
                    errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: DsSpace.md),
                ],
                FilledButton(
                  onPressed: isLoading ? null : onLogin,
                  child: DsButtonContent(
                    label: isLoading ? '登入中' : '登入',
                    isLoading: isLoading,
                    progressSemanticsLabel: '登入進度',
                  ),
                ),
                const SizedBox(height: DsSpace.md),
                OutlinedButton(
                  onPressed: onOpenProtected,
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
