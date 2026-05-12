import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LessonSixState {
  final Map<int, String> answers;
  final List<String> availableOptions;
  final int carouselIndex; // Controla qual par de opções estamos vendo
  final bool hasTested;
  final bool isSuccess;

  LessonSixState({
    this.answers = const {},
    required this.availableOptions,
    this.carouselIndex = 0,
    this.hasTested = false,
    this.isSuccess = false,
  });

  // Gabarito da Fase 6 (8 perguntas focadas no universo infantil)
  static const Map<int, String> correctAnswers = {
    1: 'Escovar', // Enquanto o dente não estiver limpo...
    2: 'Dar um pulo', // Repetir 5 vezes no pula-pula...
    3: 'Arrumar a bagunça', // Enquanto o quarto estiver bagunçado...
    4: 'Lavar e secar', // Para cada prato sujo na pia...
    5: 'Deixar na tomada', // Até o celular carregar 100%...
    6: 'Assar no forno', // Enquanto o bolo estiver cru...
    7: 'Colocar água', // Para cada plantinha no jardim...
    8: 'Prestar atenção', // Até o sinal da escola tocar...
  };

  bool get isCorrect {
    if (answers.length < 8) return false;
    for (int i = 1; i <= 8; i++) {
      if (answers[i] != correctAnswers[i]) return false;
    }
    return true;
  }

  LessonSixState copyWith({
    Map<int, String>? answers,
    List<String>? availableOptions,
    int? carouselIndex,
    bool? hasTested,
    bool? isSuccess,
  }) {
    return LessonSixState(
      answers: answers ?? this.answers,
      availableOptions: availableOptions ?? this.availableOptions,
      carouselIndex: carouselIndex ?? this.carouselIndex,
      hasTested: hasTested ?? this.hasTested,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class LessonSixController extends StateNotifier<LessonSixState> {
  LessonSixController()
    : super(
        LessonSixState(
          // Embaralhando as opções no início
          availableOptions: LessonSixState.correctAnswers.values.toList()
            ..shuffle(),
        ),
      );

  void updateAnswer(int id, String item) {
    final newAnswers = Map<int, String>.from(state.answers);
    final newOptions = List<String>.from(state.availableOptions);

    // Se o slot já tinha uma resposta antes, devolve ela pro carrossel
    if (newAnswers.containsKey(id) && newAnswers[id] != null) {
      newOptions.add(newAnswers[id]!);
    }

    // Coloca a nova resposta no slot e tira do carrossel
    newAnswers[id] = item;
    newOptions.remove(item);

    // Ajusta o carrossel para não dar erro se as opções acabarem
    int newIdx = state.carouselIndex;
    if (newIdx >= newOptions.length && newOptions.isNotEmpty) {
      newIdx = max(0, newOptions.length - 1); // Volta um pouquinho
    }

    state = state.copyWith(
      answers: newAnswers,
      availableOptions: newOptions,
      carouselIndex: newIdx,
      hasTested: false,
    );
  }

  void removeAnswer(int id) {
    final newAnswers = Map<int, String>.from(state.answers);
    final newOptions = List<String>.from(state.availableOptions);

    // Tira a resposta do slot e devolve pro carrossel
    if (newAnswers.containsKey(id)) {
      newOptions.add(newAnswers[id]!);
      newAnswers.remove(id);
    }

    state = state.copyWith(
      answers: newAnswers,
      availableOptions: newOptions,
      hasTested: false,
    );
  }

  // Navegação do Carrossel
  void nextCarousel() {
    if (state.carouselIndex + 2 < state.availableOptions.length) {
      state = state.copyWith(carouselIndex: state.carouselIndex + 1);
    }
  }

  void prevCarousel() {
    if (state.carouselIndex > 0) {
      state = state.copyWith(carouselIndex: state.carouselIndex - 1);
    }
  }

  void testAnswer() {
    if (state.answers.length == 8) {
      state = state.copyWith(hasTested: true, isSuccess: state.isCorrect);
    }
  }

  void resetLesson() {
    state = LessonSixState(
      availableOptions: LessonSixState.correctAnswers.values.toList()
        ..shuffle(),
    );
  }
}

final lessonSixProvider =
    StateNotifierProvider.autoDispose<LessonSixController, LessonSixState>((
      ref,
    ) {
      return LessonSixController();
    });
