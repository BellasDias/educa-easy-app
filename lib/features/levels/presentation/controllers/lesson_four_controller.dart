import 'package:flutter_riverpod/flutter_riverpod.dart';

class LessonFourState {
  final Map<int, String> answers;
  final bool hasTested;
  final bool isSuccess;

  LessonFourState({
    this.answers = const {},
    this.hasTested = false,
    this.isSuccess = false,
  });

  // O Gabarito da Fase 4
  static const Map<int, String> correctAnswers = {
    1: 'Guarda-chuva', // Se chuva
    2: 'Casaco', // Se frio
    3: 'Boné', // Se sol
    4: 'Escova', // E (noite + sujo)
    5: 'Comida', // E (acordar + fome)
    6: 'Livro', // E (prova + estudar)
    7: 'Sabonete', // OU (lama + tinta)
    8: 'Brincar', // OU (sábado + domingo)
    9: 'Protetor', // OU (praia + piscina)
  };

  // Verifica se o usuário preencheu as 9 e se todas batem com o gabarito
  bool get isCorrect {
    if (answers.length < 9) return false;
    for (int i = 1; i <= 9; i++) {
      if (answers[i] != correctAnswers[i]) return false;
    }
    return true;
  }

  LessonFourState copyWith({
    Map<int, String>? answers,
    bool? hasTested,
    bool? isSuccess,
  }) {
    return LessonFourState(
      answers: answers ?? this.answers,
      hasTested: hasTested ?? this.hasTested,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class LessonFourController extends StateNotifier<LessonFourState> {
  LessonFourController() : super(LessonFourState());

  void updateAnswer(int id, String item) {
    final newAnswers = Map<int, String>.from(state.answers);
    newAnswers[id] = item;
    state = state.copyWith(answers: newAnswers, hasTested: false);
  }

  void testAnswer() {
    // Só permite testar se preencheu tudo
    if (state.answers.length == 9) {
      state = state.copyWith(hasTested: true, isSuccess: state.isCorrect);
    }
  }

  void resetLesson() {
    state = LessonFourState();
  }
}

final lessonFourProvider =
    StateNotifierProvider.autoDispose<LessonFourController, LessonFourState>((
      ref,
    ) {
      return LessonFourController();
    });
