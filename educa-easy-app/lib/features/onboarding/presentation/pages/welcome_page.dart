import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // <-- IMPORTANTE: Importar o go_router
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:educaeasy_app/design_system/tokens/colors.dart';
import 'package:educaeasy_app/design_system/widgets/button.dart';
import 'package:educaeasy_app/design_system/widgets/onboarding_shell.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      showBackButton: false,
      child: Padding(  
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.30,  
          bottom: MediaQuery.of(context).size.height * 0.25,  
        ), 
        child: Column(  
          mainAxisAlignment: MainAxisAlignment.center,  
          mainAxisSize: MainAxisSize.min,  
          children: [  
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52, maxHeight: 52),  
              child: SizedBox(  
                width: double.infinity,  
                child: EducaeasyButton(
                  text: 'Começar',
                  variant: ButtonVariant.primary,
                  icon: Icon(
                    LucideIcons.play,
                    color: AppColors.gray00,
                  ),
                  onPressed: () {
                    context.go('/name_input'); 
                  },
                ),
              ),  
            ),  
            const SizedBox(height: 16),  
            ConstrainedBox(  
              constraints: const BoxConstraints(minHeight: 52, maxHeight: 52),  
              child: SizedBox(  
                width: double.infinity,  
                child: EducaeasyButton(
                  text: 'Já tenho conta',
                  variant: ButtonVariant.outline,
                  onPressed: () {
                    context.go('/login_methods');
                  },
                ),
              ),  
            ), 
            const SizedBox(height: 100),  
          ],  
        ),  
      ),  
    );
  }
}