import 'package:flutter/material.dart';
import '../../domain/models/level_model.dart';
import 'level_icon_widget.dart';

class LevelMapItem extends StatelessWidget {
  final LevelModel level;
  final double badgeSize;
  /// Se true, a caixa fica na esquerda. Se false, fica na direita.
  final bool descriptionOnLeft;

  const LevelMapItem({
    super.key,
    required this.level,
    required this.badgeSize,
    required this.descriptionOnLeft,
  });

  @override
  Widget build(BuildContext context) {
    // Quantos pixels a caixa deve se esconder atrás do ícone
    const double overlap = 32.0; 

    // A caixa de descrição (baseada no design anterior)
    final descriptionBox = Container(
      padding: EdgeInsets.only(
        top: 12,
        bottom: 12,
        // O padding lateral maior fica do lado que está escondido atrás do badge
        left: descriptionOnLeft ? 24 : overlap + 8,
        right: descriptionOnLeft ? overlap + 8 : 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          width: 1,
          color: const Color(0xFFE4E7EB),
        ),
        borderRadius: BorderRadius.horizontal(
          left: descriptionOnLeft ? const Radius.circular(99) : const Radius.circular(24),
          right: descriptionOnLeft ? const Radius.circular(24) : const Radius.circular(99),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFE4E7EB),
            blurRadius: 4,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: descriptionOnLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            'Nível ${level.index}',
            style: const TextStyle(
              color: Color(0xFF323F4B),
              fontSize: 20,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            level.title,
            style: const TextStyle(
              color: Color(0xFF542BD6),
              fontSize: 14,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );

    // O truque: o SizedBox trava o tamanho principal. A descrição vazará para os lados.
    return SizedBox(
      width: badgeSize,
      height: badgeSize,
      child: Stack(
        clipBehavior: Clip.none, // Permite que a descrição vase o tamanho do badge
        alignment: Alignment.center,
        children: [
          // 1. Descrição (Background - fica atrás)
          Positioned(
            left: descriptionOnLeft ? null : badgeSize - overlap,
            right: descriptionOnLeft ? badgeSize - overlap : null,
            child: descriptionBox,
          ),
          
          // 2. O seu Ícone Original (Foreground - fica na frente)
          LevelIconWidget(level: level),
        ],
      ),
    );
  }
}