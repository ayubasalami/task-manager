import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/app_sizes.dart';
import '../../../../core/app_strings.dart';
import '../../../../core/colors.dart';
import '../../../../core/utils/app_storage.dart';
import '../provider/onboarding_provider.dart';
import '../widgets/onboarding_widget.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    ref.read(onboardingPageIndexProvider.notifier).goToPage(index);
  }

  Future<void> _completeOnboarding() async {
    await AppStorage.setOnboardingComplete(true);

    if (!mounted) return;
    context.go('/home');
  }

  void _skipOnboarding() {
    final pages = ref.read(onboardingPagesProvider);
    _pageController.animateToPage(
      pages.length - 1,
      duration: const Duration(milliseconds: AppSizes.animationNormal),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    final currentIndex = ref.read(onboardingPageIndexProvider);
    final pages = ref.read(onboardingPagesProvider);

    if (currentIndex < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: AppSizes.animationNormal),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = ref.watch(onboardingPagesProvider);
    final currentIndex = ref.watch(onboardingPageIndexProvider);
    final isLastPage = currentIndex == pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (!isLastPage)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMd),
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    child: const Text(AppStrings.skip),
                  ),
                ),
              ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(page: pages[index]);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXl,
              ),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.grey300,
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                      expansionFactor: 3,
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingXl),
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeightLg,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      child: Text(
                        isLastPage ? AppStrings.getStarted : AppStrings.next,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
