import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_track/core/constants/navigation/navigation_constants.dart';
import 'package:gym_track/feature/login/login_view.dart';
import 'package:gym_track/feature/main/main_view.dart';
import 'package:gym_track/feature/signup/signup_view.dart';
import 'package:gym_track/feature/splash/view/splash_view.dart';

final goRouter = GoRouter(initialLocation: NavigationConstants.splash, routes: [
  GoRoute(
    path: '/',
    builder: (BuildContext context, GoRouterState state) {
      return const Scaffold(
        body: Center(
          child: Text('Home'),
        ),
      );
    },
  ),
  GoRoute(
    path: NavigationConstants.splash,
    builder: (BuildContext context, GoRouterState state) {
      return const SplashView();
    },
  ),
  GoRoute(
    path: NavigationConstants.main,
    builder: (BuildContext context, GoRouterState state) {
      return const MainView();
    },
  ),
  GoRoute(
    path: NavigationConstants.login,
    builder: (BuildContext context, GoRouterState state) {
      return const LoginView();
    },
  ),
  GoRoute(
    path: NavigationConstants.signup,
    builder: (BuildContext context, GoRouterState state) {
      return const SignUpScreen();
    },
  ),
]);
