// lib/features/profile/presentation/pages/edit_profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Design System
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/widgets/button.dart';
import '../../../../design_system/widgets/input.dart';

// Dependências
import '../../../onboarding/domain/auth_repository.dart';
import '../../../onboarding/data/firebase_auth_repository_impl.dart';
import '../../../store/data/avatar_service.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  late final AuthRepository _authRepository;
  bool _isLoadingData = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _authRepository = FirebaseAuthRepositoryImpl(FirebaseAuth.instance);
    _loadCurrentData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // 💡 CORRIGIDO: Agora usa o Fallback triplo (Firestore -> Google -> Memória Local)
  Future<void> _loadCurrentData() async {
    final userModel = await _authRepository.getCurrentUserData();
    final authUser = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();

    final localAge = prefs.getInt('user_age') ?? 0;
    final localName = prefs.getString('user_name') ?? '';

    // 1. Resgata o Nome
    if (userModel != null &&
        userModel.name.isNotEmpty &&
        userModel.name != 'Estudante') {
      _nameController.text = userModel.name;
    } else if (authUser != null &&
        authUser.displayName != null &&
        authUser.displayName!.isNotEmpty) {
      _nameController.text = authUser.displayName!;
    } else if (localName.isNotEmpty) {
      _nameController.text = localName;
    }

    // 2. Resgata a Idade (Se não achar no Firestore, puxa do celular)
    if (userModel != null && userModel.age > 0) {
      _ageController.text = userModel.age.toString();
    } else if (localAge > 0) {
      _ageController.text = localAge.toString();
    }

    if (mounted) setState(() => _isLoadingData = false);
  }

  Future<void> _saveProfile() async {
    final newName = _nameController.text.trim();
    final newAge = int.tryParse(_ageController.text.trim()) ?? 0;

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O nome não pode ficar vazio!'),
          backgroundColor: AppColors.redPrimary,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Atualiza a conta Auth
        await user.updateDisplayName(newName);

        // Recria ou Atualiza o documento no Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': newName,
          'age': newAge,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Atualiza a memória local
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', newName);
        await prefs.setInt('user_age', newAge);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil atualizado com sucesso!'),
              backgroundColor: AppColors.greenPrimary,
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: AppColors.redPrimary,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showDeleteConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
              const Icon(
                Icons.warning_rounded,
                color: AppColors.redPrimary,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Atenção! Zona de Perigo',
                style: AppTypography.title(
                  color: AppColors.gray90,
                ).copyWith(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Tem certeza que deseja excluir sua conta? Você perderá todos os seus avatares, moedas e progresso no mapa para sempre. Essa ação não pode ser desfeita.',
                style: AppTypography.body(color: AppColors.gray50),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    context.pop();
                    await _executeAccountDeletion();
                  },
                  child: Text(
                    'Sim, excluir minha conta',
                    style: AppTypography.title(
                      color: Colors.white,
                    ).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: EducaeasyButton(
                  text: 'Cancelar',
                  variant: ButtonVariant.outline,
                  onPressed: () => context.pop(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _executeAccountDeletion() async {
    setState(() => _isLoadingData = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .delete();
        } catch (e) {
          debugPrint('Documento do Firestore já não existia: $e');
        }

        await user.delete();

        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        if (mounted) context.go('/welcome');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login' && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Por segurança, saia da conta e faça login novamente para excluí-la.',
            ),
            backgroundColor: AppColors.redPrimary,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
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
          'Editar Perfil',
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
      body: _isLoadingData
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.bluePrimary),
            )
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: _buildAvatarDisplay()),
                    const SizedBox(height: 32),

                    Text(
                      'Nome do Estudante',
                      style: AppTypography.title(
                        color: AppColors.gray80,
                      ).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    EducaeasyInput(
                      placeholder: 'Como você se chama?',
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Idade',
                      style: AppTypography.title(
                        color: AppColors.gray80,
                      ).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    EducaeasyInput(
                      placeholder: 'Quantos anos você tem?',
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 48),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: EducaeasyButton(
                        text: _isSaving ? 'Salvando...' : 'Salvar Alterações',
                        variant: ButtonVariant.primary,
                        onPressed: _isSaving ? () {} : _saveProfile,
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Divider(color: AppColors.gray20),
                    const SizedBox(height: 16),

                    Center(
                      child: TextButton.icon(
                        onPressed: _showDeleteConfirmation,
                        icon: const Icon(
                          Icons.delete_forever_rounded,
                          color: AppColors.redPrimary,
                        ),
                        label: Text(
                          'Excluir Minha Conta',
                          style: AppTypography.title(
                            color: AppColors.redPrimary,
                          ).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAvatarDisplay() {
    final AvatarService avatarService = AvatarService();

    return ValueListenableBuilder<String?>(
      valueListenable: avatarService.selectedAvatarNotifier,
      builder: (context, selectedSvg, child) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.bluePrimaryLighter.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.bluePrimary, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: selectedSvg != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SvgPicture.string(selectedSvg, fit: BoxFit.contain),
                  )
                : const Icon(
                    Icons.person_rounded,
                    size: 64,
                    color: AppColors.bluePrimary,
                  ),
          ),
        );
      },
    );
  }
}
