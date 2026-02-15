import 'package:expense_tracker/features/onboarding/data/onboarding_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/onboarding_repository.dart';
import 'onboarding_notifier.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository();
});

final onboardingPagesProvider = Provider<List<OnboardingModel>>((ref) {
  final repository = ref.watch(onboardingRepositoryProvider);
  return repository.getOnboardingPages();
});

final onboardingPageIndexProvider =
    StateNotifierProvider<OnboardingNotifier, int>((ref) {
      return OnboardingNotifier();
    });
