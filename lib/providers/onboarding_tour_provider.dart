import 'package:flutter_riverpod/flutter_riverpod.dart';

class TourState {
  const TourState({this.currentStep = 0, this.isVisible = false});
  final int currentStep;
  final bool isVisible;

  TourState copyWith({int? currentStep, bool? isVisible}) => TourState(
        currentStep: currentStep ?? this.currentStep,
        isVisible: isVisible ?? this.isVisible,
      );
}

class OnboardingTourNotifier extends Notifier<TourState> {
  @override
  TourState build() => const TourState();

  void startTour() => state = const TourState(currentStep: 0, isVisible: true);

  void nextStep() {
    if (state.currentStep < 4) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void endTour() => state = const TourState(isVisible: false);
}

final onboardingTourProvider =
    NotifierProvider<OnboardingTourNotifier, TourState>(
  OnboardingTourNotifier.new,
);
