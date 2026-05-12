import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:educaeasy_app/design_system/tokens/colors.dart';
import 'package:educaeasy_app/design_system/tokens/typography.dart';
import '../controllers/lesson_three_controller.dart';
// IMPORTANTE: Importe o arquivo de progresso que acabamos de criar! Ajuste o caminho.
import '../../../levels_map/domain/map_progress_provider.dart';

class LessonThreePage extends ConsumerWidget {
  const LessonThreePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lessonThreeProvider);
    final controller = ref.read(lessonThreeProvider.notifier);

    // O "Ouvinte Mágico": Quando a fase for vencida, ele age!
    ref.listen<LessonThreeState>(lessonThreeProvider, (previous, next) {
      if (next.isSuccess && (previous?.isSuccess != true)) {
        // 1. Libera a Fase 4 no mapa global!
        ref.read(mapProgressProvider.notifier).state = 4;

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
        title: Text('Nível 3', style: AppTypography.title()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: state.isSuccess ? 1.0 : 0.5, // Enche a barra se ganhar
              backgroundColor: AppColors.gray20,
              color: AppColors.purplePrimary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 32),

            Text(
              'Coloque dentro do recipiente o objeto correspondente.',
              style: AppTypography.body(color: AppColors.gray80),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Linha 1: Lancheira
            _buildCodeLine(
              number: '1',
              variableName: 'Lancheira',
              droppedItem: state.lancheiraItem,
              onAccept: (item) => controller.setLancheiraItem(item),
            ),
            const SizedBox(height: 24),

            // Linha 2: Bolsa
            _buildCodeLine(
              number: '2',
              variableName: 'Bolsa',
              droppedItem: state.bolsaItem,
              onAccept: (item) => controller.setBolsaItem(item),
            ),

            const Spacer(),

            // Opções Arrastáveis (Agora com cores corretas!)
            if (!state.isSuccess) ...[
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildDraggableOption('🔗 Maçã'),
                  _buildDraggableOption('🔗 Caderno'),
                  _buildDraggableOption('🔗 Pular'),
                ],
              ),
              const SizedBox(height: 40),
            ],

            // Feedback Visual (Sucesso ou Erro)
            if (state.hasTested)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  state.isCorrect
                      ? 'Perfeito! Fase concluída!\nVoltando ao mapa...'
                      : 'Ops! Verifique se os itens estão nas caixas corretas.',
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
                onPressed:
                    (state.lancheiraItem == null || state.bolsaItem == null)
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

  // Novo widget para organizar as linhas de código
  Widget _buildCodeLine({
    required String number,
    required String variableName,
    required String? droppedItem,
    required Function(String) onAccept,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(number, style: AppTypography.title(color: AppColors.gray30)),
        const SizedBox(width: 16),
        _buildCodeBlock(variableName, AppColors.purplePrimary),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            '=',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        DragTarget<String>(
          onAcceptWithDetails: (details) => onAccept(details.data),
          builder: (context, candidateData, rejectedData) {
            return Container(
              width: 120,
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
              ),
              alignment: Alignment.center,
              child: Text(
                droppedItem ?? '🔗 ...',
                style: AppTypography.button(
                  color: droppedItem != null ? Colors.white : AppColors.gray50,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // O parâmetro textColor resolveu o bug do texto branco no fundo branco!
  Widget _buildCodeBlock(String text, Color bgColor, {Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
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
      // Passando a cor roxa para o texto quando a opção está solta!
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
