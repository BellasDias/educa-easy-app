// lib/features/profile/presentation/pages/trophies_page.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Design System do EducaEasy
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/widgets/button.dart';

// Repositories e Providers
import '../../../onboarding/domain/models/user_model.dart';
import '../../../onboarding/domain/auth_repository.dart';
import '../../../onboarding/data/firebase_auth_repository_impl.dart';
import '../../../levels_map/domain/map_progress_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrophiesPage extends ConsumerStatefulWidget {
  const TrophiesPage({super.key});

  @override
  ConsumerState<TrophiesPage> createState() => _TrophiesPageState();
}

class _TrophiesPageState extends ConsumerState<TrophiesPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rgbController;
  late final AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = FirebaseAuthRepositoryImpl(FirebaseAuth.instance);

    // Controlador que faz o efeito RGB rodar infinitamente a cada 5 segundos
    _rgbController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rgbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLevel = ref.watch(mapProgressProvider);
    final int completedLevels = currentLevel - 1 > 0 ? currentLevel - 1 : 0;

    return Scaffold(
      backgroundColor: AppColors.gray05,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Minhas Conquistas',
          style: AppTypography.title(
            color: AppColors.gray80,
          ).copyWith(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.gray80),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<UserModel?>(
        future: _authRepository.getCurrentUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.bluePrimary),
            );
          }

          final user = snapshot.data;
          final List<String> avatars =
              user?.unlockedAvatars ?? ['Prof. Coruja'];

          return AnimatedBuilder(
            animation: _rgbController,
            builder: (context, child) {
              // 🌈 Definição do Gradiente RGB Animado Rotativo
              final rgbGradient = SweepGradient(
                transform: GradientRotation(_rgbController.value * 2 * math.pi),
                colors: const [
                  Colors.red,
                  Colors.orange,
                  Colors.yellow,
                  Colors.green,
                  Colors.blue,
                  Colors.purple,
                  Colors.red, // Fecha o ciclo do arco-íris
                ],
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // 💡 CORRIGIDO
                  children: [
                    Text(
                      'Galeria de Troféus',
                      style: AppTypography.title(
                        color: AppColors.gray90,
                      ).copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Veja suas medalhas e marcas alcançadas!',
                      style: AppTypography.body(color: AppColors.gray50),
                    ),
                    const SizedBox(height: 24),

                    // 📊 LAYOUT DE ESTATÍSTICAS REESTRUTURADO
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.map_rounded,
                            color: AppColors.bluePrimary,
                            value: '$completedLevels',
                            label: 'Fases Concluídas',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.face_rounded,
                            color: AppColors.purplePrimary,
                            value: '${avatars.length}',
                            label: 'Personagens',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // 🏆 SISTEMA DE BADGES
                    Text(
                      'Medalhas de Estudo',
                      style: AppTypography.title(
                        color: AppColors.gray90,
                      ).copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Medalha 1: Primeira fase concluída
                    _buildBadgeTile(
                      icon: Icons.rocket_launch_rounded,
                      color: Colors.red,
                      title: 'Primeira de Muitas!',
                      description: 'Conclua a primeira lição do mapa.',
                      isUnlocked: completedLevels >= 1,
                      rgbGradient: rgbGradient,
                    ),
                    const SizedBox(height: 12),

                    // Medalha 2: Comprou personagem
                    _buildBadgeTile(
                      icon: Icons.shopping_bag_rounded,
                      color: Colors.teal,
                      title: 'Estilo Puro',
                      description: 'Desbloqueie um novo parceiro na Loja.',
                      isUnlocked: avatars.length > 1,
                      rgbGradient: rgbGradient,
                    ),
                    const SizedBox(height: 12),

                    // Medalha 3: Concluir a Fase 5 (Ativa no nível 6)
                    _buildBadgeTile(
                      icon: Icons.workspace_premium_rounded,
                      color: Colors.indigo,
                      title: 'Campeão da Fase 5',
                      description: 'Supere todos os desafios até a lição 5.',
                      isUnlocked: currentLevel >= 6,
                      rgbGradient: rgbGradient,
                    ),
                    const SizedBox(height: 12),

                    // Medalha 4: Concluir a Fase 7 (Ativa no nível 8) - 🌟 NOVA CONQUISTA MÁXIMA
                    _buildBadgeTile(
                      icon: Icons.military_tech_rounded,
                      color: Colors.amber.shade800,
                      title: 'Lenda da Fase 7',
                      description: 'Conclua as fases até a fase 7.',
                      isUnlocked: currentLevel >= 8,
                      rgbGradient: rgbGradient,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- WIDGET AUXILIAR PARA CRIAR A BORDA RGB NESTADA ---
  Widget _buildRGBBorderContainer({
    required Widget child,
    required SweepGradient gradient,
    required bool isUnlocked,
  }) {
    if (!isUnlocked) return child;
    return Container(
      padding: const EdgeInsets.all(2.5), // Espessura da borda RGB
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(
          18,
        ), // Ajustado para bater com o raio do inner
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray20),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.title(
              color: AppColors.gray80,
            ).copyWith(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.body(
              color: AppColors.gray40,
            ).copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeTile({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required bool isUnlocked,
    required SweepGradient rgbGradient,
  }) {
    // Componente interno da medalha
    final innerContent = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? Colors.transparent : AppColors.gray20,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnlocked ? color.withOpacity(0.1) : AppColors.gray10,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUnlocked ? icon : Icons.lock_rounded,
              color: isUnlocked ? color : AppColors.gray40,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.title(
                    color: isUnlocked ? AppColors.gray90 : AppColors.gray40,
                  ).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTypography.body(
                    color: AppColors.gray50,
                  ).copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.greenPrimary,
              size: 22,
            ),
        ],
      ),
    );

    // Se estiver liberada, ganha o invólucro com a borda RGB animada
    return _buildRGBBorderContainer(
      gradient: rgbGradient,
      isUnlocked: isUnlocked,
      child: innerContent,
    );
  }
}
