import 'dart:ui';

import 'package:flutter/material.dart';

import '../auth/reset_password_screen.dart';
import '../auth/sign_up_screen.dart';
import '../dashboard/dashboard_screen.dart';
import 'top_glass_bar.dart';

import '../../core/api/api_client.dart';
import '../../core/storage/auth_storage.dart';
import '../../services/auth_service.dart';

const _deepForest = Color(0xFF071B14);
const _emerald = Color(0xFF55D39B);
const _mint = Color(0xFFB8F5D8);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  bool keepSignedIn = true;
  bool obscurePassword = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();

    emailController = TextEditingController(
      text: 'admin@seqotia.com',
    );

    passwordController = TextEditingController(
      text: 'admin123',
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ======================================================================
  // LOGIN
  // ======================================================================

  final AuthService _authService = const AuthService(
    apiClient: ApiClient(),
  );

  Future<void> _login() async {
    if (isSubmitting) return;

    setState(() => isSubmitting = true);

    try {
      final result = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final token = result['token'] as String?;
      final user = result['user'] as Map<String, dynamic>?;

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token missing from response.');
      }

      await AuthStorage.saveToken(
        token,
        rememberMe: keepSignedIn,
        userEmail: user?['email'] as String?,
        userName: user?['name'] as String?,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
      );
    } catch (e) {
      debugPrint('Login error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  // ======================================================================
  // BUILD
  // ======================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepForest,
      body: Stack(
        children: [
          // ==============================================================
          // BACKGROUND
          // ==============================================================

          const Positioned.fill(
            child: _LuxuryForestBackground(),
          ),

          // ==============================================================
          // TOP GLASS BAR
          // ==============================================================

          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TopGlassBar(
              userName: 'Welcome!',
              status: 'Not signed in',
            ),
          ),

          // ==============================================================
          // LOGIN CONTENT
          // ==============================================================

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  108,
                  24,
                  40,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 430,
                  ),
                  child: _LoginGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 28),

                        // ==================================================
                        // BRAND
                        // ==================================================

                        const _BrandHeader(),

                        const SizedBox(height: 38),

                        // ==================================================
                        // TITLE
                        // ==================================================

                        const Text(
                          'Welcome back',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.9,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Your intelligent document workspace is ready.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13.5,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ==================================================
                        // EMAIL
                        // ==================================================

                        _LoginField(
                          label: 'EMAIL',
                          controller: emailController,
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 18),

                        // ==================================================
                        // PASSWORD
                        // ==================================================

                        _LoginField(
                          label: 'PASSWORD',
                          controller: passwordController,
                          icon: Icons.lock_outline_rounded,
                          obscureText: obscurePassword,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.white60,
                              size: 18,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ==================================================
                        // OPTIONS
                        // ==================================================

                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: _LoginOptions(
                            keepSignedIn: keepSignedIn,
                            onKeepSignedInChanged: (value) {
                              setState(() {
                                keepSignedIn = value;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 26),

                        // ==================================================
                        // SIGN IN BUTTON
                        // ==================================================

                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeInOut,
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            onPressed: isSubmitting ? null : _login,
                            style: FilledButton.styleFrom(
                              backgroundColor: _mint,
                              foregroundColor: _deepForest,
                              elevation: 0,
                              shadowColor: _mint.withValues(alpha: .35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _deepForest,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Sign in to Seqotia',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ==================================================
                        // SIGN UP
                        // ==================================================

                        _SignUpText(
                          onSignUp: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SignUpScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        // ==================================================
                        // SECURITY
                        // ==================================================

                        const _SecurityStatus(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================================================
// BRAND HEADER
// ========================================================================

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: .10),
            boxShadow: [
              BoxShadow(
                color: _emerald.withValues(alpha: .10),
                blurRadius: 20,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/ICONWITHNOBACKGROUND.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons.eco_rounded,
                  color: _mint,
                  size: 34,
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SEQOTIA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.2,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Work faster. Documents, simplified.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ========================================================================
// LOGIN OPTIONS
// ========================================================================

class _LoginOptions extends StatelessWidget {
  final bool keepSignedIn;
  final ValueChanged<bool> onKeepSignedInChanged;

  const _LoginOptions({
    required this.keepSignedIn,
    required this.onKeepSignedInChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: keepSignedIn,
            onChanged: (value) {
              onKeepSignedInChanged(
                value ?? false,
              );
            },
            activeColor: _emerald,
            checkColor: _deepForest,
            side: BorderSide(
              color: Colors.white.withValues(
                alpha: .35,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Keep me signed in',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ResetPasswordScreen(),
              ),
            );
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
          ),
          child: const Text(
            'Forgot password?',
            style: TextStyle(
              color: _mint,
              fontSize: 12.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ========================================================================
// SIGN UP
// ========================================================================

class _SignUpText extends StatelessWidget {
  final VoidCallback onSignUp;

  const _SignUpText({
    required this.onSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          const Text(
            "Don't have an account? ",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
          GestureDetector(
            onTap: onSignUp,
            child: const Text(
              'Sign Up',
              style: TextStyle(
                color: _mint,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================================================
// SECURITY STATUS
// ========================================================================

class _SecurityStatus extends StatelessWidget {
  const _SecurityStatus();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 14,
            color: _mint,
          ),
          const SizedBox(width: 7),
          Text(
            'Your workspace is protected',
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: .55,
              ),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================================================
// LUXURY FOREST BACKGROUND
// ========================================================================

class _LuxuryForestBackground extends StatelessWidget {
  const _LuxuryForestBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ================================================================
        // MAIN FOREST
        // ================================================================

        Image.asset(
          'assets/images/forest.png',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
        ),

        // ================================================================
        // SECOND FOREST
        // ================================================================

        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: .58,
              heightFactor: 1,
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: [
                      0.00,
                      0.18,
                      0.42,
                      1.00,
                    ],
                    colors: [
                      Colors.transparent,
                      Colors.white24,
                      Colors.white70,
                      Colors.white,
                    ],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  'assets/images/forest1.jpg',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
        ),

        // ================================================================
        // CENTER LIGHT
        // ================================================================

        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(
                  0,
                  -0.05,
                ),
                radius: 1.0,
                colors: [
                  Colors.white.withValues(alpha: .03),
                  Colors.transparent,
                  Colors.black.withValues(alpha: .14),
                ],
                stops: const [
                  0.0,
                  0.55,
                  1.0,
                ],
              ),
            ),
          ),
        ),

        // ================================================================
        // CINEMATIC GRADIENT
        // ================================================================

        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: .22),
                  Colors.transparent,
                  Colors.black.withValues(alpha: .10),
                ],
                stops: const [
                  0.0,
                  0.48,
                  1.0,
                ],
              ),
            ),
          ),
        ),

        // ================================================================
        // SIDE VIGNETTE
        // ================================================================

        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: .16),
                  Colors.transparent,
                  Colors.black.withValues(alpha: .12),
                ],
                stops: const [
                  0.0,
                  0.38,
                  1.0,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ========================================================================
// LOGIN GLASS CARD
// ========================================================================

class _LoginGlassCard extends StatelessWidget {
  final Widget child;

  const _LoginGlassCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 26,
          sigmaY: 26,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            34,
            28,
            34,
            30,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: .10,
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: .20,
              ),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: .18,
                ),
                blurRadius: 50,
                spreadRadius: 0,
                offset: const Offset(
                  0,
                  22,
                ),
              ),
            ],
          ),
          child: Stack(
            children: [
              // ==========================================================
              // GLASS HIGHLIGHT
              // ==========================================================

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(
                            alpha: .45,
                          ),
                          Colors.white.withValues(
                            alpha: .06,
                          ),
                          Colors.white.withValues(
                            alpha: .35,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              child,
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================================================
// LOGIN FIELD
// ========================================================================

class _LoginField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const _LoginField({
    required this.label,
    required this.controller,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================================================================
        // LABEL
        // ================================================================

        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 7),

        // ================================================================
        // TEXT FIELD
        // ================================================================

        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          cursorColor: _mint,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: Colors.white60,
              size: 17,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.black.withValues(
              alpha: .18,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(
                  alpha: .12,
                ),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(
                  alpha: .12,
                ),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: _mint.withValues(
                  alpha: .72,
                ),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
