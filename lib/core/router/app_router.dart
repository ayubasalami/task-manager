import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/pages/onboarding_screen.dart';
import '../../features/onboarding/pages/splash_screen.dart';
import '../utils/app_storage.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) =>
            const Placeholder(), // TODO: Replace with TransactionsListScreen
      ),
    ],

    redirect: (context, state) {
      final isSplashScreen = state.matchedLocation == '/';
      if (isSplashScreen) {
        return null;
      }
      final isOnboardingComplete = AppStorage.isOnboardingComplete();
      final isOnboardingScreen = state.matchedLocation == '/onboarding';

      if (!isOnboardingComplete && !isOnboardingScreen) {
        return '/onboarding';
      }
      if (isOnboardingComplete && isOnboardingScreen) {
        return '/home';
      }
      return null;
    },
  );
}
