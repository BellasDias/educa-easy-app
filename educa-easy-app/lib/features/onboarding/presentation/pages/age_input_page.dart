import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:educaeasy_app/design_system/tokens/colors.dart';
import 'package:educaeasy_app/design_system/tokens/typography.dart';
import 'package:educaeasy_app/design_system/widgets/age_picker.dart';
import 'package:educaeasy_app/design_system/widgets/onboarding_shell.dart';
import 'package:educaeasy_app/design_system/widgets/button.dart';
import '../../data/firebase_auth_repository_impl.dart'; 

class AgeInputPage extends StatefulWidget {
  const AgeInputPage({super.key});

  @override
  State<AgeInputPage> createState() => _AgeInputPageState();
}

class _AgeInputPageState extends State<AgeInputPage> {
  // Definindo a idade inicial e mínima como constantes para Clean Code
  static const int _minAge = 5;
  int _currentAge = _minAge;
  bool _isLoading = false;

  // Idealmente, usando Clean Architecture, isso viria via Injeção de Dependência (ex: GetIt)
  final _authRepository = FirebaseAuthRepositoryImpl(FirebaseAuth.instance);

  Future<void> _handleContinue() async {
    setState(() => _isLoading = true);

    try {
      await _authRepository.saveUserAge(_currentAge);
      
      if (mounted) {
        // Se deu sucesso, redireciona
        context.push('/login_methods'); 
      }
    } catch (e) {
      debugPrint('Erro ao salvar idade: $e');
      
      // NOVO: Mostra um aviso visual do erro na tela
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao continuar. Tente novamente! ($e)'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      showBackButton: true,
      footer: EducaeasyButton(
        text: _isLoading ? 'Salvando...' : 'Continuar',
        variant: ButtonVariant.primary,
        onPressed: _isLoading ? () {} : _handleContinue, // Bloqueia múltiplos cliques
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
              "Quantos anos você tem?", // Texto corrigido
              style: AppTypography.title(color: AppColors.gray40),
            ),
            AgePicker(
              initialAge: _currentAge, // Sincronizado com o estado
              minAge: _minAge,         // Sincronizado com o estado
              maxAge: 100,
              onAgeChanged: (age) {
                setState(() {
                  _currentAge = age;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}