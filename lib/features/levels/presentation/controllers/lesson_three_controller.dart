import 'package:flutter_riverpod/flutter_riverpod.dart';

class LessonThreeState {
  final String? lancheiraItem;
  final String? bolsaItem;
  final bool hasTested;
  final bool isSuccess; // Controla se a tela de sucesso deve aparecer

  LessonThreeState({
    this.lancheiraItem,
    this.bolsaItem,
    this.hasTested = false,
    this.isSuccess = false,
  });

  // Agora a resposta certa exige as duas combinações corretas!
  bool get isCorrect => lancheiraItem == 'Maçã' && bolsaItem == 'Caderno';

  LessonThreeState copyWith({
    String? lancheiraItem,
    String? bolsaItem,
    bool? hasTested,
    bool? isSuccess,
  }) {
    return LessonThreeState(
      lancheiraItem: lancheiraItem ?? this.lancheiraItem,
      bolsaItem: bolsaItem ?? this.bolsaItem,
      hasTested: hasTested ?? this.hasTested,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class LessonThreeController extends StateNotifier<LessonThreeState> {
  LessonThreeController() : super(LessonThreeState());

  void setLancheiraItem(String item) {
    state = state.copyWith(lancheiraItem: item, hasTested: false);
  }

  void setBolsaItem(String item) {
    state = state.copyWith(bolsaItem: item, hasTested: false);
  }

  void testAnswer() {
    if (state.lancheiraItem != null && state.bolsaItem != null) {
      if (state.isCorrect) {
        state = state.copyWith(hasTested: true, isSuccess: true);
      } else {
        state = state.copyWith(hasTested: true, isSuccess: false);
      }
    }
  }

  void resetLesson() {
    state = LessonThreeState();
  }
}

// O .autoDispose é o que faz a fase "zerar" quando o usuário volta pro mapa!
final lessonThreeProvider =
    StateNotifierProvider.autoDispose<LessonThreeController, LessonThreeState>((
      ref,
    ) {
      return LessonThreeController();
    });
