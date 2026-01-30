import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_track/core/constants/navigation/navigation_constants.dart';
import 'package:gym_track/feature/login/theme/login_theme.dart';
import 'package:gym_track/feature/signup/signup_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      // TODO: Implement actual login logic
      try {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('welcome back ${credential.user?.displayName ?? ""}'),
            backgroundColor: LoginTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        context.push(NavigationConstants.main);
      } on FirebaseAuthException catch (e) {
        debugPrint('ErrorCode on Firebase Login: ${e.code}');
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No user found for that email.'),
              backgroundColor: LoginTheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Wrong password provided for that user.'),
              backgroundColor: LoginTheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }

      setState(() => _isLoading = false);

      // Navigate to main view after successful login
      if (mounted) {
        // TODO: Navigate to MainView
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LoginTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: LoginTheme.pagePadding,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      _buildHeader(),
                      const SizedBox(height: 60),
                      _buildLoginForm(),
                      const SizedBox(height: 24),
                      _buildForgotPassword(),
                      const SizedBox(height: 32),
                      _buildLoginButton(),
                      const SizedBox(height: 32),
                      _buildDivider(),
                      const SizedBox(height: 32),
                      _buildSocialLogin(),
                      const SizedBox(height: 40),
                      _buildSignUpPrompt(),
                      const SizedBox(height: 40),
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animated logo/icon
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LoginTheme.buttonGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: LoginTheme.glowShadow,
          ),
          child: const Icon(
            Icons.fitness_center,
            color: LoginTheme.background,
            size: 32,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Welcome\nBack',
          style: LoginTheme.title,
        ),
        const SizedBox(height: 12),
        const Text(
          'Track your fitness journey',
          style: LoginTheme.subtitle,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildEmailField(),
          const SizedBox(height: 20),
          _buildPasswordField(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text('EMAIL', style: LoginTheme.inputLabel),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LoginTheme.inputGradient,
            borderRadius: BorderRadius.circular(LoginTheme.inputRadius),
            boxShadow: LoginTheme.inputShadow,
          ),
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: LoginTheme.inputText,
            decoration: InputDecoration(
              hintText: 'your.email@example.com',
              hintStyle: LoginTheme.inputText.copyWith(
                color: LoginTheme.textSecondary.withValues(alpha: 0.5),
              ),
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: LoginTheme.primary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(LoginTheme.inputRadius),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text('PASSWORD', style: LoginTheme.inputLabel),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LoginTheme.inputGradient,
            borderRadius: BorderRadius.circular(LoginTheme.inputRadius),
            boxShadow: LoginTheme.inputShadow,
          ),
          child: TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: LoginTheme.inputText,
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: LoginTheme.inputText.copyWith(
                color: LoginTheme.textSecondary.withValues(alpha: 0.5),
              ),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: LoginTheme.primary,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: LoginTheme.textSecondary,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(LoginTheme.inputRadius),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // TODO: Implement forgot password
        },
        child: const Text(
          'Forgot Password?',
          style: LoginTheme.linkText,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: LoginTheme.buttonHeight,
      decoration: BoxDecoration(
        gradient: LoginTheme.buttonGradient,
        borderRadius: BorderRadius.circular(LoginTheme.buttonRadius),
        boxShadow: LoginTheme.buttonShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleLogin,
          borderRadius: BorderRadius.circular(LoginTheme.buttonRadius),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: LoginTheme.background,
                      strokeWidth: 3,
                    ),
                  )
                : const Text(
                    'LOGIN',
                    style: LoginTheme.buttonText,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  LoginTheme.textSecondary.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: LoginTheme.inputLabel.copyWith(
              color: LoginTheme.textSecondary.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  LoginTheme.textSecondary.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Row(
      children: [
        Expanded(child: _buildSocialButton(Icons.g_mobiledata, 'Google')),
        const SizedBox(width: 16),
        Expanded(child: _buildSocialButton(Icons.apple, 'Apple')),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: LoginTheme.surfaceHighlight,
        borderRadius: BorderRadius.circular(LoginTheme.buttonRadius),
        border: Border.all(
          color: LoginTheme.secondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Implement social login
          },
          borderRadius: BorderRadius.circular(LoginTheme.buttonRadius),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: LoginTheme.textPrimary, size: 24),
              const SizedBox(width: 8),
              Text(
                label,
                style: LoginTheme.inputText.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpPrompt() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Don't have an account? ",
            style: LoginTheme.subtitle,
          ),
          TextButton(
            onPressed: () {
              context.push(NavigationConstants.signup);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Sign Up',
              style: LoginTheme.linkText,
            ),
          ),
        ],
      ),
    );
  }
}
