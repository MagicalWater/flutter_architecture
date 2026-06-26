import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';

/// ProtectedPage，也就是需求中的 D 頁面。
///
/// ## 行為
///
/// 這個頁面需要登入才能進入。
///
/// 檢查邏輯不放在頁面裡，而是放在 AuthGuard。
/// 頁面只負責顯示內容。
@RoutePage()
class ProtectedPage extends HookWidget {
  const ProtectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = useBloc<AuthBloc>();
    final authState = useBlocBuilder(authBloc);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Protected Page'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.verified_user_outlined, size: 64),
            const SizedBox(height: 16),
            const Text(
              '你已通過 Route Guard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('目前登入用戶：${user?.name ?? '未知'}'),
          ],
        ),
      ),
    );
  }
}
