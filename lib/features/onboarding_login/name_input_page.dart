import 'package:educaeasy_app/design_system/widgets/onboarding_shell.dart';
import 'package:flutter/material.dart';
import 'package:educaeasy_app/design_system/widgets/input.dart';

class NameInputPage extends StatelessWidget {
  const NameInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      showBackButton: true, 
      child: Column(  
        // Removido: mainAxisSize: MainAxisSize.min (não é necessário aqui)
        children: [
          const SizedBox(  
            width: double.infinity,  
            height: 52,  
            child: EducaeasyInput(  
              placeholder: 'Seu nome',  
            ),  
          ), 
          const SizedBox(height: 20), // 👈 USE SIZEDBOX EM VEZ DE SPACER
        ], 
      ),
    );
  }
}