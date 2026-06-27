import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:auth/auth.dart';
import 'package:flutter_architecture/app/di/injection.dart';

/// ProtectedPage，也就是需求中的 D 頁面。
///
/// ## 行為
///
/// 這個頁面需要登入才能進入。
///
/// 檢查邏輯不放在頁面裡，而是放在 AuthGuard。
/// 頁面只負責顯示內容。
@RoutePage()
class ProtectedPage extends StatelessWidget {
  const ProtectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = getIt<SessionManager>().currentSession;

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
            Text('目前登入用戶 ID：${session?.userId ?? '未知'}'),
          ],
        ),
      ),
    );
  }
}
