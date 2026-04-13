// lib/features/onboarding/presentation/pages/email_signup_page.dart

import 'package:educaeasy_app/features/onboarding/data/firebase_auth_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:educaeasy_app/design_system/tokens/colors.dart';
import 'package:educaeasy_app/design_system/tokens/typography.dart';
import 'package:educaeasy_app/design_system/widgets/button.dart';
import 'package:educaeasy_app/design_system/widgets/input.dart';
import 'package:educaeasy_app/design_system/widgets/onboarding_shell.dart';

class EmailSignupPage extends StatefulWidget {
  const EmailSignupPage({super.key});

  @override
  State<EmailSignupPage> createState() => _EmailSignupPageState();
}

class _EmailSignupPageState extends State<EmailSignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  final _authRepository = FirebaseAuthRepositoryImpl(FirebaseAuth.instance);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validações simples
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError('Preencha todos os campos!');
      return;
    }
    
    if (password != confirmPassword) {
      _showError('As senhas não coincidem!');
      return;
    }

    if (password.length < 6) {
      _showError('A senha deve ter pelo menos 6 caracteres.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Chama o método que criamos na etapa anterior
      await _authRepository.signUpWithEmail(email, password);
      
      if (mounted) {
        // Se deu tudo certo e sincronizou com a nuvem, manda pro mapa de níveis!
        context.push('/levels'); 
      }
    } on FirebaseAuthException catch (e) {
      // Tratamento de erros comuns do Firebase
      if (e.code == 'email-already-in-use') {
        _showError('Este e-mail já está cadastrado.');
      } else if (e.code == 'invalid-email') {
        _showError('E-mail inválido.');
      } else {
        _showError('Erro ao criar conta: ${e.message}');
      }
    } catch (e) {
      _showError('Ocorreu um erro inesperado. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      showBackButton: true, // Adiciona o botão de voltar no topo
      footer: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Ainda não tem uma conta?",
            style: AppTypography.body(color: AppColors.gray40),
          ),
          GestureDetector(
            onTap: () {
              context.push('/signup');
            },
            child: Text(
              "Criar uma conta",
              style: AppTypography.body(color: Colors.blue).copyWith(
              fontWeight: FontWeight.bold,
            ),
            ),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.15,
          bottom: 24,
        ),
        child: Column(
          spacing: 24,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  "Digite seu e-mail:",
                  style: AppTypography.title(color: AppColors.gray40).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 52,
                  child: EducaeasyInput(
                    placeholder: 'E-mail',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ],
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  "Digite seu e-mail:",
                  style: AppTypography.title(color: AppColors.gray40).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 52,
                  child: EducaeasyInput(
                    placeholder: 'Senha',
                    controller: _passwordController,
                    obscureText: true, // Esconde os caracteres (***)
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: EducaeasyButton(
              text: _isLoading ? 'Criando...' : 'Finalizar',
              variant: ButtonVariant.primary,
              onPressed: _isLoading ? () {} : _handleSignup,
              ),
            ),
          ],
        ),
      ),
    );
  }
}