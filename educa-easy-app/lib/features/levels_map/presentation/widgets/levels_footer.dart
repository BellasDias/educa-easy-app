import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class LevelsFooter extends StatelessWidget {
  const LevelsFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 2),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _FooterItem(icon: Icons.home_rounded, isSelected: true),
            _FooterItem(icon: Icons.emoji_events_rounded, isSelected: false),
            // O ícone de perfil agora tem a lógica de logout
            _FooterItem(
              icon: Icons.person_rounded, 
              isSelected: false, 
              isProfile: true, // Flag para habilitar o triplo clique
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterItem extends StatefulWidget {
  final IconData icon;
  final bool isSelected;
  final bool isProfile;

  const _FooterItem({
    required this.icon, 
    required this.isSelected, 
    this.isProfile = false,
  });

  @override
  State<_FooterItem> createState() => _FooterItemState();
}

class _FooterItemState extends State<_FooterItem> {
  int _clickCount = 0;
  Timer? _resetTimer;

  // Lógica para processar cliques seguidos
  void _handleProfileClick() async {
    _resetTimer?.cancel(); // Cancela o timer anterior se houver
    
    setState(() {
      _clickCount++;
    });

    if (_clickCount == 3) {
      _clickCount = 0;
      await _logout();
    } else {
      // Se não clicar de novo em 500ms, o contador zera
      _resetTimer = Timer(const Duration(milliseconds: 500), () {
        _clickCount = 0;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        // Como o GoRouter no app_router.dart observa o estado do Firebase,
        // ele deve redirecionar automaticamente, mas forçamos para garantir o teste.
        context.go('/home'); 
      }
    } catch (e) {
      debugPrint('Erro ao desconectar: $e');
    }
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return IconButton(
      icon: Icon(
        widget.icon,
        size: 36,
        color: widget.isSelected ? primaryColor : Colors.grey.shade400,
      ),
      onPressed: () {
        if (widget.isProfile) {
          _handleProfileClick();
        } else {
          print('Navegando...');
        }
      },
    );
  }
}