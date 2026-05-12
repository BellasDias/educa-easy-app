import 'package:flutter/material.dart'; // Necessário para o IconData

enum LevelStatus { completed, current, locked }

class LevelModel {
  final int index;
  final double x;
  final double y;
  final String title;
  final LevelStatus status;
  final bool bubbleOnRight;
  final bool isSpecial;
  final int starCount;

  // 🚀 NOVAS PROPRIEDADES DATA-DRIVEN
  final String? drawerTitle;
  final String? description;
  final List<String> conceptTags;
  final String route;
  final IconData? drawerIcon;

  LevelModel({
    required this.index,
    required this.x,
    required this.y,
    required this.title,
    this.status = LevelStatus.locked,
    this.bubbleOnRight = true,
    this.isSpecial = false,
    this.starCount = 0,

    // Valores padrão para as fases que ainda não configuramos
    this.drawerTitle,
    this.description,
    this.conceptTags = const [],
    this.route = '/sequence_level', // Rota antiga de fallback
    this.drawerIcon,
  });
}
