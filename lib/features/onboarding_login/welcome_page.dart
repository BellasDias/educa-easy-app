import 'package:educaeasy_app/design_system/tokens/colors.dart';
import 'package:educaeasy_app/design_system/widgets/button.dart';
import 'package:educaeasy_app/design_system/widgets/onboarding_shell.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import './name_input_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      showBackButton: false,
        child: Padding(  
          padding: EdgeInsets.only(  // Deixando os components (botões) no centro da tela 
            top: MediaQuery.of(context).size.height * 0.35,  
            bottom: MediaQuery.of(context).size.height * 0.25,  
          ), 
          child: Column(  
            mainAxisAlignment: MainAxisAlignment.center,  
            mainAxisSize: MainAxisSize.min,  
            children: [  
              ConstrainedBox(  // ← FORÇA altura finita  
                constraints: const BoxConstraints(  
                  minHeight: 52,  
                  maxHeight: 52,  
                ),  
                child: SizedBox(  
                  width: double.infinity,  
                  child: EducaeasyButton(
                      text: 'Começar',
                      variant: ButtonVariant.primary,  // ← Roxo!
                      icon: Icon(
                        LucideIcons.play,
                        color: AppColors.gray00,  // ← Branco no roxo
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NameInputPage(),
                          ),
                        );
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
                      onPressed: () {},
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
