import 'package:flutter_riverpod/flutter_riverpod.dart';

class LessonFiveState {
  final int currentStage; // Vai de 0 (Fase 1) a 3 (Fase 4)
  final Map<String, String> answers;
  final bool hasTested;
  final bool isSuccess;

  LessonFiveState({
    this.currentStage = 0,
    this.answers = const {},
    this.hasTested = false,
    this.isSuccess = false,
  });

  // O Super Gabarito da Missão Espacial
  static const Map<String, String> correctAnswers = {
    // Fase 1: Sequência de Decolagem
    'seq1': 'Vestir o Traje',
    'seq2': 'Entrar na Nave',
    'seq3': 'Ligar os Motores',
    // Fase 2: Rota Numérica (De 5 em 5) -> 5, 10, [15], 20, [25], [30]
    'num1': '15',
    'num2': '25',
    'num3': '30',
    // Fase 3: Variáveis (Estoque da Nave)
    'var1': 'Bateria', // Energia
    'var2': 'Comida', // Alimentação
    'var3': 'Rádio', // Comunicação
    // Fase 4: Condicionais (Emergências no Espaço)
    'cond1': 'Desviar', // SE meteoro
    'cond2': 'Acenar', // SE alien amigável E acenando
    'cond3': 'Apertar Botão', // SE alarme OU luz piscar
  };

  // Verifica se a etapa ATUAL está toda preenchida para liberar o botão "Avançar"
  bool get isCurrentStageFilled {
    if (currentStage == 0)
      return answers.containsKey('seq1') &&
          answers.containsKey('seq2') &&
          answers.containsKey('seq3');
    if (currentStage == 1)
      return answers.containsKey('num1') &&
          answers.containsKey('num2') &&
          answers.containsKey('num3');
    if (currentStage == 2)
      return answers.containsKey('var1') &&
          answers.containsKey('var2') &&
          answers.containsKey('var3');
    if (currentStage == 3)
      return answers.containsKey('cond1') &&
          answers.containsKey('cond2') &&
          answers.containsKey('cond3');
    return false;
  }

  // Verifica se TODAS as 12 respostas estão corretas
  bool get isAllCorrect {
    for (var key in correctAnswers.keys) {
      if (answers[key] != correctAnswers[key]) return false;
    }
    return true;
  }

  LessonFiveState copyWith({
    int? currentStage,
    Map<String, String>? answers,
    bool? hasTested,
    bool? isSuccess,
  }) {
    return LessonFiveState(
      currentStage: currentStage ?? this.currentStage,
      answers: answers ?? this.answers,
      hasTested: hasTested ?? this.hasTested,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class LessonFiveController extends StateNotifier<LessonFiveState> {
  LessonFiveController() : super(LessonFiveState());

  void updateAnswer(String key, String value) {
    final newAnswers = Map<String, String>.from(state.answers);
    newAnswers[key] = value;
    state = state.copyWith(answers: newAnswers, hasTested: false);
  }

  void nextStage() {
    if (state.currentStage < 3) {
      state = state.copyWith(currentStage: state.currentStage + 1);
    }
  }

  void previousStage() {
    if (state.currentStage > 0) {
      state = state.copyWith(currentStage: state.currentStage - 1);
    }
  }

  void testFinalChallenge() {
    state = state.copyWith(hasTested: true, isSuccess: state.isAllCorrect);
  }

  void resetLesson() {
    state = LessonFiveState();
  }
}

final lessonFiveProvider =
    StateNotifierProvider.autoDispose<LessonFiveController, LessonFiveState>((
      ref,
    ) {
      return LessonFiveController();
    });
