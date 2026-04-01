import 'package:educaeasy_app/design_system/widgets/onboarding_shell.dart';
import 'package:flutter/material.dart';
import 'package:educaeasy_app/design_system/widgets/input.dart';

class NameInputPage extends StatelessWidget {
  const NameInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      showBackButton: true, 
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(  
          mainAxisSize: MainAxisSize.min, 
          children: [
            const SizedBox(  // ✅ 3. const + height  
              width: double.infinity,  
              height: 52,  
              child: EducaeasyInput(  
                placeholder: 'Seu nome',  
              ),  
            ), 
            const Spacer(),
          ], 
        ),
      ),
    );
  }
}