import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../cubits/email_monitor/email_monitor_cubit.dart';
import '../cubits/email_monitor/email_monitor_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.initialEmail,
    this.errorMessage,
  });

  final String? initialEmail;
  final String? errorMessage;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passCtrl;
  String? _statusMessage;
  bool _isError = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail ?? '');
    _passCtrl = TextEditingController();
    if (widget.errorMessage != null) {
      _statusMessage = widget.errorMessage;
      _isError = true;
    }
    _emailCtrl.addListener(_clearErrorOnEdit);
    _passCtrl.addListener(_clearErrorOnEdit);
  }

  void _clearErrorOnEdit() {
    if (_isError && _statusMessage != null) {
      debugPrint('[Settings] Error cleared — user started editing a field');
      setState(() {
        _statusMessage = null;
        _isError = false;
      });
    }
  }

  @override
  void didUpdateWidget(SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorMessage != null &&
        widget.errorMessage != oldWidget.errorMessage) {
      setState(() {
        _statusMessage = widget.errorMessage;
        _isError = true;
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _connect() {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      debugPrint('[Settings] Connect tapped with empty fields');
      setState(() {
        _statusMessage = AppStrings.emptyFieldsError;
        _isError = true;
      });
      return;
    }
    debugPrint('[Settings] Connect tapped — verifying credentials');
    setState(() {
      _isVerifying = true;
      _statusMessage = null;
      _isError = false;
    });
    context.read<EmailMonitorCubit>().verifyAndStart(email, pass);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EmailMonitorCubit, EmailMonitorState>(
      listener: (context, state) {
        switch (state) {
          case EmailMonitorError(:final message):
            setState(() {
              _statusMessage = message;
              _isError = true;
              _isVerifying = false;
            });
          default:
            break;
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: AppColors.settingsBackground,
            padding: const EdgeInsets.all(AppDimensions.settingsPadding),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    AppStrings.settingsTitle,
                    style: AppTextStyles.settingsTitle,
                  ),
                  const SizedBox(height: AppDimensions.settingsTitleGap),
                  _FormField(
                    controller: _emailCtrl,
                    label: AppStrings.gmailAddressLabel,
                    hint: AppStrings.gmailAddressHint,
                  ),
                  const SizedBox(height: AppDimensions.fieldGap),
                  _FormField(
                    controller: _passCtrl,
                    label: AppStrings.appPasswordLabel,
                    hint: AppStrings.appPasswordHint,
                    obscure: true,
                  ),
                  const SizedBox(height: AppDimensions.fieldToButtonGap),
                  FilledButton(
                    onPressed: _isVerifying ? null : _connect,
                    child: _isVerifying
                        ? const SizedBox(
                            height: AppDimensions.spinnerSize,
                            width: AppDimensions.spinnerSize,
                            child: CircularProgressIndicator(
                              strokeWidth: AppDimensions.spinnerStroke,
                              color: AppColors.fieldText,
                            ),
                          )
                        : const Text(AppStrings.connect),
                  ),
                  if (_statusMessage != null) ...[
                    const SizedBox(height: AppDimensions.statusGap),
                    Text(
                      _statusMessage!,
                      style: AppTextStyles.statusMessage(_isError),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            top: AppDimensions.quitButtonInset,
            right: AppDimensions.quitButtonInset,
            child: IconButton(
              onPressed: () => exit(0),
              tooltip: AppStrings.quitTooltip,
              icon: const Icon(
                Icons.close,
                color: AppColors.iconMuted,
                size: AppDimensions.iconSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatefulWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.obscure = false,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscure;

  @override
  State<_FormField> createState() => _FormFieldState();
}

class _FormFieldState extends State<_FormField> {
  late bool _obscured = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: AppDimensions.fieldLabelGap),
        TextField(
          controller: widget.controller,
          obscureText: _obscured,
          style: AppTextStyles.fieldInput,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.fieldHint,
            filled: true,
            fillColor: AppColors.fieldFill,
            suffixIcon: widget.obscure
                ? IconButton(
                    splashRadius: AppDimensions.iconSplashRadius,
                    tooltip: _obscured
                        ? AppStrings.showPassword
                        : AppStrings.hidePassword,
                    icon: Icon(
                      _obscured ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.iconMuted,
                      size: AppDimensions.iconSize,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.fieldRadius),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.fieldRadius),
              borderSide: const BorderSide(
                color: AppColors.fieldFocusBorder,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.fieldContentPaddingH,
              vertical: AppDimensions.fieldContentPaddingV,
            ),
          ),
        ),
      ],
    );
  }
}
