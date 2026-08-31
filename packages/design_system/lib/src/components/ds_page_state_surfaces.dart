import 'package:design_system/src/tokens/ds_icon_size.dart';
import 'package:design_system/src/tokens/ds_space.dart';
import 'package:flutter/material.dart';

final class DsPageStateAction {
  const DsPageStateAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

final class DsLoadingState extends StatelessWidget {
  const DsLoadingState({
    required this.title,
    required this.progressSemanticsLabel,
    this.message,
    super.key,
  });

  final String title;
  final String? message;
  final String progressSemanticsLabel;

  @override
  Widget build(BuildContext context) {
    return _DsPageStateLayout(
      leading: Semantics(
        label: progressSemanticsLabel,
        child: const ExcludeSemantics(child: CircularProgressIndicator()),
      ),
      title: title,
      message: message,
    );
  }
}

final class DsEmptyState extends StatelessWidget {
  const DsEmptyState({
    required this.title,
    this.message,
    this.icon,
    this.primaryAction,
    this.secondaryAction,
    this.scrollable = true,
    super.key,
  });

  final String title;
  final String? message;
  final Widget? icon;
  final DsPageStateAction? primaryAction;
  final DsPageStateAction? secondaryAction;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return _DsPageStateLayout(
      leading: icon ?? Icon(Icons.inbox_outlined, size: DsIconSize.hero),
      title: title,
      message: message,
      primaryAction: primaryAction,
      secondaryAction: secondaryAction,
      scrollable: scrollable,
    );
  }
}

final class DsBlockingErrorState extends StatelessWidget {
  const DsBlockingErrorState({
    required this.title,
    this.message,
    this.icon,
    this.primaryAction,
    this.secondaryAction,
    super.key,
  });

  final String title;
  final String? message;
  final Widget? icon;
  final DsPageStateAction? primaryAction;
  final DsPageStateAction? secondaryAction;

  @override
  Widget build(BuildContext context) {
    final label = message == null ? title : '$title. $message';
    return _DsPageStateLayout(
      leading:
          icon ??
          Icon(
            Icons.error_outline,
            size: DsIconSize.hero,
            color: Theme.of(context).colorScheme.error,
          ),
      title: title,
      message: message,
      primaryAction: primaryAction,
      secondaryAction: secondaryAction,
      contentSemanticsLabel: label,
    );
  }
}

final class DsMessageState extends StatelessWidget {
  const DsMessageState({
    required this.title,
    this.message,
    this.icon,
    this.primaryAction,
    this.secondaryAction,
    super.key,
  });

  final String title;
  final String? message;
  final Widget? icon;
  final DsPageStateAction? primaryAction;
  final DsPageStateAction? secondaryAction;

  @override
  Widget build(BuildContext context) {
    return _DsPageStateLayout(
      leading: icon ?? Icon(Icons.info_outline, size: DsIconSize.hero),
      title: title,
      message: message,
      primaryAction: primaryAction,
      secondaryAction: secondaryAction,
    );
  }
}

final class _DsPageStateLayout extends StatelessWidget {
  const _DsPageStateLayout({
    required this.leading,
    required this.title,
    this.message,
    this.primaryAction,
    this.secondaryAction,
    this.contentSemanticsLabel,
    this.scrollable = true,
  });

  final Widget leading;
  final String title;
  final String? message;
  final DsPageStateAction? primaryAction;
  final DsPageStateAction? secondaryAction;
  final String? contentSemanticsLabel;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    if (!scrollable) {
      return Padding(
        padding: EdgeInsets.all(DsSpace.lg),
        child: Center(child: _buildContent()),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(DsSpace.lg),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.hasBoundedHeight
                  ? (constraints.maxHeight - DsSpace.lg * 2).clamp(
                      0,
                      double.infinity,
                    )
                  : 0,
            ),
            child: Center(child: _buildContent()),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _PageStateContent(
            leading: leading,
            title: title,
            message: message,
            semanticsLabel: contentSemanticsLabel,
          ),
          if (primaryAction != null || secondaryAction != null) ...<Widget>[
            SizedBox(height: DsSpace.lg),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: DsSpace.sm,
              runSpacing: DsSpace.xs,
              children: <Widget>[
                if (primaryAction != null)
                  FilledButton(
                    onPressed: primaryAction!.onPressed,
                    child: Text(primaryAction!.label),
                  ),
                if (secondaryAction != null)
                  OutlinedButton(
                    onPressed: secondaryAction!.onPressed,
                    child: Text(secondaryAction!.label),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

final class _PageStateContent extends StatelessWidget {
  const _PageStateContent({
    required this.leading,
    required this.title,
    this.message,
    this.semanticsLabel,
  });

  final Widget leading;
  final String title;
  final String? message;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        leading,
        SizedBox(height: DsSpace.md),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        if (message != null) ...<Widget>[
          SizedBox(height: DsSpace.xs),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ],
    );

    if (semanticsLabel == null) {
      return content;
    }

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: ExcludeSemantics(child: content),
    );
  }
}
