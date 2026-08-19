import 'package:auto_route/auto_route.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.protectedTitle)),
      body: DsMessageState(
        title: l10n.protectedAccessGrantedTitle,
        message: l10n.protectedAccessGrantedMessage,
        icon: Icon(Icons.verified_user_outlined, size: DsIconSize.hero),
      ),
    );
  }
}
