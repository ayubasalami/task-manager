import 'package:flutter_riverpod/legacy.dart';

class OnboardingNotifier extends StateNotifier<int> {
  OnboardingNotifier() : super(0);

  void nextPage() {
    state++;
  }

  void previousPage() {
    if (state > 0) {
      state--;
    }
  }

  void goToPage(int index) {
    state = index;
  }

  void reset() {
    state = 0;
  }
}
