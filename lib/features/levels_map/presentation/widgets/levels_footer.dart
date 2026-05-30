import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LevelsFooter extends StatelessWidget {
  const LevelsFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 2)),
      ),
      child: const Padding(
        padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _FooterItem(icon: Icons.home_rounded, isSelected: true),

            // ✅ CORREÇÃO: Adicionado a lógica para escutar o clique do troféu
            _FooterItem(
              icon: Icons.emoji_events_rounded,
              isSelected: false,
              isTrophies: true,
            ),

            // O ícone de perfil agora tem a lógica de navegação direta
            _FooterItem(
              icon: Icons.person_rounded,
              isSelected: false,
              isProfile: true,
            ),
          ],
        ),
      ),
    );
  }
}

// 🚀 CLEAN CODE: Transformamos em StatelessWidget! Fim da complexidade.
class _FooterItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final bool isProfile;
  final bool isTrophies; // ✅ ADICIONADO

  const _FooterItem({
    required this.icon,
    required this.isSelected,
    this.isProfile = false,
    this.isTrophies = false, // ✅ ADICIONADO
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return IconButton(
      icon: Icon(
        icon, // Acessamos a variável direto, sem precisar do "widget.icon"
        size: 36,
        color: isSelected ? primaryColor : Colors.grey.shade400,
      ),
      onPressed: () {
        if (isProfile) {
          // Usa a rota definida no seu AppRouter
          context.push('/profile');
        } else if (isTrophies) {
          // ✅ ENTRANDO EM AÇÃO: Redireciona direto para a galeria gamer de conquistas!
          context.push('/trophies');
        } else {
          // Trocamos print por debugPrint para seguir as boas práticas!
          debugPrint('Navegando para o Mapa Principal...');
        }
      },
    );
  }
}
