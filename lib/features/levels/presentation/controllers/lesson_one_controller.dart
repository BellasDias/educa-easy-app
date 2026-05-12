import 'package:flutter_riverpod/flutter_riverpod.dart';

class LessonOneState {
  final String? droppedItem;
  final bool hasTested;
  final bool isSuccess;

  LessonOneState({
    this.droppedItem,
    this.hasTested = false,
    this.isSuccess = false,
  });

  // A ordem lógica certa: colocar o sapato DEPOIS da meia e ANTES de amarrar!
  bool get isCorrect => droppedItem == 'Calçar o sapato';

  LessonOneState copyWith({
    String? droppedItem,
    bool? hasTested,
    bool? isSuccess,
  }) {
    return LessonOneState(
      droppedItem: droppedItem ?? this.droppedItem,
      hasTested: hasTested ?? this.hasTested,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class LessonOneController extends StateNotifier<LessonOneState> {
  LessonOneController() : super(LessonOneState());

  void setDroppedItem(String item) {
    state = state.copyWith(droppedItem: item, hasTested: false);
  }

  void testAnswer() {
    if (state.droppedItem != null) {
      if (state.isCorrect) {
        state = state.copyWith(hasTested: true, isSuccess: true);
      } else {
        state = state.copyWith(hasTested: true, isSuccess: false);
      }
    }
  }

  void resetLesson() {
    state = LessonOneState();
  }
}

// O autoDispose garante que a fase zera se a criança sair na metade
final lessonOneProvider =
    StateNotifierProvider.autoDispose<LessonOneController, LessonOneState>((
      ref,
    ) {
      return LessonOneController();
    });
