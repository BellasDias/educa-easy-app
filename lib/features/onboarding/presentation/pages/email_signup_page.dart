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

  bool _isLoading = false;
  final _authRepository = FirebaseAuthRepositoryImpl(FirebaseAuth.instance);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validações simples
    if (email.isEmpty || password.isEmpty) {
      _showError('Preencha o e-mail e a senha!');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authRepository.signInWithEmail(email, password);

      if (mounted) {
        context.push('/levels');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        _showError('E-mail ou senha incorretos.');
      } else if (e.code == 'invalid-email') {
        _showError('E-mail inválido.');
      } else {
        _showError('Erro ao fazer login: ${e.message}');
      }
    } catch (e) {
      _showError('Ocorreu um erro inesperado. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // NOVA FUNÇÃO: Recuperação de Senha
  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError('Digite seu e-mail no campo acima para recuperar a senha.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authRepository.sendPasswordResetEmail(email);

      if (mounted) {
        // Mensagem verde de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'E-mail de recuperação enviado! Verifique sua caixa de entrada.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showError('Nenhuma conta encontrada com este e-mail.');
      } else if (e.code == 'invalid-email') {
        _showError('E-mail inválido.');
      } else {
        _showError('Erro ao recuperar senha: ${e.message}');
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
      showBackButton: true,
      footer: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Ainda não tem uma conta?",
            style: AppTypography.body(color: AppColors.gray40),
          ),
          GestureDetector(
            onTap: () {
              context.push('/create_account');
            },
            child: Text(
              "Criar uma conta",
              style: AppTypography.body(
                color: Colors.blue,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.13,
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
                  style: AppTypography.title(
                    color: AppColors.gray40,
                  ).copyWith(fontWeight: FontWeight.bold, fontSize: 20),
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

            // Agrupei a senha e o botão de esqueci a senha
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end, // Alinha os filhos à direita
              spacing: 8,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Text(
                      "Digite sua senha:",
                      style: AppTypography.title(
                        color: AppColors.gray40,
                      ).copyWith(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(
                      height: 52,
                      child: EducaeasyInput(
                        placeholder: 'Senha',
                        controller: _passwordController,
                        obscureText: true,
                      ),
                    ),
                  ],
                ),
                // NOVO VISUAL: Botão Esqueci minha senha
                GestureDetector(
                  onTap: _isLoading ? null : _handleForgotPassword,
                  child: Text(
                    "Esqueci minha senha",
                    style: AppTypography.body(
                      color: Colors.blue,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: EducaeasyButton(
                text: _isLoading ? 'Aguarde...' : 'Entrar',
                variant: ButtonVariant.primary,
                onPressed: _isLoading ? () {} : _handleLogin,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
