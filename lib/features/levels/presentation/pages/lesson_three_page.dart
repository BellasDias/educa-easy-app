import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:educaeasy_app/design_system/tokens/colors.dart';
import 'package:educaeasy_app/design_system/tokens/typography.dart';
import '../controllers/lesson_three_controller.dart';
import '../../../levels_map/domain/map_progress_provider.dart';

class LessonThreePage extends ConsumerWidget {
  const LessonThreePage({super.key});

  // Função auxiliar para descobrir qual ícone usar com base na palavra
  IconData _getIconForItem(String item) {
    switch (item) {
      case 'Maçã':
        return Icons.apple;
      case 'Caderno':
        return Icons.menu_book_rounded;
      case 'Pular':
        return Icons.directions_run_rounded;
      default:
        return Icons.extension_rounded; // Ícone genérico caso não ache
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lessonThreeProvider);
    final controller = ref.read(lessonThreeProvider.notifier);

    // O "Ouvinte Mágico"
    ref.listen<LessonThreeState>(lessonThreeProvider, (previous, next) {
      if (next.isSuccess && (previous?.isSuccess != true)) {
        final currentProgress = ref.read(mapProgressProvider);
        if (currentProgress < 4) {
          ref.read(mapProgressProvider.notifier).state = 4;
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
        title: Text('Nível 3', style: AppTypography.title()),
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
              'Coloque dentro do recipiente o objeto correspondente.',
              style: AppTypography.body(color: AppColors.gray80),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Linha 1: Lancheira (Agora Laranja!)
            _buildCodeLine(
              number: '1',
              variableName: 'Lancheira',
              droppedItem: state.lancheiraItem,
              onAccept: (item) => controller.setLancheiraItem(item),
              themeColor: Colors.orange.shade600,
            ),
            const SizedBox(height: 24),

            // Linha 2: Bolsa (Agora Azul!)
            _buildCodeLine(
              number: '2',
              variableName: 'Bolsa',
              droppedItem: state.bolsaItem,
              onAccept: (item) => controller.setBolsaItem(item),
              themeColor: Colors.blue.shade600,
            ),

            const Spacer(),

            // Opções Arrastáveis (Sem a corrente e com o ícone correspondente)
            if (!state.isSuccess) ...[
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildDraggableOption('Maçã'),
                  _buildDraggableOption('Caderno'),
                  _buildDraggableOption('Pular'),
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

  // Recebe uma themeColor para diferenciar as variáveis
  Widget _buildCodeLine({
    required String number,
    required String variableName,
    required String? droppedItem,
    required Function(String) onAccept,
    required Color themeColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(number, style: AppTypography.title(color: AppColors.gray30)),
        const SizedBox(width: 16),
        _buildCodeBlock(variableName, themeColor), // Variável usa a cor do tema
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
              width:
                  130, // Aumentei um pouco para caber o ícone + texto folgado
              height: 48,
              decoration: BoxDecoration(
                // Se preenchido, usa a cor da variável. Se vazio, fica cinza
                color: droppedItem != null ? themeColor : AppColors.gray10,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: candidateData.isNotEmpty
                      ? AppColors.greenPrimary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              // Se tiver um item, mostra o ícone e o texto. Se não, mostra reticências.
              child: droppedItem != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getIconForItem(droppedItem),
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          droppedItem,
                          style: AppTypography.button(color: Colors.white),
                        ),
                      ],
                    )
                  : Text(
                      '...',
                      style: AppTypography.button(color: AppColors.gray50),
                    ),
            );
          },
        ),
      ],
    );
  }

  // O _buildCodeBlock agora aceita um IconData opcional!
  Widget _buildCodeBlock(
    String text,
    Color bgColor, {
    Color? textColor,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor ?? Colors.white, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: AppTypography.button(color: textColor ?? Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableOption(String text) {
    final icon = _getIconForItem(text); // Pega o ícone certo
    return Draggable<String>(
      data: text, // Envia apenas a palavra pura
      feedback: Material(
        color: Colors.transparent,
        child: _buildCodeBlock(
          text,
          AppColors.purplePrimary.withOpacity(0.8),
          icon: icon, // Mostra o ícone enquanto arrasta
        ),
      ),
      childWhenDragging: _buildCodeBlock(text, AppColors.gray20, icon: icon),
      child: _buildCodeBlock(
        text,
        Colors.white,
        textColor: AppColors.purplePrimary,
        icon: icon, // Mostra o ícone na pecinha solta
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
