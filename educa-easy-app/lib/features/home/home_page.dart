import 'package:educaeasy_app/design_system/widgets/button.dart';
import 'package:educaeasy_app/features/home/widgets/home_background.dart';
import 'package:educaeasy_app/features/home/widgets/home_logo.dart';
import 'package:flutter/material.dart';
import '../onboarding/presentation/pages/welcome_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background full tela
          const HomeBackground(),
          
          // Logo NO TOPO
          const Positioned(
            top: 80,  // ← Topo com margem statusbar
            left: 24,
            right: 24,
            child: HomeLogo(),
          ),
          
          // Botão EMBAIXO
          Positioned(
            bottom: 60,
            left: 24,
            right: 24,
            child: EducaeasyButton(
              text: 'Começar',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomePage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
