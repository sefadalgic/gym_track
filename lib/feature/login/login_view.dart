import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart' as http hide Response;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gym_track/core/constants/navigation/navigation_constants.dart';
import 'package:gym_track/feature/login/theme/login_theme.dart';
import 'package:gym_track/feature/signup/signup_view.dart';
import 'package:http/http.dart' as http;

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

  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;
  String _contactText = '';
  String _errorMessage = '';
  String _serverAuthCode = '';

  List<String> scopes = <String>[
    'https://www.googleapis.com/auth/contacts.readonly',
  ];

  @override
  void initState() {
    super.initState();

    // #docregion Setup
    final GoogleSignIn signIn = GoogleSignIn.instance;
    unawaited(
      signIn
          .initialize(
              clientId:
                  '495544191021-9js1hl8s741vdf086u26rhq723i2a8a7.apps.googleusercontent.com')
          .then((
        _,
      ) {
        signIn.authenticationEvents
            .listen(_handleAuthenticationEvent)
            .onError(_handleAuthenticationError);

        /// This example always uses the stream-based approach to determining
        /// which UI state to show, rather than using the future returned here,
        /// if any, to conditionally skip directly to the signed-in state.
        signIn.attemptLightweightAuthentication();
      }),
    );
    // #enddocregion Setup

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

  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    // #docregion CheckAuthorization
    final GoogleSignInAccount? user = // ...
        // #enddocregion CheckAuthorization
        switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    // Check for existing authorization.
    // #docregion CheckAuthorization
    final GoogleSignInClientAuthorization? authorization =
        await user?.authorizationClient.authorizationForScopes(scopes);
    // #enddocregion CheckAuthorization

    setState(() {
      _currentUser = user;
      _isAuthorized = authorization != null;
      _errorMessage = '';
    });

    // If the user has already granted access to the required scopes, call the
    // REST API.
    if (user != null && authorization != null) {
      unawaited(_handleGetContact(user));
    }
  }

  // Calls the People API REST endpoint for the signed-in user to retrieve information.
  Future<void> _handleGetContact(GoogleSignInAccount user) async {
    setState(() {
      _contactText = 'Loading contact info...';
    });
    final Map<String, String>? headers =
        await user.authorizationClient.authorizationHeaders(scopes);
    if (headers == null) {
      setState(() {
        _contactText = '';
        _errorMessage = 'Failed to construct authorization headers.';
      });
      return;
    }
    final http.Response response = await http.get(
      Uri.parse(
        'https://people.googleapis.com/v1/people/me/connections'
        '?requestMask.includeField=person.names',
      ),
      headers: headers,
    );
    if (response.statusCode != 200) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        setState(() {
          _isAuthorized = false;
          _errorMessage = 'People API gave a ${response.statusCode} response. '
              'Please re-authorize access.';
        });
      } else {
        print('People API ${response.statusCode} response: ${response.body}');
        setState(() {
          _contactText = 'People API gave a ${response.statusCode} '
              'response. Check logs for details.';
        });
      }
      return;
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    final String? namedContact = _pickFirstNamedContact(data);
    setState(() {
      if (namedContact != null) {
        _contactText = 'I see you know $namedContact!';
      } else {
        _contactText = 'No contacts to display.';
      }
    });
  }

  String? _pickFirstNamedContact(Map<String, dynamic> data) {
    final connections = data['connections'] as List<dynamic>?;
    final contact = connections?.firstWhere(
      (dynamic contact) => (contact as Map<Object?, dynamic>)['names'] != null,
      orElse: () => null,
    ) as Map<String, dynamic>?;
    if (contact != null) {
      final names = contact['names'] as List<dynamic>;
      final name = names.firstWhere(
        (dynamic name) =>
            (name as Map<Object?, dynamic>)['displayName'] != null,
        orElse: () => null,
      ) as Map<String, dynamic>?;
      if (name != null) {
        return name['displayName'] as String?;
      }
    }
    return null;
  }

  Future<void> _handleAuthenticationError(Object e) async {
    setState(() {
      _currentUser = null;
      _isAuthorized = false;
      _errorMessage = e is GoogleSignInException
          ? _errorMessageFromSignInException(e)
          : 'Unknown error: $e';
    });
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

  Future<void> _handleGetAuthCode(GoogleSignInAccount user) async {
    try {
      // #docregion RequestServerAuth
      final GoogleSignInServerAuthorization? serverAuth =
          await user.authorizationClient.authorizeServer(scopes);
      // #enddocregion RequestServerAuth

      setState(() {
        _serverAuthCode = serverAuth == null ? '' : serverAuth.serverAuthCode;
      });
    } on GoogleSignInException catch (e) {
      _errorMessage = _errorMessageFromSignInException(e);
    }
  }

  /// Returns the list of widgets to include if the user is authenticated.
  List<Widget> _buildAuthenticatedWidgets(GoogleSignInAccount user) {
    return <Widget>[
      // The user is Authenticated.
      ListTile(
        leading: GoogleUserCircleAvatar(identity: user),
        title: Text(user.displayName ?? ''),
        subtitle: Text(user.email),
      ),
      const Text('Signed in successfully.'),
      if (_isAuthorized) ...<Widget>[
        // The user has Authorized all required scopes.
        if (_contactText.isNotEmpty) Text(_contactText),
        ElevatedButton(
          child: const Text('REFRESH'),
          onPressed: () => _handleGetContact(user),
        ),
        if (_serverAuthCode.isEmpty)
          ElevatedButton(
            child: const Text('REQUEST SERVER CODE'),
            onPressed: () => _handleGetAuthCode(user),
          )
        else
          Text('Server auth code:\n$_serverAuthCode'),
      ] else ...<Widget>[
        // The user has NOT Authorized all required scopes.
        const Text('Authorization needed to read your contacts.'),
        ElevatedButton(
          onPressed: () => _handleAuthorizeScopes(user),
          child: const Text('REQUEST PERMISSIONS'),
        ),
      ],
      ElevatedButton(onPressed: () {}, child: const Text('SIGN OUT')),
    ];
  }

  // regardless, so authorizationRequiresUserInteraction() is not checked.
  Future<void> _handleAuthorizeScopes(GoogleSignInAccount user) async {
    try {
      // #docregion RequestScopes
      final GoogleSignInClientAuthorization authorization =
          await user.authorizationClient.authorizeScopes(scopes);
      // #enddocregion RequestScopes

      // The returned tokens are ignored since _handleGetContact uses the
      // authorizationHeaders method to re-read the token cached by
      // authorizeScopes. The code above is used as a README excerpt, so shows
      // the simpler pattern of getting the authorization for immediate use.
      // That results in an unused variable, which this statement suppresses
      // (without adding an ignore: directive to the README excerpt).
      // ignore: unnecessary_statements
      authorization;

      setState(() {
        _isAuthorized = true;
        _errorMessage = '';
      });
      unawaited(_handleGetContact(_currentUser!));
    } on GoogleSignInException catch (e) {
      _errorMessage = _errorMessageFromSignInException(e);
    }
  }

  /// Returns the list of widgets to include if the user is not authenticated.
  List<Widget> _buildUnauthenticatedWidgets() {
    return <Widget>[
      const Text('You are not currently signed in.'),
      // #docregion ExplicitSignIn
      if (GoogleSignIn.instance.supportsAuthenticate())
        ElevatedButton(
          onPressed: () async {
            try {
              await GoogleSignIn.instance.authenticate();
            } catch (e) {
              // #enddocregion ExplicitSignIn
              _errorMessage = e.toString();
              // #docregion ExplicitSignIn
            }
          },
          child: const Text('SIGN IN'),
        )
      else ...<Widget>[
        const Text(
          'This platform does not have a known authentication method',
        ),
        // #docregion ExplicitSignIn
      ],
      // #enddocregion ExplicitSignIn
    ];
  }

  String _errorMessageFromSignInException(GoogleSignInException e) {
    // In practice, an application should likely have specific handling for most
    // or all of the, but for simplicity this just handles cancel, and reports
    // the rest as generic errors.
    return switch (e.code) {
      GoogleSignInExceptionCode.canceled => 'Sign in canceled',
      _ => 'GoogleSignInException ${e.code}: ${e.description}',
    };
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
                      if (_currentUser != null)
                        ..._buildAuthenticatedWidgets(_currentUser!),
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
        Expanded(
            child: _buildSocialButton(
                Icons.g_mobiledata, 'Google', _signInGoogle)),
        const SizedBox(width: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            if (_currentUser == null) ..._buildUnauthenticatedWidgets(),
            if (_errorMessage.isNotEmpty) Text(_errorMessage),
          ],
        )
      ],
    );
  }

  Future<void> _signInGoogle() async {
    try {
      final googleSignIn = GoogleSignIn.instance;

      googleSignIn.authenticate();
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
    }
  }

  Widget _buildSocialButton(IconData icon, String label, VoidCallback onTap) {
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
