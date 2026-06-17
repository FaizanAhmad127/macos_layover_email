import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/credentials/credentials_cubit.dart';
import '../cubits/credentials/credentials_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.initialEmail, this.errorMessage});

  final String? initialEmail;

  /// Pre-displayed error (e.g. shown when reopened after an auth failure).
  final String? errorMessage;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passCtrl;
  String? _statusMessage;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail ?? '');
    _passCtrl = TextEditingController();
    if (widget.errorMessage != null) {
      _statusMessage = widget.errorMessage;
      _isError = true;
    }
  }

  @override
  void didUpdateWidget(SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Surface a new error if the screen is reused while already mounted.
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

  void _save() {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() {
        _statusMessage = 'Email and app password are required.';
        _isError = true;
      });
      return;
    }
    context.read<CredentialsCubit>().save(email, pass);
  }

  void _clear() => context.read<CredentialsCubit>().clear();

  @override
  Widget build(BuildContext context) {
    return BlocListener<CredentialsCubit, CredentialsState>(
      listener: (context, state) {
        switch (state) {
          case CredentialsSaved():
            setState(() {
              _statusMessage = 'Saved — connecting to Gmail…';
              _isError = false;
              _passCtrl.clear();
            });
          case CredentialsCleared():
            setState(() {
              _emailCtrl.clear();
              _passCtrl.clear();
              _statusMessage = 'Credentials cleared.';
              _isError = false;
            });
          case CredentialsError(:final message):
            setState(() {
              _statusMessage = message;
              _isError = true;
            });
          default:
            break;
        }
      },
      child: Container(
        color: const Color(0xFF1E1E1E),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            const Text(
              'Gmail Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _FormField(
              controller: _emailCtrl,
              label: 'Gmail address',
              hint: 'you@gmail.com',
            ),
            const SizedBox(height: 12),
            _FormField(
              controller: _passCtrl,
              label: 'App password',
              hint: '16-character app password',
              obscure: true,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: _clear,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[300],
                    side: BorderSide(color: Colors.red[300]!),
                  ),
                  child: const Text('Clear'),
                ),
              ],
            ),
              if (_statusMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _statusMessage!,
                  style: TextStyle(
                    color: _isError ? Colors.red[300] : Colors.green[300],
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
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

  /// When true the field starts obscured and shows a show/hide eye toggle.
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
        Text(
          widget.label,
          style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 12),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: widget.controller,
          obscureText: _obscured,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: Color(0xFF555555)),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            suffixIcon: widget.obscure
                ? IconButton(
                    splashRadius: 18,
                    tooltip: _obscured ? 'Show password' : 'Hide password',
                    icon: Icon(
                      _obscured ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF999999),
                      size: 18,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF4A90D9), width: 1),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}
