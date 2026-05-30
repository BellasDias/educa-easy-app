import 'package:educaeasy_app/features/onboarding/data/firebase_auth_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:educaeasy_app/design_system/tokens/colors.dart';
import 'package:educaeasy_app/design_system/tokens/typography.dart';
import '../controllers/lesson_four_controller.dart';
import 'package:educaeasy_app/features/levels_map/domain/map_progress_provider.dart';

class LessonFourPage extends ConsumerWidget {
  const LessonFourPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lessonFourProvider);
    final controller = ref.read(lessonFourProvider.notifier);

    ref.listen<LessonFourState>(lessonFourProvider, (previous, next) {
      if (next.isSuccess && (previous?.isSuccess != true)) {
        final currentProgress = ref.read(mapProgressProvider);

        if (currentProgress < 5) {
          ref.read(mapProgressProvider.notifier).updateProgress(5);

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

    // Os 3 grupos de opções separados!
    final seOptions = ['Boné', 'Guarda-chuva', 'Casaco'];
    final eOptions = ['Escova', 'Comida', 'Livro'];
    final ouOptions = ['Sabonete', 'Brincar', 'Protetor'];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Nível 4', style: AppTypography.title()),
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
              value: state.isSuccess ? 1.0 : (state.answers.length / 9),
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
                  'As nossas escolhas dependem do que acontece! Toque no botão e escolha a ação correta.',
                  style: AppTypography.body(color: AppColors.gray80),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // ---------------- GRUPO 1: LÓGICA "SE" ----------------
                _buildCategoryHeader(
                  '1. Apenas uma condição (SE)',
                  Icons.filter_1_rounded,
                ),
                _buildConditionRow(
                  context,
                  1,
                  'SE começar a chover:',
                  state.answers[1],
                  controller,
                  Icons.umbrella_rounded,
                  Colors.blue,
                  seOptions,
                ),
                _buildConditionRow(
                  context,
                  2,
                  'SE estiver muito frio:',
                  state.answers[2],
                  controller,
                  Icons.ac_unit_rounded,
                  Colors.cyan,
                  seOptions,
                ),
                _buildConditionRow(
                  context,
                  3,
                  'SE fizer muito sol:',
                  state.answers[3],
                  controller,
                  Icons.wb_sunny_rounded,
                  Colors.orange,
                  seOptions,
                ),
                const SizedBox(height: 32),

                // ---------------- GRUPO 2: LÓGICA "E" ----------------
                _buildCategoryHeader(
                  '2. Os dois precisam acontecer (E)',
                  Icons.filter_2_rounded,
                ),
                _buildConditionRow(
                  context,
                  4,
                  'SE for de noite E o dente sujar:',
                  state.answers[4],
                  controller,
                  Icons.nightlight_round,
                  Colors.indigo,
                  eOptions,
                ),
                _buildConditionRow(
                  context,
                  5,
                  'SE acordar E a barriga roncar:',
                  state.answers[5],
                  controller,
                  Icons.restaurant_rounded,
                  Colors.red,
                  eOptions,
                ),
                _buildConditionRow(
                  context,
                  6,
                  'SE tiver prova E precisar estudar:',
                  state.answers[6],
                  controller,
                  Icons.school_rounded,
                  Colors.green,
                  eOptions,
                ),
                const SizedBox(height: 32),

                // ---------------- GRUPO 3: LÓGICA "OU" ----------------
                _buildCategoryHeader(
                  '3. Basta um acontecer (OU)',
                  Icons.filter_3_rounded,
                ),
                _buildConditionRow(
                  context,
                  7,
                  'SE sujar a mão de lama OU tinta:',
                  state.answers[7],
                  controller,
                  Icons.wash_rounded,
                  Colors.teal,
                  ouOptions,
                ),
                _buildConditionRow(
                  context,
                  8,
                  'SE for Sábado OU Domingo:',
                  state.answers[8],
                  controller,
                  Icons.celebration_rounded,
                  Colors.purple,
                  ouOptions,
                ),
                _buildConditionRow(
                  context,
                  9,
                  'SE for Praia OU Piscina:',
                  state.answers[9],
                  controller,
                  Icons.pool_rounded,
                  Colors.lightBlue,
                  ouOptions,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Rodapé Fixo apenas com o Botão de Verificar
          Container(
            padding: const EdgeInsets.all(24.0),
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
                if (state.hasTested)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      state.isCorrect
                          ? 'Incrível! Você domina a lógica das escolhas!'
                          : 'Ops! Revise as opções, alguma não combinou bem.',
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
                      onPressed: state.answers.length < 9
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
                            : 'Verificar Escolhas',
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

  Widget _buildCategoryHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.purplePrimary),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: AppTypography.title())),
        ],
      ),
    );
  }

  Widget _buildConditionRow(
    BuildContext context,
    int id,
    String label,
    String? selectedValue,
    LessonFourController controller,
    IconData icon,
    Color iconColor,
    List<String> options,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray05,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTypography.body(color: AppColors.gray80),
            ),
          ),
          const SizedBox(width: 8),

          // O NOVO BOTÃO DE ESCOLHA (Substituiu o DragTarget)
          GestureDetector(
            onTap: () => _showOptionsSheet(context, id, options, controller),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selectedValue != null
                    ? AppColors.purplePrimary
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedValue != null
                      ? AppColors.purplePrimary
                      : AppColors.purplePrimary.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedValue ?? 'Escolher',
                    style: AppTypography.button(
                      color: selectedValue != null
                          ? Colors.white
                          : AppColors.purplePrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: selectedValue != null
                        ? Colors.white
                        : AppColors.purplePrimary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // A GAVETA DE OPÇÕES QUE SOBE DA BASE DA TELA
  void _showOptionsSheet(
    BuildContext context,
    int id,
    List<String> options,
    LessonFourController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray20,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Escolha a melhor opção:',
                style: AppTypography.title(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: options
                    .map(
                      (opt) => GestureDetector(
                        onTap: () {
                          controller.updateAnswer(id, opt); // Salva a resposta
                          Navigator.pop(context); // Fecha a gaveta
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.purplePrimary,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            opt,
                            style: AppTypography.button(
                              color: AppColors.purplePrimary,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
