import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_track/feature/login/theme/login_theme.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _acceptTerms = false;
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept the terms and conditions'),
          backgroundColor: LoginTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
        }
      } catch (e) {
        print(e);
      }

      setState(() => _isLoading = false);

      // Navigate to main view after successful signup
      if (mounted) {
        // TODO: Navigate to MainView or show success message
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
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
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
                            const SizedBox(height: 20),
                            _buildHeader(),
                            const SizedBox(height: 40),
                            _buildSignUpForm(),
                            const SizedBox(height: 24),
                            _buildTermsCheckbox(),
                            const SizedBox(height: 32),
                            _buildSignUpButton(),
                            const SizedBox(height: 32),
                            _buildDivider(),
                            const SizedBox(height: 32),
                            _buildSocialSignUp(),
                            const SizedBox(height: 40),
                            _buildLoginPrompt(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: LoginTheme.surfaceHighlight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: LoginTheme.secondary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: LoginTheme.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
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
          'Create\nAccount',
          style: LoginTheme.title,
        ),
        const SizedBox(height: 12),
        const Text(
          'Start your fitness journey today',
          style: LoginTheme.subtitle,
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildNameField(),
          const SizedBox(height: 20),
          _buildEmailField(),
          const SizedBox(height: 20),
          _buildPasswordField(),
          const SizedBox(height: 20),
          _buildConfirmPasswordField(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text('FULL NAME', style: LoginTheme.inputLabel),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LoginTheme.inputGradient,
            borderRadius: BorderRadius.circular(LoginTheme.inputRadius),
            boxShadow: LoginTheme.inputShadow,
          ),
          child: TextFormField(
            controller: _nameController,
            keyboardType: TextInputType.name,
            style: LoginTheme.inputText,
            decoration: InputDecoration(
              hintText: 'John Doe',
              hintStyle: LoginTheme.inputText.copyWith(
                color: LoginTheme.textSecondary.withValues(alpha: 0.5),
              ),
              prefixIcon: const Icon(
                Icons.person_outline,
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
                return 'Please enter your name';
              }
              if (value.length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
        ),
      ],
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
              if (!value.contains('@') || !value.contains('.')) {
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
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              if (!value.contains(RegExp(r'[A-Z]'))) {
                return 'Password must contain at least one uppercase letter';
              }
              if (!value.contains(RegExp(r'[0-9]'))) {
                return 'Password must contain at least one number';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text('CONFIRM PASSWORD', style: LoginTheme.inputLabel),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LoginTheme.inputGradient,
            borderRadius: BorderRadius.circular(LoginTheme.inputRadius),
            boxShadow: LoginTheme.inputShadow,
          ),
          child: TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
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
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: LoginTheme.textSecondary,
                ),
                onPressed: () {
                  setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword);
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
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            gradient: _acceptTerms ? LoginTheme.buttonGradient : null,
            color: _acceptTerms ? null : LoginTheme.surfaceHighlight,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _acceptTerms
                  ? LoginTheme.primary
                  : LoginTheme.secondary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() => _acceptTerms = !_acceptTerms);
              },
              borderRadius: BorderRadius.circular(6),
              child: _acceptTerms
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: LoginTheme.background,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _acceptTerms = !_acceptTerms);
            },
            child: RichText(
              text: TextSpan(
                style: LoginTheme.subtitle.copyWith(fontSize: 13),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: LoginTheme.linkText.copyWith(fontSize: 13),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: LoginTheme.linkText.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
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
          onTap: _isLoading ? null : _handleSignUp,
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
                    'CREATE ACCOUNT',
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

  Widget _buildSocialSignUp() {
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
            // TODO: Implement social signup
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

  Widget _buildLoginPrompt() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Already have an account? ',
            style: LoginTheme.subtitle,
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Login',
              style: LoginTheme.linkText,
            ),
          ),
        ],
      ),
    );
  }
}
