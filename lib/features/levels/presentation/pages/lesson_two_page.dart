import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:educaeasy_app/design_system/tokens/colors.dart';
import 'package:educaeasy_app/design_system/tokens/typography.dart';
import '../controllers/lesson_two_controller.dart';
import '../../../levels_map/domain/map_progress_provider.dart';

class LessonTwoPage extends ConsumerWidget {
  const LessonTwoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lessonTwoProvider);
    final controller = ref.read(lessonTwoProvider.notifier);

    ref.listen<LessonTwoState>(lessonTwoProvider, (previous, next) {
      if (next.isSuccess && (previous?.isSuccess != true)) {
        ref.read(mapProgressProvider.notifier).state = 3;
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
            const SizedBox(height: 24),

            Text(
              'Complete com a sequência correta arrastando os números:',
              style: AppTypography.title(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // O Expanded + ListView evitam o erro de Overflow no final da tela!
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSequenceRow(number: '1', isFixed: true, isLast: false),
                  _buildSequenceRow(number: '2', isFixed: true, isLast: false),

                  // O slot mágico número 3!
                  _buildSequenceRow(
                    isFixed: false,
                    isLast: false,
                    droppedValue: state.slotThree,
                    onAccept: (val) => controller.setSlotThree(val),
                  ),

                  _buildSequenceRow(number: '4', isFixed: true, isLast: false),
                  _buildSequenceRow(number: '5', isFixed: true, isLast: false),

                  // O slot mágico número 6!
                  _buildSequenceRow(
                    isFixed: false,
                    isLast: true,
                    droppedValue: state.slotSix,
                    onAccept: (val) => controller.setSlotSix(val),
                  ),
                ],
              ),
            ),

            // As opções que a criança vai arrastar
            if (!state.isSuccess) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildDraggableOption('3'),
                  _buildDraggableOption('6'),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Feedback Visual
            if (state.hasTested)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  state.isCorrect
                      ? 'Perfeito! A sequência está completa!'
                      : 'Ops! Tem algum número no lugar errado. Tente de novo!',
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
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: ElevatedButton(
                  onPressed: (state.slotThree == null || state.slotSix == null)
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
                        : 'Verificar Resposta',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // O componente que desenha a linha do tempo perfeita
  Widget _buildSequenceRow({
    String? number,
    required bool isFixed,
    required bool isLast,
    String? droppedValue,
    Function(String)? onAccept,
  }) {
    Widget boxWidget;

    // Se for um item fixo (1, 2, 4, 5)
    if (isFixed) {
      boxWidget = Container(
        height: 64, // Altura fixa para ficar bonito
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray20),
        ),
        child: Text(number!, style: AppTypography.title()),
      );
    }
    // Se for um item arrastável (3 e 6)
    else {
      boxWidget = DragTarget<String>(
        onAcceptWithDetails: (details) => onAccept!(details.data),
        builder: (context, candidateData, rejectedData) {
          return Container(
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: droppedValue != null
                  ? AppColors.purplePrimary
                  : AppColors.gray05,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: candidateData.isNotEmpty
                    ? AppColors.greenPrimary
                    : AppColors.purplePrimary.withOpacity(0.5),
                width: 2,
                style: droppedValue != null
                    ? BorderStyle.solid
                    : BorderStyle.solid,
              ),
            ),
            child: Text(
              droppedValue ?? 'Arraste o número aqui',
              style: AppTypography.body(
                color: droppedValue != null ? Colors.white : AppColors.gray40,
              ),
            ),
          );
        },
      );
    }

    return IntrinsicHeight(
      // O Segredo para a linha cinza ligar as bolinhas!
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // A Bolinha e a Linha
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 26),
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gray30,
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: AppColors.gray20)),
            ],
          ),
          const SizedBox(width: 24),

          // O Bloco da direita
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: boxWidget,
            ),
          ),
        ],
      ),
    );
  }

  // As "peças" que ficam soltas lá embaixo
  Widget _buildDraggableOption(String text) {
    return Draggable<String>(
      data: text,
      feedback: Material(
        color: Colors.transparent,
        child: _buildOptionBlock(
          text,
          AppColors.purplePrimary.withOpacity(0.8),
          Colors.white,
        ),
      ),
      childWhenDragging: _buildOptionBlock(
        text,
        AppColors.gray20,
        Colors.white,
      ),
      child: _buildOptionBlock(
        text,
        Colors.white,
        AppColors.purplePrimary,
      ).applyBorder(),
    );
  }

  Widget _buildOptionBlock(String text, Color bgColor, Color textColor) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(text, style: AppTypography.title(color: textColor)),
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
