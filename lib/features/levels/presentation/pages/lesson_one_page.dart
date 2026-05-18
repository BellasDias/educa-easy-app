import 'package:educaeasy_app/features/onboarding/data/firebase_auth_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:educaeasy_app/design_system/tokens/colors.dart';
import 'package:educaeasy_app/design_system/tokens/typography.dart';
import '../controllers/lesson_one_controller.dart';
import '../../../levels_map/domain/map_progress_provider.dart';

class LessonOnePage extends ConsumerWidget {
  const LessonOnePage({super.key});

  // Função auxiliar para descobrir qual ícone usar com base na ação
  IconData _getIconForItem(String item) {
    switch (item) {
      case 'Colocar as meias':
        return Icons.checkroom_rounded; // Ícone de guarda-roupa/vestuário
      case 'Amarrar o cadarço':
        return Icons.all_inclusive_rounded; // Lembra um nó/laço
      case 'Calçar o sapato':
        return Icons.directions_walk_rounded; // Ícone de caminhada/sapato
      case 'Colocar o chapéu':
        return Icons.face_rounded; // Rosto/Cabeça
      case 'Lavar as mãos':
        return Icons.clean_hands_rounded; // Lavar as mãos
      default:
        return Icons.extension_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lessonOneProvider);
    final controller = ref.read(lessonOneProvider.notifier);

    ref.listen<LessonOneState>(lessonOneProvider, (previous, next) {
      if (next.isSuccess && (previous?.isSuccess != true)) {
        final currentProgress = ref.read(mapProgressProvider);

        if (currentProgress < 2) {
          // 🔄 MUDOU AQUI: Usando o nosso novo método que salva na nuvem!
          ref.read(mapProgressProvider.notifier).updateProgress(2);

          // 💰 GERA A RECOMPENSA NO BANCO DE DADOS (50 MOEDAS)
          final authRepository = FirebaseAuthRepositoryImpl(
            FirebaseAuth.instance,
          );
          authRepository.addCoins(50);
        }

        // Espera 3 segundos e volta pro mapa
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

            // O Visual de "Sequência / Lista" (Agora com cores e ícones!)
            _buildFixedStep('1', 'Colocar as meias', Colors.blue.shade600),
            const SizedBox(height: 16),

            // O Slot interativo da Fase 1 (Laranja para chamar atenção)
            _buildInteractiveStep(
              '2',
              state.droppedItem,
              (item) => controller.setDroppedItem(item),
              Colors.orange.shade600,
            ),
            const SizedBox(height: 16),

            _buildFixedStep('3', 'Amarrar o cadarço', Colors.green.shade600),

            const Spacer(),

            // Opções Arrastáveis (Sem a corrente e com os ícones automáticos)
            if (!state.isSuccess) ...[
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildDraggableOption('Calçar o sapato'),
                  _buildDraggableOption('Colocar o chapéu'),
                  _buildDraggableOption('Lavar as mãos'),
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

  // Widget para os passos que já estão preenchidos na tela (Recebe a cor do tema e o ícone)
  Widget _buildFixedStep(String number, String text, Color themeColor) {
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
          child: _buildCodeBlock(text, themeColor, icon: _getIconForItem(text)),
        ),
      ],
    );
  }

  // Widget interativo (DragTarget) para o passo que falta
  Widget _buildInteractiveStep(
    String number,
    String? droppedItem,
    Function(String) onAccept,
    Color themeColor,
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
                child: droppedItem != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getIconForItem(droppedItem),
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            droppedItem,
                            style: AppTypography.button(color: Colors.white),
                          ),
                        ],
                      )
                    : Text(
                        'Arraste a próxima ação aqui',
                        style: AppTypography.button(color: AppColors.gray50),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Bloco atualizado com suporte ao ícone
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
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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

  // Opções arrastáveis gerando o ícone dinamicamente
  Widget _buildDraggableOption(String text) {
    final icon = _getIconForItem(text);
    return Draggable<String>(
      data: text, // O valor real sem emoji
      feedback: Material(
        color: Colors.transparent,
        child: _buildCodeBlock(
          text,
          AppColors.purplePrimary.withOpacity(0.8),
          icon: icon,
        ),
      ),
      childWhenDragging: _buildCodeBlock(text, AppColors.gray20, icon: icon),
      child: _buildCodeBlock(
        text,
        Colors.white,
        textColor: AppColors.purplePrimary,
        icon: icon,
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
