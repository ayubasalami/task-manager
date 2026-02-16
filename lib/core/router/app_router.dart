import 'package:expense_tracker/features/transactions/presentation/pages/transaction_detail_screen.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/presentation/pages/onboarding_screen.dart';
import '../../features/onboarding/presentation/pages/splash_screen.dart';
import '../../features/transactions/presentation/pages/add_transaction_screen.dart';
import '../../features/transactions/presentation/pages/edit_transaction_screen.dart';
import '../../features/transactions/presentation/pages/transaction_list_main.dart';
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
        path: '/home/transaction/:id/edit',
        name: 'editTransaction',
        builder: (context, state) {
          final transactionId = state.pathParameters['id']!;
          return EditTransactionScreen(transactionId: transactionId);
        },
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const TransactionListScreen(),
        routes: [
          GoRoute(
            path: 'transaction/:id',
            name: 'transaction-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return TransactionDetailScreen(transactionId: id);
            },
          ),

          GoRoute(
            path: 'add',
            name: 'add-transaction',
            builder: (context, state) => const AddTransactionScreen(),
          ),
        ],
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
