import 'package:educaeasy_app/features/onboarding/data/firebase_auth_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:educaeasy_app/design_system/tokens/colors.dart';
import 'package:educaeasy_app/design_system/tokens/typography.dart';
import '../controllers/lesson_five_controller.dart';
import 'package:educaeasy_app/features/levels_map/domain/map_progress_provider.dart';

class LessonFivePage extends ConsumerWidget {
  const LessonFivePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lessonFiveProvider);
    final controller = ref.read(lessonFiveProvider.notifier);

    ref.listen<LessonFiveState>(lessonFiveProvider, (previous, next) {
      if (next.isSuccess && (previous?.isSuccess != true)) {
        final currentProgress = ref.read(mapProgressProvider);

        if (currentProgress < 6) {
          ref.read(mapProgressProvider.notifier).updateProgress(6);

          final authRepository = FirebaseAuthRepositoryImpl(
            FirebaseAuth.instance,
          );
          authRepository.addCoins(100);
        }

        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) context.pop();
        });
      }
    });

    final stageTitles = [
      '1. Lançamento',
      '2. Rota',
      '3. Bagagem',
      '4. Emergências',
    ];

    return Scaffold(
      backgroundColor: AppColors.gray05,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Missão Espacial',
          style: AppTypography.title(color: AppColors.purplePrimary),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Barra de Progresso das 4 Etapas
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: List.generate(4, (index) {
                final isActive = index <= state.currentStage;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.purplePrimary
                          : AppColors.gray20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),

          Text(stageTitles[state.currentStage], style: AppTypography.title()),
          const SizedBox(height: 16),

          // O Conteúdo muda dependendo da Etapa atual
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gray20,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: _buildCurrentStageContent(context, state, controller),
              ),
            ),
          ),

          // Rodapé com Botões de Navegação
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                if (state.hasTested)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      state.isSuccess
                          ? 'DECOLAGEM AUTORIZADA! Desafio Concluído!'
                          : 'Alerta! Existe um erro em alguma das etapas. Volte e revise os painéis!',
                      style: AppTypography.title(
                        color: state.isSuccess
                            ? AppColors.greenDark
                            : AppColors.redDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                Row(
                  children: [
                    if (state.currentStage > 0 && !state.isSuccess)
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () => controller.previousStage(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Icon(Icons.arrow_back),
                        ),
                      ),
                    if (state.currentStage > 0 && !state.isSuccess)
                      const SizedBox(width: 16),

                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        // Desabilita se a etapa não estiver preenchida
                        onPressed: state.isCurrentStageFilled
                            ? () {
                                if (state.currentStage < 3) {
                                  controller.nextStage();
                                } else {
                                  controller.testFinalChallenge();
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state.hasTested && !state.isSuccess
                              ? AppColors.redPrimary
                              : AppColors.purplePrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          state.currentStage < 3
                              ? 'Próximo Painel'
                              : (state.hasTested && !state.isSuccess
                                    ? 'Tentar Novamente'
                                    : 'Iniciar Lançamento!'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Função que decide qual tela renderizar
  Widget _buildCurrentStageContent(
    BuildContext context,
    LessonFiveState state,
    LessonFiveController controller,
  ) {
    switch (state.currentStage) {
      case 0:
        return _buildStageOne(context, state, controller);
      case 1:
        return _buildStageTwo(state, controller);
      case 2:
        return _buildStageThree(context, state, controller);
      case 3:
        return _buildStageFour(context, state, controller);
      default:
        return const SizedBox();
    }
  }

  // --- TELA 1: SEQUÊNCIA ---
  Widget _buildStageOne(
    BuildContext context,
    LessonFiveState state,
    LessonFiveController controller,
  ) {
    final opts = ['Entrar na Nave', 'Ligar os Motores', 'Vestir o Traje'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.rocket_launch_rounded,
          size: 64,
          color: AppColors.purplePrimary,
        ),
        const SizedBox(height: 16),
        Text(
          'Qual é a ordem certa para decolar?',
          style: AppTypography.body(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildSelector(
          context,
          'Passo 1:',
          state.answers['seq1'],
          opts,
          (val) => controller.updateAnswer('seq1', val),
        ),
        _buildSelector(
          context,
          'Passo 2:',
          state.answers['seq2'],
          opts,
          (val) => controller.updateAnswer('seq2', val),
        ),
        _buildSelector(
          context,
          'Passo 3:',
          state.answers['seq3'],
          opts,
          (val) => controller.updateAnswer('seq3', val),
        ),
      ],
    );
  }

  // --- TELA 2: NÚMEROS ---
  Widget _buildStageTwo(
    LessonFiveState state,
    LessonFiveController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.route_rounded,
          size: 64,
          color: AppColors.greenPrimary,
        ),
        const SizedBox(height: 16),
        Text(
          'A nave viaja de 5 em 5 anos-luz. Complete a rota!',
          style: AppTypography.body(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_buildFixedNum('5'), _buildArrow(), _buildFixedNum('10')],
        ),
        const SizedBox(height: 16),
        _buildNumInput('num1', state.answers['num1'], controller),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_buildArrow(), _buildFixedNum('20'), _buildArrow()],
        ),
        const SizedBox(height: 16),
        _buildNumInput('num2', state.answers['num2'], controller),
        const SizedBox(height: 16),
        _buildNumInput('num3', state.answers['num3'], controller),
      ],
    );
  }

  // --- TELA 3: VARIÁVEIS ---
  Widget _buildStageThree(
    BuildContext context,
    LessonFiveState state,
    LessonFiveController controller,
  ) {
    final opts = ['Bateria', 'Comida', 'Rádio'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.inventory_2_rounded, size: 64, color: Colors.orange),
        const SizedBox(height: 16),
        Text(
          'Guarde os itens nas caixas (variáveis) corretas:',
          style: AppTypography.body(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildSelector(
          context,
          'Variável [Energia]',
          state.answers['var1'],
          opts,
          (val) => controller.updateAnswer('var1', val),
        ),
        _buildSelector(
          context,
          'Variável [Alimentação]',
          state.answers['var2'],
          opts,
          (val) => controller.updateAnswer('var2', val),
        ),
        _buildSelector(
          context,
          'Variável [Comunicação]',
          state.answers['var3'],
          opts,
          (val) => controller.updateAnswer('var3', val),
        ),
      ],
    );
  }

  // --- TELA 4: CONDICIONAIS ---
  Widget _buildStageFour(
    BuildContext context,
    LessonFiveState state,
    LessonFiveController controller,
  ) {
    final opts1 = ['Desviar', 'Acelerar'];
    final opts2 = ['Atirar', 'Acenar'];
    final opts3 = ['Apertar Botão', 'Dormir'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.warning_rounded, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        Text(
          'Decisões de emergência! O que fazer?',
          style: AppTypography.body(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildSelector(
          context,
          'SE ver um meteoro:',
          state.answers['cond1'],
          opts1,
          (val) => controller.updateAnswer('cond1', val),
        ),
        _buildSelector(
          context,
          'SE alien amigável E acenando:',
          state.answers['cond2'],
          opts2,
          (val) => controller.updateAnswer('cond2', val),
        ),
        _buildSelector(
          context,
          'SE alarme tocar OU luz piscar:',
          state.answers['cond3'],
          opts3,
          (val) => controller.updateAnswer('cond3', val),
        ),
      ],
    );
  }

  // WIDGETS AUXILIARES (Design)
  Widget _buildSelector(
    BuildContext context,
    String label,
    String? value,
    List<String> options,
    Function(String) onSelect,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.title(color: AppColors.gray70)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showOptionsSheet(context, options, onSelect),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: value != null
                    ? AppColors.purplePrimary
                    : AppColors.gray05,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: value != null
                      ? AppColors.purplePrimary
                      : AppColors.gray20,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value ?? 'Toque para escolher',
                    style: AppTypography.button(
                      color: value != null ? Colors.white : AppColors.gray40,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down_circle,
                    color: value != null ? Colors.white : AppColors.gray40,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedNum(String num) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.gray10,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(num, style: AppTypography.title()),
  );

  Widget _buildArrow() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 12),
    child: Icon(Icons.arrow_downward_rounded, color: AppColors.gray30),
  );

  Widget _buildNumInput(
    String key,
    String? value,
    LessonFiveController controller,
  ) {
    return TextField(
      keyboardType: TextInputType.number,
      onChanged: (val) => controller.updateAnswer(key, val),
      controller: TextEditingController.fromValue(
        TextEditingValue(
          text: value ?? '',
          selection: TextSelection.collapsed(offset: (value ?? '').length),
        ),
      ),
      textAlign: TextAlign.center,
      style: AppTypography.title(color: AppColors.purplePrimary),
      decoration: InputDecoration(
        hintText: '?',
        filled: true,
        fillColor: AppColors.purplePrimary.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.purplePrimary.withOpacity(0.3),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.purplePrimary,
            width: 2,
          ),
        ),
      ),
    );
  }

  void _showOptionsSheet(
    BuildContext context,
    List<String> options,
    Function(String) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Escolha a opção:',
              style: AppTypography.title(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ...options.map(
              (opt) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton(
                  onPressed: () {
                    onSelect(opt);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.purplePrimary,
                    side: const BorderSide(color: AppColors.purplePrimary),
                  ),
                  child: Text(opt),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
