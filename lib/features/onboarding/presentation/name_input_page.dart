import 'package:educaeasy_app/design_system/tokens/colors.dart';
import 'package:educaeasy_app/design_system/widgets/button.dart';
import 'package:educaeasy_app/design_system/widgets/onboarding_shell.dart';
import 'package:educaeasy_app/features/onboarding/presentation/login_methods_page.dart';
import 'package:flutter/material.dart';
import 'package:educaeasy_app/design_system/widgets/input.dart';
import 'package:educaeasy_app/design_system/tokens/typography.dart';

class NameInputPage extends StatelessWidget {
  const NameInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      showBackButton: true,
      footer: EducaeasyButton(
        text: "Continuar",
        variant: ButtonVariant.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginMethodsPage(),
            ),
          );
        },
      ),
      child: Padding(
        padding: EdgeInsets.only( // Deixar componentes no centro da tela
          top: MediaQuery.of(context).size.height * 0.25,
          bottom: 24,
        ),
        child: Column(  
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start, // Alinha tudo para a esquerda
        children: [
          // Parte do centro (label & input)
          Text(
            "Como você se chama?",
            style: AppTypography.title(color: AppColors.gray40),
            ),
          const SizedBox(  
            width: double.infinity,  
            height: 52,  
            child: EducaeasyInput(  
              placeholder: 'Seu nome',  
            ),  
          ), 
        ], 
      ),
    ),
    );
  }
}