import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/pages/write_precheck_view.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/write_precheck_copy.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';

@RoutePage()
class WritePrecheckPage extends StatelessWidget {
  const WritePrecheckPage({super.key});

  @override
  Widget build(BuildContext context) => WritePrecheckView(
    copy: WritePrecheckCopy.from(AppLocalizations.of(context)),
  );
}
