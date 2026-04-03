

import 'package:educaeasy_app/design_system/tokens/colors.dart';
import 'package:educaeasy_app/design_system/widgets/button.dart';
import 'package:educaeasy_app/design_system/widgets/onboarding_shell.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';

class LoginMethodsPage extends StatelessWidget {
  const LoginMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    final List<Map<String, dynamic>> loginMethods = [
      {
        'label': 'Entrar com e-mail',
        'icon': const Icon(Icons.mail_outline, size: 20, color: AppColors.gray40),
      },
      {
        'label': 'Entrar com Google',
        // 'icon': SvgPicture.asset('assets/svg/google-icon.svg', width: 20),
        'icon': const Icon(Icons.mail_outline, size: 20, color: AppColors.gray40),
      },
      {
        'label': 'Continuar sem conta',
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
            return SizedBox(
              height: 52,
              child: EducaeasyButton(
                text: method['label'],
                variant: ButtonVariant.outline,
                // 2. O botão recebe o widget, não importa se é SVG ou Icon
                icon: method['icon'], 
                onPressed: () {
                  // Lógica de login aqui
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}