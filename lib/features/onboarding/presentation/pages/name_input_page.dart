import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:educaeasy_app/design_system/tokens/colors.dart';
import 'package:educaeasy_app/design_system/tokens/typography.dart';
import 'package:educaeasy_app/design_system/widgets/button.dart';
import 'package:educaeasy_app/design_system/widgets/input.dart';
import 'package:educaeasy_app/design_system/widgets/onboarding_shell.dart';
import '../../data/firebase_auth_repository_impl.dart'; 

class NameInputPage extends StatefulWidget {
  const NameInputPage({super.key});

  @override
  State<NameInputPage> createState() => _NameInputPageState();
}

class _NameInputPageState extends State<NameInputPage> {
  // Controlador para capturar o que a criança digita
  final TextEditingController _nameController = TextEditingController();
  
  // Variável para controlar se o botão deve mostrar que está carregando
  bool _isLoading = false;

  // Instanciando nosso repositório 
  final _authRepository = FirebaseAuthRepositoryImpl(FirebaseAuth.instance);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Executa a lógica ao clicar no botão
  Future<void> _handleContinue() async {
    final name = _nameController.text.trim();

    // Validação simples; Não faz nada se estiver vazio
    if (name.isEmpty) return;

    setState(() => _isLoading = true); // Começa a carregar

    try {
      // Chama a interface (Domain) que executa o Firebase (Data)
      await _authRepository.saveUserName(name);
      
      // Se deu tudo certo e a tela ainda está aberta, vai para a próxima página usando GoRouter
      if (mounted) {
        context.go('/login_methods');
      }
    } catch (e) {
      print('Erro ao salvar nome: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      showBackButton: true,
      footer: EducaeasyButton(
        text: _isLoading ? "Salvando..." : "Continuar",
        variant: ButtonVariant.primary,
        onPressed: _isLoading ? () {} : _handleContinue, // Desativa o clique se estiver carregando
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.25,
          bottom: 24,
        ),
        child: Column(  
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Text(
              "Como você se chama?",
              style: AppTypography.title(color: AppColors.gray40),
            ),
            SizedBox(  
              width: double.infinity,  
              height: 52,  
              child: EducaeasyInput(  
                placeholder: 'Seu nome',
                // Passar o controlador para o input customizado
                controller: _nameController, 
              ),  
            ), 
          ], 
        ),
      ),
    );
  }
}