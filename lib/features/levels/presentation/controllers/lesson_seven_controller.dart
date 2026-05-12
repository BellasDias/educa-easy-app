import 'package:flutter_riverpod/flutter_riverpod.dart';

class LessonSevenState {
  final Map<int, String> answers;
  final bool hasTested;
  final bool isSuccess;

  LessonSevenState({
    this.answers = const {},
    this.hasTested = false,
    this.isSuccess = false,
  });

  // Gabarito: Qual "Comando" agrupa esses passos?
  static const Map<int, String> correctAnswers = {
    1: 'Fazer Sanduíche',
    2: 'Lavar as Mãos',
    3: 'Ir para Escola',
    4: 'Arrumar a Cama',
    5: 'Banho no Pet',
  };

  bool get isCorrect {
    if (answers.length < 5) return false;
    for (int i = 1; i <= 5; i++) {
      if (answers[i] != correctAnswers[i]) return false;
    }
    return true;
  }

  LessonSevenState copyWith({
    Map<int, String>? answers,
    bool? hasTested,
    bool? isSuccess,
  }) {
    return LessonSevenState(
      answers: answers ?? this.answers,
      hasTested: hasTested ?? this.hasTested,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class LessonSevenController extends StateNotifier<LessonSevenState> {
  LessonSevenController() : super(LessonSevenState());

  void updateAnswer(int id, String item) {
    final newAnswers = Map<int, String>.from(state.answers);
    newAnswers[id] = item;
    state = state.copyWith(answers: newAnswers, hasTested: false);
  }

  void testAnswer() {
    if (state.answers.length == 5) {
      state = state.copyWith(hasTested: true, isSuccess: state.isCorrect);
    }
  }

  void resetLesson() {
    state = LessonSevenState();
  }
}

final lessonSevenProvider =
    StateNotifierProvider.autoDispose<LessonSevenController, LessonSevenState>((
      ref,
    ) {
      return LessonSevenController();
    });
