import 'package:flutter/material.dart';

// Importe seus widgets aqui! Ajuste o caminho se necessário.
import '../widgets/level_map_module.dart';
import '../widgets/levels_header.dart'; 
import '../widgets/levels_footer.dart'; 

class LevelsPage extends StatelessWidget {
  const LevelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            LevelsHeader(), // Seu componente de Header isolado
            
            Expanded(
              child: LevelMapModule(), // O módulo do mapa
            ),
            
            LevelsFooter(), // Seu componente de Footer isolado
          ],
        ),
      ),
    );
  }
}

