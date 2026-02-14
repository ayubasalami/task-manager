import 'package:expense_tracker/features/onboarding/data/onboarding_model.dart';

import '../../../core/app_strings.dart';

class OnboardingRepository {
  List<OnboardingModel> getOnboardingPages() {
    return const [
      OnboardingModel(
        title: AppStrings.onboardingTitle1,
        description: AppStrings.onboardingDesc1,
        lottieAsset: 'assets/lottie/Finance guru.json',
      ),
      OnboardingModel(
        title: AppStrings.onboardingTitle2,
        description: AppStrings.onboardingDesc2,
        lottieAsset: 'assets/lottie/Payment Successful Animation.json',
      ),
      OnboardingModel(
        title: AppStrings.onboardingTitle3,
        description: AppStrings.onboardingDesc3,
        lottieAsset: 'assets/lottie/Isometric data analysis.json',
      ),
    ];
  }
}
