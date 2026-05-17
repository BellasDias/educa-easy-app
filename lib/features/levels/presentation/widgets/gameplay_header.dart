import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GameplayHeader extends StatelessWidget {
  final double progress; // Valor de 0.0 a 1.0
  final VoidCallback onBackPressed;
  final String svgIconPath;

  const GameplayHeader({
    super.key,
    required this.progress,
    required this.onBackPressed,
    required this.svgIconPath,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            // Botão de voltar sem borda
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
              onPressed: onBackPressed,
              splashRadius: 24,
            ),
            const SizedBox(width: 8),
            // Linha de progresso
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // SVG ao lado (vidas, energia, etc)
            SvgPicture.asset(
              svgIconPath,
              width: 32,
              height: 32,
            ),
          ],
        ),
      ),
    );
  }
}