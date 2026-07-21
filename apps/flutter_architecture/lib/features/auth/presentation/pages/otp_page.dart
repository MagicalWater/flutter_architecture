import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_architecture/features/auth/presentation/auth_failure_localization.dart';
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';

@RoutePage()
class OtpPage extends HookWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final codeController = useTextEditingController();
    final authBloc = useBloc<AuthBloc>();
    final state = useBlocBuilder(authBloc);
    final challenge = state.otpChallenge;

    return OtpView(
      codeController: codeController,
      maskedDestination: challenge?.maskedDestination ?? '',
      resendAvailableAt: challenge?.resendAvailableAt,
      isVerifying: state.status == AuthPresentationStatus.verifying,
      isResending: state.status == AuthPresentationStatus.resending,
      failureMessage: state.failure != null && state.failureOperation != null
          ? localizedAuthFailure(
              AppLocalizations.of(context),
              failure: state.failure!,
              operation: state.failureOperation!,
            )
          : null,
      onVerify: () =>
          authBloc.add(AuthEvent.otpVerifyRequested(code: codeController.text)),
      onResend: () => authBloc.add(const AuthEvent.otpResendRequested()),
    );
  }
}

final class OtpView extends StatefulWidget {
  const OtpView({
    required this.codeController,
    required this.maskedDestination,
    required this.resendAvailableAt,
    required this.isVerifying,
    required this.isResending,
    required this.onVerify,
    required this.onResend,
    this.failureMessage,
    this.now = DateTime.now,
    super.key,
  });

  final TextEditingController codeController;
  final String maskedDestination;
  final DateTime? resendAvailableAt;
  final bool isVerifying;
  final bool isResending;
  final String? failureMessage;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final DateTime Function() now;

  @override
  State<OtpView> createState() => _OtpViewState();
}

final class _OtpViewState extends State<OtpView> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  int get _remainingSeconds {
    final retryAt = widget.resendAvailableAt;
    if (retryAt == null) return 0;
    final seconds = retryAt.difference(widget.now().toUtc()).inSeconds;
    return seconds > 0 ? seconds : 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = widget.isVerifying || widget.isResending;
    final canResend = !busy && _remainingSeconds == 0;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.otpTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: DsConstrainedContent(
            maxWidth: 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  l10n.otpInstruction(widget.maskedDestination),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DsSpace.xl),
                TextField(
                  key: const ValueKey('otpCodeField'),
                  controller: widget.codeController,
                  keyboardType: TextInputType.number,
                  autofillHints: const <String>[AutofillHints.oneTimeCode],
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  textInputAction: TextInputAction.done,
                  onSubmitted: busy ? null : (_) => widget.onVerify(),
                  decoration: InputDecoration(labelText: l10n.otpCodeLabel),
                ),
                const SizedBox(height: DsSpace.lg),
                if (widget.failureMessage != null) ...<Widget>[
                  Text(
                    widget.failureMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: DsSpace.md),
                ],
                FilledButton(
                  onPressed: busy ? null : widget.onVerify,
                  child: DsButtonContent(
                    label: widget.isVerifying
                        ? l10n.otpVerifyingLabel
                        : l10n.otpVerifyAction,
                    isLoading: widget.isVerifying,
                    progressSemanticsLabel:
                        l10n.otpVerifyProgressSemanticsLabel,
                  ),
                ),
                const SizedBox(height: DsSpace.md),
                TextButton(
                  onPressed: canResend ? widget.onResend : null,
                  child: Text(
                    widget.isResending
                        ? l10n.otpResendingLabel
                        : _remainingSeconds > 0
                        ? l10n.otpResendCountdown(_remainingSeconds)
                        : l10n.otpResendAction,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
