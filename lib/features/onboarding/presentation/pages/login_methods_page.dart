import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 
import 'package:go_router/go_router.dart';

// --- 1. MUDANÇA: Imports necessários para a lógica funcionar ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:educaeasy_app/features/onboarding/data/firebase_auth_repository_impl.dart'; 

import 'package:educaeasy_app/design_system/tokens/colors.dart';
import 'package:educaeasy_app/design_system/widgets/button.dart';
import 'package:educaeasy_app/design_system/widgets/onboarding_shell.dart';

class LoginMethodsPage extends StatefulWidget {
  const LoginMethodsPage({super.key});

  @override
  State<LoginMethodsPage> createState() => _LoginMethodsPageState();
}

class _LoginMethodsPageState extends State<LoginMethodsPage> {
  // Variável para saber qual botão está em estado de "loading"
  String? _loadingMethod;

  // --- 2. MUDANÇA: Instanciando o nosso repositório de autenticação ---
  final _authRepository = FirebaseAuthRepositoryImpl(FirebaseAuth.instance);

  Future<void> _handleGoogleLogin() async {
    setState(() => _loadingMethod = 'google');
    
    try {
      // Pega a resposta da nossa camada de lógica
      final bool sucesso = await _authRepository.signInWithGoogle();
      
      // SÓ VAI PARA A HOME SE O LOGIN FOR BEM SUCEDIDO
      if (sucesso && mounted) {
        context.go('/home');
      } else {
        print("A janela do Google não abriu ou o login falhou!");
      }
    } catch (e) {
      print('Erro no Google: $e');
    } finally {
      if (mounted) setState(() => _loadingMethod = null);
    }
  }

  // Lógica para Email (Leva para uma tela de digitar senha)
  void _handleEmailLogin() {
    print("Navegar para tela de input de email/senha");
  }

  // Lógica para Sem Conta (Apenas avança, pois já criamos o user anônimo na tela de Nome)
  void _handleAnonymous() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> loginMethods = [
      {
        'id': 'email',
        'label': 'Entrar com e-mail',
        'icon': const Icon(Icons.mail_outline, size: 20, color: AppColors.gray40),
        'onTap': _handleEmailLogin,
      },
      {
        'id': 'google',
        'label': 'Entrar com Google',
        'icon': SvgPicture.asset('assets/svg/google-icon.svg', width: 20),
        'onTap': _handleGoogleLogin,
      },
      {
        'id': 'anonymous',
        'label': 'Continuar sem conta',
        'icon': null, 
        'onTap': _handleAnonymous,
      },
    ];

    return OnboardingShell(
      showBackButton: true,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.25,
          bottom: MediaQuery.of(context).size.height * 0.10,
        ),
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: loginMethods.map((method) {
            final isThisLoading = _loadingMethod == method['id'];
            final isAnyLoading = _loadingMethod != null;

            return SizedBox(
              height: 52,
              child: EducaeasyButton(
                text: isThisLoading ? 'Carregando...' : method['label'],
                variant: ButtonVariant.outline,
                icon: isThisLoading ? null : method['icon'], 
                onPressed: isAnyLoading ? () {} : method['onTap'],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}