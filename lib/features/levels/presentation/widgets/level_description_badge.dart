import 'package:flutter/material.dart';

class LevelDescriptionBadge extends StatelessWidget {
  final String title;
  final String subtitle;
  /// Pode receber um Text('2') ou um Icon(Icons.star), por exemplo.
  final Widget badgeContent;
  /// Controla a posição da descrição: true (esquerda), false (direita).
  final bool descriptionOnLeft;

  const LevelDescriptionBadge({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.badgeContent,
    this.descriptionOnLeft = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Variáveis para controlar o tamanho e a sobreposição do ícone
    const double badgeSize = 88.0;
    const double overlap = 24.0; 
    const double reservedSpace = badgeSize - overlap;

    // 1. Caixa de Descrição
    final descriptionBox = Container(
      padding: EdgeInsets.only(
        top: 14,
        bottom: 14,
        // Adiciona um padding extra do lado em que o ícone vai sobrepor
        left: descriptionOnLeft ? 32 : overlap + 16,
        right: descriptionOnLeft ? overlap + 16 : 32,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          width: 1,
          color: const Color(0xFFE4E7EB), /* gray-10 */
        ),
        borderRadius: BorderRadius.horizontal(
          left: descriptionOnLeft
              ? const Radius.circular(99)
              : const Radius.circular(24), // Curva menor para esconder atrás do badge
          right: descriptionOnLeft
              ? const Radius.circular(24)
              : const Radius.circular(99),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFE4E7EB),
            blurRadius: 0,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: descriptionOnLeft
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF323F4B), /* gray-80 */
              fontSize: 24,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF542BD6), /* purple-dark2 */
              fontSize: 16,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );

    // 2. Ícone / Badge Circular
    final badge = Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFE4E7EB),
          width: 6,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFD1D5DB),
            blurRadius: 0,
            offset: Offset(0, 4),
          )
        ],
      ),
      alignment: Alignment.center,
      // Força o estilo padrão para textos e ícones passados como badgeContent
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Color(0xFF323F4B),
          fontSize: 40,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
        ),
        child: IconTheme(
          data: const IconThemeData(
            color: Color(0xFF323F4B),
            size: 40,
          ),
          child: badgeContent,
        ),
      ),
    );

    // 3. Montagem com Stack para sobreposição perfeita
    return Stack(
      alignment: Alignment.center,
      children: [
        // O padding garante que o Stack tenha a largura certa e não esprema o conteúdo
        Padding(
          padding: EdgeInsets.only(
            left: descriptionOnLeft ? 0 : reservedSpace,
            right: descriptionOnLeft ? reservedSpace : 0,
          ),
          child: descriptionBox,
        ),
        // O badge fica ancorado nas extremidades dependendo do layout escolhido
        Positioned(
          left: descriptionOnLeft ? null : 0,
          right: descriptionOnLeft ? 0 : null,
          child: badge,
        ),
      ],
    );
  }
}