import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:educaeasy_app/design_system/tokens/colors.dart';
import 'package:educaeasy_app/design_system/tokens/typography.dart';
import '../controllers/lesson_one_controller.dart';
// ⚠️ Ajuste o caminho abaixo para onde está o seu map_progress_provider
import '../../../levels_map/domain/map_progress_provider.dart';

class LessonOnePage extends ConsumerWidget {
  const LessonOnePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lessonOneProvider);
    final controller = ref.read(lessonOneProvider.notifier);

    // O "Ouvinte Mágico" da Fase 1
    ref.listen<LessonOneState>(lessonOneProvider, (previous, next) {
      if (next.isSuccess && (previous?.isSuccess != true)) {
        // 1. Libera a Fase 2 no mapa global!
        ref.read(mapProgressProvider.notifier).state = 2;

        // 2. Espera 3 segundos e volta pro mapa
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) {
            context.pop();
          }
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Nível 1', style: AppTypography.title()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: state.isSuccess ? 1.0 : 0.5,
              backgroundColor: AppColors.gray20,
              color: AppColors.purplePrimary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 32),

            Text(
              'Tudo tem uma ordem certa! Qual é o próximo passo correto antes de amarrar o cadarço?',
              style: AppTypography.body(color: AppColors.gray80),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // O Visual de "Sequência / Lista"
            _buildFixedStep('1', 'Colocar as meias'),
            const SizedBox(height: 16),

            // O Slot interativo da Fase 1
            _buildInteractiveStep(
              '2',
              state.droppedItem,
              (item) => controller.setDroppedItem(item),
            ),
            const SizedBox(height: 16),

            _buildFixedStep('3', 'Amarrar o cadarço'),

            const Spacer(),

            // Opções Arrastáveis
            if (!state.isSuccess) ...[
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildDraggableOption('🔗 Calçar o sapato'),
                  _buildDraggableOption('🔗 Colocar o chapéu'),
                  _buildDraggableOption('🔗 Lavar as mãos'),
                ],
              ),
              const SizedBox(height: 40),
            ],

            // Feedback Visual
            if (state.hasTested)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  state.isCorrect
                      ? 'Muito bem! Você seguiu a ordem correta!'
                      : 'Ops! Será que amarramos o cadarço no chapéu? Tente outra vez.',
                  style: AppTypography.title(
                    color: state.isCorrect
                        ? AppColors.greenDark
                        : AppColors.redDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Botão Testar / Refazer
            if (!state.isSuccess)
              ElevatedButton(
                onPressed: state.droppedItem == null
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
                      ? 'Tentar Novamente'
                      : 'Testar',
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget para os passos que já estão preenchidos na tela (Meia e Cadarço)
  Widget _buildFixedStep(String number, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          child: Text(
            number,
            style: AppTypography.title(color: AppColors.gray30),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: _buildCodeBlock(text, AppColors.purplePrimary)),
      ],
    );
  }

  // Widget interativo (DragTarget) para o passo que falta
  Widget _buildInteractiveStep(
    String number,
    String? droppedItem,
    Function(String) onAccept,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          child: Text(
            number,
            style: AppTypography.title(color: AppColors.gray30),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DragTarget<String>(
            onAcceptWithDetails: (details) => onAccept(details.data),
            builder: (context, candidateData, rejectedData) {
              return Container(
                height: 48,
                decoration: BoxDecoration(
                  color: droppedItem != null
                      ? AppColors.purplePrimary
                      : AppColors.gray10,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: candidateData.isNotEmpty
                        ? AppColors.greenPrimary
                        : Colors.transparent,
                    width: 2,
                  ),
                  // Uma borda tracejada ficaria legal aqui no futuro se for um espaço vazio!
                ),
                alignment: Alignment.center,
                child: Text(
                  droppedItem ?? 'Arraste a próxima ação aqui',
                  style: AppTypography.button(
                    color: droppedItem != null
                        ? Colors.white
                        : AppColors.gray50,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCodeBlock(String text, Color bgColor, {Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: AppTypography.button(color: textColor ?? Colors.white),
      ),
    );
  }

  Widget _buildDraggableOption(String text) {
    return Draggable<String>(
      data: text.replaceAll('🔗 ', ''),
      feedback: Material(
        color: Colors.transparent,
        child: _buildCodeBlock(text, AppColors.purplePrimary.withOpacity(0.8)),
      ),
      childWhenDragging: _buildCodeBlock(text, AppColors.gray20),
      child: _buildCodeBlock(
        text,
        Colors.white,
        textColor: AppColors.purplePrimary,
      ).applyBorder(),
    );
  }
}

extension on Widget {
  Widget applyBorder() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.purplePrimary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: this,
    );
  }
}
