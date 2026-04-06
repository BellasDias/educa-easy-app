import 'package:flutter/material.dart';

class LevelsFooter extends StatelessWidget {
  const LevelsFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        // Borda superior para separar o Footer do Mapa
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 2),
        ),
      ),
      child: const Padding(
        // Padding bottom levanta os ícones um pouco para não colar no fim da tela
        padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Extraímos a lógica do botão para um sub-componente privado (_FooterItem)
            _FooterItem(icon: Icons.home_rounded, isSelected: true),
            _FooterItem(icon: Icons.emoji_events_rounded, isSelected: false),
            _FooterItem(icon: Icons.person_rounded, isSelected: false),
          ],
        ),
      ),
    );
  }
}

// Sub-componente Privado (Clean Code: Evita repetição de código no Footer)
class _FooterItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const _FooterItem({required this.icon, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    // Pega a cor primária do seu design_system/theme/app_theme.dart
    final primaryColor = Theme.of(context).primaryColor;
    
    return IconButton(
      icon: Icon(
        icon,
        size: 36, // Ícones grandes e acessíveis
        // Pinta com a cor do app se selecionado, senão pinta de cinza
        color: isSelected ? primaryColor : Colors.grey.shade400,
      ),
      onPressed: () {
        // No futuro, aqui terá o context.go() para navegar
        print('Navegando...');
      },
    );
  }
}