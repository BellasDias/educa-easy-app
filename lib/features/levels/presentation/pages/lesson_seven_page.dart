import 'package:educaeasy_app/features/onboarding/data/firebase_auth_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:educaeasy_app/design_system/tokens/colors.dart';
import 'package:educaeasy_app/design_system/tokens/typography.dart';
import '../controllers/lesson_seven_controller.dart';
import 'package:educaeasy_app/features/levels_map/domain/map_progress_provider.dart';

class LessonSevenPage extends ConsumerWidget {
  const LessonSevenPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lessonSevenProvider);
    final controller = ref.read(lessonSevenProvider.notifier);

    ref.listen<LessonSevenState>(lessonSevenProvider, (previous, next) {
      if (next.isSuccess && (previous?.isSuccess != true)) {
        final currentProgress = ref.read(mapProgressProvider);

        if (currentProgress < 8) {
          ref.read(mapProgressProvider.notifier).updateProgress(8);

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

    // Todas as 5 opções que aparecerão no BottomSheet
    final options = [
      'Ir para Escola',
      'Lavar as Mãos',
      'Banho no Pet',
      'Fazer Sanduíche',
      'Arrumar a Cama',
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Nível 7', style: AppTypography.title()),
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
              value: state.isSuccess ? 1.0 : (state.answers.length / 5),
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
                  'Receitas Prontas (Funções)! Um comando mágico guarda vários passos dentro dele. Qual comando nós usamos para os passos abaixo?',
                  style: AppTypography.body(color: AppColors.gray80),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                _buildFunctionRow(
                  context: context,
                  id: 1,
                  steps: '1. Pegar o pão\n2. Colocar o queijo\n3. Fechar o pão',
                  selectedValue: state.answers[1],
                  controller: controller,
                  options: options,
                  icon: Icons.lunch_dining_rounded,
                  iconColor: AppColors.purplePrimary, // Tudo Roxo!
                ),

                _buildFunctionRow(
                  context: context,
                  id: 2,
                  steps: '1. Ligar a torneira\n2. Passar sabonete\n3. Enxugar',
                  selectedValue: state.answers[2],
                  controller: controller,
                  options: options,
                  icon: Icons.wash_rounded,
                  iconColor: AppColors.purplePrimary,
                ),

                _buildFunctionRow(
                  context: context,
                  id: 3,
                  steps:
                      '1. Vestir uniforme\n2. Pegar mochila\n3. Entrar no ônibus',
                  selectedValue: state.answers[3],
                  controller: controller,
                  options: options,
                  icon: Icons.directions_bus_rounded,
                  iconColor: AppColors.purplePrimary,
                ),

                _buildFunctionRow(
                  context: context,
                  id: 4,
                  steps: '1. Esticar o lençol\n2. Bater o travesseiro',
                  selectedValue: state.answers[4],
                  controller: controller,
                  options: options,
                  icon: Icons.bed_rounded,
                  iconColor: AppColors.purplePrimary,
                ),

                _buildFunctionRow(
                  context: context,
                  id: 5,
                  steps:
                      '1. Pegar a mangueira\n2. Passar shampoo\n3. Esfregar o pelo',
                  selectedValue: state.answers[5],
                  controller: controller,
                  options: options,
                  icon: Icons.pets_rounded,
                  iconColor: AppColors.purplePrimary,
                ),
              ],
            ),
          ),

          // Rodapé
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
                          ? 'Sensacional! Você criou suas próprias funções!'
                          : 'Ops! Tem alguma receita trocada. Revise os comandos.',
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
                      onPressed: state.answers.length < 5
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
                            : 'Verificar Comandos',
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

  Widget _buildFunctionRow({
    required BuildContext context,
    required int id,
    required String steps,
    required String? selectedValue,
    required LessonSevenController controller,
    required List<String> options,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray05,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  steps,
                  style: AppTypography.body(color: AppColors.gray70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedValue ?? 'Qual é o Comando?',
                    style: AppTypography.button(
                      color: selectedValue != null
                          ? Colors.white
                          : AppColors.purplePrimary,
                    ),
                  ),
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

  void _showOptionsSheet(
    BuildContext context,
    int id,
    List<String> options,
    LessonSevenController controller,
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
                'Escolha o Comando Correto:',
                style: AppTypography.title(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: options
                    .map(
                      (opt) => GestureDetector(
                        onTap: () {
                          controller.updateAnswer(id, opt);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
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
