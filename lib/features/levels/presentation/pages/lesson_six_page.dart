import 'package:educaeasy_app/features/onboarding/data/firebase_auth_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:educaeasy_app/design_system/tokens/colors.dart';
import 'package:educaeasy_app/design_system/tokens/typography.dart';
import '../controllers/lesson_six_controller.dart';
import 'package:educaeasy_app/features/levels_map/domain/map_progress_provider.dart';

class LessonSixPage extends ConsumerWidget {
  const LessonSixPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lessonSixProvider);
    final controller = ref.read(lessonSixProvider.notifier);

    ref.listen<LessonSixState>(lessonSixProvider, (previous, next) {
      if (next.isSuccess && (previous?.isSuccess != true)) {
        final currentProgress = ref.read(mapProgressProvider);

        if (currentProgress < 7) {
          ref.read(mapProgressProvider.notifier).updateProgress(7);

          final authRepository = FirebaseAuthRepositoryImpl(
            FirebaseAuth.instance,
          );
          authRepository.addCoins(50);
        }

        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) context.pop();
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Nível 6', style: AppTypography.title()),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: LinearProgressIndicator(
              value: state.isSuccess ? 1.0 : (state.answers.length / 8),
              backgroundColor: AppColors.gray20,
              color: AppColors.purplePrimary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              physics: const BouncingScrollPhysics(),
              children: [
                Text(
                  'Rotina de Repetição! Nós chamamos de "Laços" aquilo que repetimos várias vezes ou até terminar. Arraste as opções:',
                  style: AppTypography.body(color: AppColors.gray80),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                _buildQuestionRow(
                  1,
                  'ENQUANTO o dente não estiver limpo:',
                  state.answers[1],
                  controller,
                  Icons.clean_hands_rounded,
                ),
                _buildQuestionRow(
                  2,
                  'REPETIR 5 vezes no pula-pula:',
                  state.answers[2],
                  controller,
                  Icons.directions_run_rounded,
                ),
                _buildQuestionRow(
                  3,
                  'ENQUANTO o quarto estiver bagunçado:',
                  state.answers[3],
                  controller,
                  Icons.bed_rounded,
                ),
                _buildQuestionRow(
                  4,
                  'PARA CADA prato sujo na pia:',
                  state.answers[4],
                  controller,
                  Icons.restaurant_rounded,
                ),
                _buildQuestionRow(
                  5,
                  'ATÉ o celular carregar 100%:',
                  state.answers[5],
                  controller,
                  Icons.battery_charging_full_rounded,
                ),
                _buildQuestionRow(
                  6,
                  'ENQUANTO o bolo estiver cru:',
                  state.answers[6],
                  controller,
                  Icons.cake_rounded,
                ),
                _buildQuestionRow(
                  7,
                  'PARA CADA plantinha no jardim:',
                  state.answers[7],
                  controller,
                  Icons.local_florist_rounded,
                ),
                _buildQuestionRow(
                  8,
                  'ATÉ o sinal da escola tocar:',
                  state.answers[8],
                  controller,
                  Icons.school_rounded,
                ),
              ],
            ),
          ),

          // Rodapé: Carrossel de Opções e Botão de Teste
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.gray20,
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Carrossel de Drag and Drop
                if (!state.isSuccess && state.availableOptions.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Seta para Esquerda
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded),
                        color: state.carouselIndex > 0
                            ? AppColors.purplePrimary
                            : AppColors.gray20,
                        onPressed: state.carouselIndex > 0
                            ? () => controller.prevCarousel()
                            : null,
                      ),

                      // Mostra 2 opções (ou 1 se for a última)
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (state.availableOptions.length >
                                state.carouselIndex)
                              _buildDraggableOption(
                                state.availableOptions[state.carouselIndex],
                              ),

                            if (state.availableOptions.length >
                                state.carouselIndex + 1)
                              _buildDraggableOption(
                                state.availableOptions[state.carouselIndex + 1],
                              ),
                          ],
                        ),
                      ),

                      // Seta para Direita
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded),
                        color:
                            state.carouselIndex + 2 <
                                state.availableOptions.length
                            ? AppColors.purplePrimary
                            : AppColors.gray20,
                        onPressed:
                            state.carouselIndex + 2 <
                                state.availableOptions.length
                            ? () => controller.nextCarousel()
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Feedback e Botão Verificar
                if (state.hasTested)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      state.isCorrect
                          ? 'Muito bem! Você entendeu como os laços de repetição funcionam!'
                          : 'Ops! Tem alguma repetição que não faz sentido. Tire a errada e tente de novo.',
                      style: AppTypography.title(
                        color: state.isCorrect
                            ? AppColors.greenDark
                            : AppColors.redDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                if (!state.isSuccess)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.answers.length < 8
                          ? null
                          : () {
                              if (state.hasTested && !state.isCorrect) {
                                controller.resetLesson();
                              } else {
                                controller.testAnswer();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: state.hasTested && !state.isCorrect
                            ? AppColors.redPrimary
                            : AppColors.purplePrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        state.hasTested && !state.isCorrect
                            ? 'Refazer Tudo'
                            : 'Verificar Respostas',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionRow(
    int id,
    String label,
    String? droppedValue,
    LessonSixController controller,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray05,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.purplePrimary, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.body(color: AppColors.gray80),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: DragTarget<String>(
                  onAcceptWithDetails: (details) =>
                      controller.updateAnswer(id, details.data),
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: droppedValue != null
                            ? AppColors.purplePrimary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: candidateData.isNotEmpty
                              ? AppColors.greenPrimary
                              : AppColors.gray30,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        droppedValue ?? 'Arraste a repetição aqui',
                        style: AppTypography.button(
                          color: droppedValue != null
                              ? Colors.white
                              : AppColors.gray40,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Botão de REMOVER (X vermelho) só aparece se houver resposta
              if (droppedValue != null) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => controller.removeAnswer(id),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.redPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.redPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableOption(String text) {
    return Draggable<String>(
      data: text,
      feedback: Material(
        color: Colors.transparent,
        child: _buildBlock(
          text,
          AppColors.purplePrimary.withOpacity(0.8),
          Colors.white,
        ),
      ),
      childWhenDragging: _buildBlock(text, AppColors.gray20, Colors.white),
      child: _buildBlock(
        text,
        Colors.white,
        AppColors.purplePrimary,
      ).applyBorder(),
    );
  }

  Widget _buildBlock(String text, Color bgColor, Color textColor) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 120, minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: AppTypography.button(color: textColor),
        textAlign: TextAlign.center,
      ),
    );
  }
}

extension on Widget {
  Widget applyBorder() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.purplePrimary, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: this,
    );
  }
}
