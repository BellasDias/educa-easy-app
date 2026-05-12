import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 1. Roteamento (Usando caminhos relativos para garantir que o Flutter encontre)
import '../../../../core/routing/app_router.dart';

// 2. Design System
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/widgets/button.dart';

// 3. Domínio e Dados
import '../../../onboarding/domain/models/user_model.dart';
import '../../../onboarding/domain/auth_repository.dart';
import '../../../onboarding/data/firebase_auth_repository_impl.dart';

// Importes do Firebase
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoggingOut = false;
  late final AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    // ✅ CORREÇÃO: O seu repositório só pede a instância do FirebaseAuth!
    _authRepository = FirebaseAuthRepositoryImpl(FirebaseAuth.instance);
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);

    try {
      await _authRepository.signOut();

      if (mounted) {
        // Usa o texto direto '/welcome' que você definiu no roteador.
        context.go('/welcome');
      }
    } catch (e) {
      debugPrint('Erro ao sair: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao sair. Tente novamente.'),
            backgroundColor: AppColors.redPrimary,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Meu Perfil',
          style: AppTypography.title(
            color: AppColors.gray80,
          ).copyWith(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.gray80),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.gray20, height: 1),
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

          // 🚨 ESTADO DE ERRO ATUALIZADO COM O BOTÃO DE SAÍDA
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Erro de conexão com o servidor.',
                    style: AppTypography.body(color: AppColors.redPrimary),
                  ),
                  const SizedBox(height: 24),
                  // Botão para não deixar o usuário preso na tela
                  SizedBox(
                    width: 200,
                    child: EducaeasyButton(
                      text: _isLoggingOut ? 'Saindo...' : 'Sair da Conta',
                      variant: ButtonVariant.outline,
                      onPressed: _isLoggingOut ? () {} : _handleLogout,
                    ),
                  ),
                ],
              ),
            );
          }

          final user = snapshot.data;
          final userName = user?.name ?? 'Estudante';
          final userAge = (user?.age != null && user!.age > 0)
              ? '${user.age} anos'
              : 'Idade não informada';
          final userEmail = (user?.email != null && user!.email.isNotEmpty)
              ? user.email
              : 'Conta Anônima';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildUserHeader(userName, userEmail, userAge),
                const SizedBox(height: 32),
                _buildStatsRow(),
                const SizedBox(height: 40),
                _buildMenuTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Editar Conta',
                  onTap: () => debugPrint('Navegar para Editar Conta'),
                ),
                const SizedBox(height: 16),
                _buildMenuTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notificações',
                  onTap: () => debugPrint('Navegar para Notificações'),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: EducaeasyButton(
                    text: _isLoggingOut ? 'Saindo...' : 'Sair da Conta',
                    variant: ButtonVariant.outline,
                    onPressed: _isLoggingOut ? () {} : _handleLogout,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- SUB-WIDGETS ---

  Widget _buildUserHeader(String name, String email, String age) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.bluePrimaryLighter.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.bluePrimary, width: 2),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: AppTypography.title(
                color: AppColors.bluePrimary,
              ).copyWith(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: AppTypography.title(
            color: AppColors.gray80,
          ).copyWith(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(email, style: AppTypography.body(color: AppColors.gray40)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.gray20,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            age,
            style: AppTypography.body(
              color: AppColors.gray50,
            ).copyWith(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_fire_department_rounded,
            iconColor: AppColors.yellowDark,
            value: '12',
            label: 'Dias Seguidos',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.star_rounded,
            iconColor: AppColors.yellowPrimary,
            value: '45',
            label: 'Estrelas',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray20),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray20.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.title(
              color: AppColors.gray80,
            ).copyWith(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            style: AppTypography.body(
              color: AppColors.gray40,
            ).copyWith(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray20),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gray50),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTypography.title(
                  color: AppColors.gray80,
                ).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.gray40),
          ],
        ),
      ),
    );
  }
}
