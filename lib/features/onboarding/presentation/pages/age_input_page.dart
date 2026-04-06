import 'package:educaeasy_app/design_system/tokens/colors.dart';
import 'package:educaeasy_app/design_system/tokens/typography.dart';
import 'package:educaeasy_app/design_system/widgets/age_picker.dart';
import 'package:flutter/material.dart';
import 'package:educaeasy_app/design_system/widgets/onboarding_shell.dart';
import 'package:educaeasy_app/design_system/widgets/button.dart';
// importe o AgePicker

class AgeInputPage extends StatefulWidget {
  const AgeInputPage({super.key});

  @override
  State<AgeInputPage> createState() => _AgeInputPageState();
}

class _AgeInputPageState extends State<AgeInputPage> {
  int _currentAge = 5; // Estado guardado na página

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      showBackButton: true,
      // Footer dinâmico com o botão de continuar
      footer: EducaeasyButton(
        text: 'Continuar',
        onPressed: () {
          print('Idade selecionada para salvar: $_currentAge');
          // Aqui você salva a idade e dá um context.push() para a próxima tela
        },
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.25,
          bottom: 24,
        ),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Text(
              "Como você se chama?",
              style: AppTypography.title(color: AppColors.gray40),
            ),
            AgePicker(
              initialAge: 19,
              minAge: 10,
              maxAge: 100,
              onAgeChanged: (age) {
                setState(() {
                  _currentAge = age; // Atualiza o estado da página
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}