import 'package:auto_route/auto_route.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// ProtectedPage，也就是需求中的 D 頁面。
///
/// ## 行為
///
/// 這個頁面需要登入才能進入。
///
/// 檢查邏輯不放在頁面裡，而是放在 AuthGuard。
/// 頁面不讀取 SessionManager，也不依賴 DI container。
/// 頁面只負責顯示內容。
@RoutePage()
class ProtectedPage extends StatelessWidget {
  const ProtectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Protected Page')),
      body: const DsMessageState(
        title: '你已通過 Route Guard',
        message: '此頁面只會在 AuthGuard 確認目前已有有效登入 Session 後顯示。',
        icon: Icon(Icons.verified_user_outlined, size: DsIconSize.hero),
      ),
    );
  }
}
