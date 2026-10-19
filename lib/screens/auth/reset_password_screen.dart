import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../services/auth_service.dart';

const _bg = Color(0xFF071B14);
const _emerald = Color(0xFF60E0A0);
const _mint = Color(0xFFCCF7DE);

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;
  bool _hasToken = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _authService = const AuthService(apiClient: ApiClient());

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_isSubmitting) return;

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Enter the email associated with your account.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final result = await _authService.requestPasswordReset(email);
      if (!mounted) return;
      _showMessage(
        result['message']?.toString() ??
            'If an account exists for that email, a reset link has been sent.',
      );
      final resetToken = result['reset_token']?.toString();
      if (resetToken != null && resetToken.isNotEmpty) {
        _tokenController.text = resetToken;
        setState(() => _hasToken = true);
      }
    } catch (error) {
      _showMessage('Could not request a reset link: $error');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _confirmReset() async {
    if (_isSubmitting) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final result = await _authService.confirmPasswordReset(
        token: _tokenController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      _showMessage(result['message']?.toString() ?? 'Password updated.');
      setState(() => _hasToken = false);
      _tokenController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    } catch (error) {
      _showMessage('Could not update your password: $error');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF12372E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF071B14),
              Color(0xFF0B221C),
              Color(0xFF0D1919),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(28, 22, 28, 26),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 32,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Reset your password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'We’ll send a secure reset link to the email address linked to your account.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13.5,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'EMAIL',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: _emerald,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined, color: Colors.white60, size: 17),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.18),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: _emerald.withOpacity(0.75), width: 1.4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_hasToken) ...[
                        _ResetField(
                          label: 'RESET TOKEN',
                          controller: _tokenController,
                          icon: Icons.key_outlined,
                        ),
                        const SizedBox(height: 16),
                        _ResetField(
                          label: 'NEW PASSWORD',
                          controller: _passwordController,
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.white60,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ResetField(
                          label: 'CONFIRM PASSWORD',
                          controller: _confirmPasswordController,
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.white60,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _isSubmitting ? null : (_hasToken ? _confirmReset : _resetPassword),
                          style: FilledButton.styleFrom(
                            backgroundColor: _emerald,
                            foregroundColor: _bg,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(_bg),
                                  ),
                                )
                                : Text(
                                  _hasToken ? 'Update password' : 'Send reset link',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Back to Sign in',
                            style: TextStyle(
                              color: _mint,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResetField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;

  const _ResetField({
    required this.label,
    required this.controller,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          cursorColor: _emerald,
          style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white60, size: 17),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.black.withOpacity(0.18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.12))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.12))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _emerald.withOpacity(0.75), width: 1.4)),
          ),
        ),
      ],
    );
  }
}
