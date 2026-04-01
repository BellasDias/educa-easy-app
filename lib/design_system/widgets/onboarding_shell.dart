// lib/design_system/widgets/onboarding_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingShell extends StatelessWidget {
  /// O conteúdo central da tela (texto, campos de input, etc.)
  final Widget child;

  /// Controla a visibilidade do botão 'Voltar'
  final bool showBackButton;

  /// Ação personalizada para o botão voltar. Se nulo, faz Navigator.pop(context)
  final VoidCallback? onBack;

  const OnboardingShell({
    super.key,
    required this.child,
    this.showBackButton = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white, // Cor de fundo base (se o SVG tiver transparência)
      body: Stack(
        children: [
          // 1. O Fundo SVG (Ocupa toda a tela)
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/svg/dots.svg',
              fit: BoxFit.cover, // Faz o SVG cobrir todo o fundo sem distorcer
            ),
          ),

          // 2. O Conteúdo (Logo, Voltar, Child, Botão)
          SafeArea(
            child: Column(  
              children: [  
                const SizedBox(height: 20),  
                _buildHeader(context),  
                const SizedBox(height: 16),  
                // ✅ Expanded ao invés de Flexible  
                Expanded(  
                  child: SingleChildScrollView(  
                    padding: EdgeInsets.zero,  // ← Remove padding duplicado  
                    child: Padding(  
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),  
                      child: child,  // ← Seu child SEM padding  
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

  Widget _buildHeader(BuildContext context) {  
  return Container(  
    height: 48,  
    padding: const EdgeInsets.symmetric(horizontal: 16),  
    child: Stack(  // ← SÓ Stack!  
      children: [  
        // BackButton à esquerda  
        if (showBackButton)  
          Positioned(  
            left: 0,  
            child: _buildBackButton(context),  
          ),  
        // Logo PERFEITA no centro  
        Positioned(  
          left: 0, right: 0,  
          child: Center(  
            child: SvgPicture.asset('assets/svg/logo.svg', height: 32),  
          ),  
        ),  
      ],  
    ),  
  );  
}  

// _buildBackButton permanece igual (Container com Icon)  


  Widget _buildBackButton(BuildContext context) {
    return Container(  
      height: 48,  
      padding: const EdgeInsets.symmetric(horizontal: 16),  
      child: Stack(  // ← Stack é rei pra sobreposição perfeita  
        children: [  
          // BackButton à esquerda  
          if (showBackButton)  
            Positioned(  
              left: 0,  
              child: _buildBackButton(context),  
            ),  
          // Logo NO EXATO CENTRO  
          Positioned(  
            left: 0,  
            right: 0,  
            child: Center(  
              child: SvgPicture.asset('assets/svg/logo.svg',height: 32),  
            ),  
          ),  
        ],  
      ),  
    ); 
  }
}