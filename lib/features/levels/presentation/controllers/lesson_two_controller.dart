import 'package:flutter_riverpod/flutter_riverpod.dart';

class LessonTwoState {
  final String? slotThree; // Guarda o que foi solto na posição 3
  final String? slotSix; // Guarda o que foi solto na posição 6
  final bool hasTested;
  final bool isSuccess;

  LessonTwoState({
    this.slotThree,
    this.slotSix,
    this.hasTested = false,
    this.isSuccess = false,
  });

  // A lógica de vitória: A criança arrastou o 3 para o slotThree e o 6 para o slotSix?
  bool get isCorrect => slotThree == '3' && slotSix == '6';

  LessonTwoState copyWith({
    String? slotThree,
    String? slotSix,
    bool? hasTested,
    bool? isSuccess,
  }) {
    return LessonTwoState(
      slotThree: slotThree ?? this.slotThree,
      slotSix: slotSix ?? this.slotSix,
      hasTested: hasTested ?? this.hasTested,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class LessonTwoController extends StateNotifier<LessonTwoState> {
  LessonTwoController() : super(LessonTwoState());

  void setSlotThree(String item) {
    state = state.copyWith(slotThree: item, hasTested: false);
  }

  void setSlotSix(String item) {
    state = state.copyWith(slotSix: item, hasTested: false);
  }

  void testAnswer() {
    if (state.slotThree != null && state.slotSix != null) {
      state = state.copyWith(hasTested: true, isSuccess: state.isCorrect);
    }
  }

  void resetLesson() {
    state = LessonTwoState();
  }
}

final lessonTwoProvider =
    StateNotifierProvider.autoDispose<LessonTwoController, LessonTwoState>((
      ref,
    ) {
      return LessonTwoController();
    });
