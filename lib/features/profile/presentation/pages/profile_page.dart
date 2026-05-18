// lib/features/profile/presentation/pages/profile_page.dart

import 'package:educaeasy_app/features/store/data/avatar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Design System
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/widgets/button.dart';
import '../../../../design_system/widgets/input.dart';

// Domínio e Dados
import '../../../onboarding/domain/models/user_model.dart';
import '../../../onboarding/domain/auth_repository.dart';
import '../../../onboarding/data/firebase_auth_repository_impl.dart';
import '../../../levels_map/domain/map_progress_provider.dart';

// Importes do Firebase
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isLoading = false;
  late final AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = FirebaseAuthRepositoryImpl(FirebaseAuth.instance);
  }

  Future<Map<String, dynamic>> _fetchProfileData() async {
    final userModel = await _authRepository.getCurrentUserData();
    final prefs = await SharedPreferences.getInstance();
    return {
      'userModel': userModel,
      'localAge': prefs.getInt('user_age') ?? 0,
      'localName': prefs.getString('user_name') ?? '',
    };
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);
    try {
      await _authRepository.signOut();
      if (mounted) context.go('/welcome');
    } catch (e) {
      debugPrint('Erro ao sair: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLinkOptionsDialog(int anonLevel, int anonCoins) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Salvar Progresso',
                style: AppTypography.title(
                  color: AppColors.gray90,
                ).copyWith(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Escolha como deseja se conectar:',
                style: AppTypography.body(color: AppColors.gray50),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: EducaeasyButton(
                  text: 'Entrar com Google',
                  variant: ButtonVariant.outline,
                  onPressed: () {
                    context.pop();
                    _executeActualLogin(
                      loginAction: () => _authRepository.signInWithGoogle(),
                      anonLevel: anonLevel,
                      anonCoins: anonCoins,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: EducaeasyButton(
                  text: 'Entrar com E-mail',
                  variant: ButtonVariant.primary,
                  onPressed: () {
                    context.pop();
                    _showEmailLoginFields(anonLevel, anonCoins);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showEmailLoginFields(int anonLevel, int anonCoins) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text('Entrar com E-mail', style: AppTypography.title()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EducaeasyInput(
                placeholder: 'E-mail',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              EducaeasyInput(
                placeholder: 'Senha',
                controller: passwordController,
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                context.pop();
                _executeActualLogin(
                  loginAction: () => _authRepository.signInWithEmail(
                    emailController.text.trim(),
                    passwordController.text,
                  ),
                  anonLevel: anonLevel,
                  anonCoins: anonCoins,
                );
              },
              child: const Text('Entrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _executeActualLogin({
    required Future<dynamic> Function() loginAction,
    required int anonLevel,
    required int anonCoins,
  }) async {
    setState(() => _isLoading = true);
    try {
      final result = await loginAction();
      if (result is bool && result == false) {
        setState(() => _isLoading = false);
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 🔥 GARANTIA ABSOLUTA: Cria/Verifica o documento no Firestore IMEDIATAMENTE com os dados básicos
      // Com merge: true, os dados já existentes na nuvem nunca são apagados!
      await _authRepository.syncProfileToCloud();

      // Puxa o documento atualizado
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      int cloudLevel = 1;
      int cloudCoins = 0;
      String cloudName = user.displayName ?? '';
      int cloudAge = 0;

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        cloudLevel = data['currentLevel'] ?? 1;
        cloudCoins = data['coins'] ?? 0;
        cloudName = data['name'] ?? user.displayName ?? '';
        cloudAge = data['age'] ?? 0;
      }

      if (cloudLevel <= 1 &&
          cloudCoins == 0 &&
          anonLevel <= 1 &&
          anonCoins == 0) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'currentLevel': anonLevel,
          'coins': anonCoins,
        }, SetOptions(merge: true));

        ref.read(mapProgressProvider.notifier).updateProgress(anonLevel);
        await AvatarService().init();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conta vinculada com sucesso!')),
          );
          setState(() {});
        }
      } else {
        if (mounted) {
          _showConflictResolutionDialog(
            localAnonData: {'level': anonLevel, 'coins': anonCoins},
            cloudAccountData: {
              'currentLevel': cloudLevel,
              'coins': cloudCoins,
              'name': cloudName,
              'age': cloudAge,
            },
            permanentUserUid: user.uid,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao conectar: $e'),
            backgroundColor: AppColors.redPrimary,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showConflictResolutionDialog({
    required Map<String, dynamic> localAnonData,
    required Map<String, dynamic> cloudAccountData,
    required String permanentUserUid,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Conflito de Dados!',
                style: AppTypography.title(
                  color: AppColors.gray90,
                ).copyWith(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Identificamos dois progressos. Qual deseja manter?',
                style: AppTypography.body(color: AppColors.gray50),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _buildConflictCard(
                      title: 'Celular Atual',
                      level: localAnonData['level'] ?? 1,
                      coins: localAnonData['coins'] ?? 0,
                      borderColor: AppColors.purplePrimary,
                      backgroundColor: AppColors.purplePrimary.withOpacity(
                        0.05,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildConflictCard(
                      title: 'Salvo na Nuvem',
                      level: cloudAccountData['currentLevel'] ?? 1,
                      coins: cloudAccountData['coins'] ?? 0,
                      borderColor: AppColors.bluePrimary,
                      backgroundColor: AppColors.bluePrimary.withOpacity(0.05),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: EducaeasyButton(
                  text: 'Manter dados do celular',
                  variant: ButtonVariant.primary,
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(permanentUserUid)
                        .set({
                          'currentLevel': localAnonData['level'],
                          'coins': localAnonData['coins'],
                        }, SetOptions(merge: true));

                    await _authRepository.syncProfileToCloud();
                    ref
                        .read(mapProgressProvider.notifier)
                        .updateProgress(localAnonData['level']);
                    await AvatarService().init();

                    if (context.mounted) {
                      context.pop();
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nuvem atualizada!')),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: EducaeasyButton(
                  text: 'Baixar dados da nuvem',
                  variant: ButtonVariant.outline,
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString(
                      'user_name',
                      cloudAccountData['name'] ?? '',
                    );
                    await prefs.setInt(
                      'user_age',
                      cloudAccountData['age'] ?? 0,
                    );

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(permanentUserUid)
                        .set({
                          'currentLevel': cloudAccountData['currentLevel'] ?? 1,
                          'coins': cloudAccountData['coins'] ?? 0,
                          'name': cloudAccountData['name'] ?? '',
                          'age': cloudAccountData['age'] ?? 0,
                          'email':
                              FirebaseAuth.instance.currentUser?.email ?? '',
                          'isAnonymous': false,
                        }, SetOptions(merge: true));

                    ref
                        .read(mapProgressProvider.notifier)
                        .updateProgress(cloudAccountData['currentLevel'] ?? 1);
                    await AvatarService().init();

                    if (context.mounted) {
                      context.pop();
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Progresso restaurado!')),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLevel = ref.watch(mapProgressProvider);

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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.bluePrimary),
            )
          : FutureBuilder<Map<String, dynamic>>(
              future: _fetchProfileData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.bluePrimary,
                    ),
                  );
                }

                final data = snapshot.data;
                final user = data?['userModel'] as UserModel?;
                final localAge = data?['localAge'] as int? ?? 0;
                final localName = data?['localName'] as String? ?? '';

                final authUser = FirebaseAuth.instance.currentUser;
                final isAnonymous = authUser?.isAnonymous ?? true;

                String userName = 'Estudante';
                if (user != null &&
                    user.name.isNotEmpty &&
                    user.name != 'Estudante') {
                  userName = user.name;
                } else if (authUser != null &&
                    authUser.displayName != null &&
                    authUser.displayName!.isNotEmpty) {
                  userName = authUser.displayName!;
                } else if (localName.isNotEmpty) {
                  userName = localName;
                }

                int finalAge = (user != null && user.age > 0)
                    ? user.age
                    : localAge;
                String userAge = finalAge > 0
                    ? '$finalAge anos'
                    : 'Idade não informada';

                String userEmail = isAnonymous
                    ? 'Conta Anônima (Temporária)'
                    : '';
                if (!isAnonymous) {
                  if (authUser != null &&
                      authUser.email != null &&
                      authUser.email!.isNotEmpty) {
                    userEmail = authUser.email!;
                  } else if (user != null && user.email.isNotEmpty) {
                    userEmail = user.email;
                  } else {
                    userEmail = 'E-mail não encontrado';
                  }
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildUserHeader(userName, userEmail, userAge),
                      const SizedBox(height: 32),
                      _buildStatsRow(
                        coins: user?.coins ?? 0,
                        level: currentLevel,
                      ),
                      const SizedBox(height: 40),

                      if (isAnonymous) ...[
                        _buildSyncWarningCard(currentLevel, user?.coins ?? 0),
                        const SizedBox(height: 16),
                      ],

                      _buildMenuTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Editar Conta',
                        onTap: () => context
                            .push('/edit-profile')
                            .then((_) => setState(() {})),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: EducaeasyButton(
                          text: 'Sair da Conta',
                          variant: ButtonVariant.outline,
                          onPressed: _handleLogout,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildUserHeader(String name, String email, String age) {
    final AvatarService avatarService = AvatarService();

    return Column(
      children: [
        ValueListenableBuilder<String?>(
          valueListenable: avatarService.selectedAvatarNotifier,
          builder: (context, selectedSvg, child) {
            return Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.bluePrimaryLighter.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.bluePrimary, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: selectedSvg != null
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SvgPicture.string(
                          selectedSvg,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'E',
                          style: AppTypography.title(
                            color: AppColors.bluePrimary,
                          ).copyWith(fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            );
          },
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

  Widget _buildStatsRow({required int coins, required int level}) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.emoji_events_rounded,
            iconColor: AppColors.purplePrimary,
            value: 'Nível $level',
            label: 'Progresso Atual',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.monetization_on_rounded,
            iconColor: AppColors.yellowDark,
            value: '$coins',
            label: 'Moedas na Nuvem',
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
            color: AppColors.gray20.withOpacity(0.3),
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
            ).copyWith(fontSize: 18, fontWeight: FontWeight.w800),
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

  Widget _buildSyncWarningCard(int currentLevel, int currentCoins) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
              const SizedBox(width: 8),
              Text(
                'Proteja seu progresso!',
                style: AppTypography.title(
                  color: Colors.orange.shade900,
                ).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Vincule uma conta definitiva para não perder suas conquistas.',
            style: AppTypography.body(
              color: Colors.orange.shade800,
            ).copyWith(fontSize: 13),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: EducaeasyButton(
              text: 'Vincular Conta',
              variant: ButtonVariant.primary,
              onPressed: () =>
                  _showLinkOptionsDialog(currentLevel, currentCoins),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictCard({
    required String title,
    required int level,
    required int coins,
    required Color borderColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: AppTypography.body(
              color: AppColors.gray80,
            ).copyWith(fontWeight: FontWeight.bold, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: AppColors.purplePrimary,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                'Fase $level',
                style: AppTypography.title(
                  color: AppColors.gray90,
                ).copyWith(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.monetization_on_rounded,
                color: AppColors.yellowDark,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                '$coins',
                style: AppTypography.title(
                  color: AppColors.gray90,
                ).copyWith(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
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
