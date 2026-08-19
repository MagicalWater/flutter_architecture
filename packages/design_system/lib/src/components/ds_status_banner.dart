import 'package:design_system/src/theme/ds_semantic_colors.dart';
import 'package:design_system/src/tokens/ds_radius.dart';
import 'package:design_system/src/tokens/ds_space.dart';
import 'package:flutter/material.dart';

enum DsStatusTone { neutral, info, success, warning, error }

final class DsStatusBannerAction {
  const DsStatusBannerAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

/// 顯示非阻塞狀態、提示或可重試訊息的純 presentation primitive。
final class DsStatusBanner extends StatelessWidget {
  const DsStatusBanner({
    required this.tone,
    required this.title,
    this.message,
    this.icon,
    this.action,
    super.key,
  });

  final DsStatusTone tone;
  final String title;
  final String? message;
  final IconData? icon;
  final DsStatusBannerAction? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _BannerColors.resolve(theme, tone);
    final semanticsLabel = message == null ? title : '$title. $message';

    return Material(
      color: colors.container,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DsRadius.md),
      ),
      child: Padding(
        padding: EdgeInsets.all(DsSpace.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon ?? _defaultIcon(tone), color: colors.foreground),
            SizedBox(width: DsSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Semantics(
                    container: true,
                    label: semanticsLabel,
                    child: ExcludeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colors.foreground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (message != null) ...<Widget>[
                            SizedBox(height: DsSpace.xxs),
                            Text(
                              message!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.foreground,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (action != null) ...<Widget>[
                    SizedBox(height: DsSpace.xs),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: action!.onPressed,
                        style: TextButton.styleFrom(
                          foregroundColor: colors.foreground,
                        ),
                        child: Text(action!.label),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _defaultIcon(DsStatusTone tone) => switch (tone) {
    DsStatusTone.neutral => Icons.info_outline,
    DsStatusTone.info => Icons.info_outline,
    DsStatusTone.success => Icons.check_circle_outline,
    DsStatusTone.warning => Icons.warning_amber_outlined,
    DsStatusTone.error => Icons.error_outline,
  };
}

final class _BannerColors {
  const _BannerColors({required this.container, required this.foreground});

  final Color container;
  final Color foreground;

  static _BannerColors resolve(ThemeData theme, DsStatusTone tone) {
    final scheme = theme.colorScheme;
    final semantic = theme.extension<DsSemanticColors>();

    return switch (tone) {
      DsStatusTone.neutral => _BannerColors(
        container: scheme.surfaceContainerHigh,
        foreground: scheme.onSurface,
      ),
      DsStatusTone.info => _BannerColors(
        container: semantic?.infoContainer ?? scheme.secondaryContainer,
        foreground: semantic?.onInfoContainer ?? scheme.onSecondaryContainer,
      ),
      DsStatusTone.success => _BannerColors(
        container: semantic?.successContainer ?? scheme.primaryContainer,
        foreground: semantic?.onSuccessContainer ?? scheme.onPrimaryContainer,
      ),
      DsStatusTone.warning => _BannerColors(
        container: semantic?.warningContainer ?? scheme.tertiaryContainer,
        foreground: semantic?.onWarningContainer ?? scheme.onTertiaryContainer,
      ),
      DsStatusTone.error => _BannerColors(
        container: scheme.errorContainer,
        foreground: scheme.onErrorContainer,
      ),
    };
  }
}
