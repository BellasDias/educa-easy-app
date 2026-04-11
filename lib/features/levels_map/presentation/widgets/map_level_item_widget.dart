import 'package:flutter/material.dart';
import '../../domain/models/level_model.dart'; 

// ==========================================
// O COMPONENTE VISUAL (O Maestro)
// ==========================================
class MapLevelItemWidget extends StatelessWidget {
  final int levelNumber; // Mantido para compatibilidade de dados
  final String title;
  final LevelStatus status;
  final bool bubbleOnRight; 

  const MapLevelItemWidget({
    super.key,
    required this.levelNumber,
    required this.title,
    required this.status,
    this.bubbleOnRight = true, 
  });

  @override
  Widget build(BuildContext context) {
    // Instancia as regras de design
    final styles = _LevelStyles(status: status, context: context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: bubbleOnRight ? TextDirection.ltr : TextDirection.rtl,
      children: [
        _LevelCircle(styles: styles),
        const SizedBox(width: 16), 
        _LevelDescriptionBubble(title: title, styles: styles),
      ],
    );
  }
}

// ==========================================
// SUB-WIDGET: CÍRCULO DO NÍVEL 
// ==========================================
class _LevelCircle extends StatelessWidget {
  final _LevelStyles styles;

  const _LevelCircle({required this.styles});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56, 
      height: 56,
      decoration: BoxDecoration(
        color: styles.circleColor,
        shape: BoxShape.circle,
        // Borda branca grossa presente em todos os círculos da imagem
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: styles.commonShadow, 
      ),
      child: Center(
        child: Icon(
          styles.circleIcon,
          color: styles.circleIconColor,
          size: 28,
        ),
      ),
    );
  }
}

// ==========================================
// SUB-WIDGET: BALÃO DE DESCRIÇÃO 
// ==========================================
class _LevelDescriptionBubble extends StatelessWidget {
  final String title;
  final _LevelStyles styles;

  const _LevelDescriptionBubble({required this.title, required this.styles});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Padding ajustado para ficar mais "gordinho" como na imagem
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: styles.bubbleColor,
        // Borda 100% arredondada (formato de pílula)
        borderRadius: BorderRadius.circular(100), 
        // Sombra adicionada ao balão
        boxShadow: styles.commonShadow,
      ),
      child: Text(
        title,
        style: styles.bubbleTextStyle,
      ),
    );
  }
}

// ==========================================
// CLASSE AUXILIAR DE ESTILO (Design System Isolado)
// ==========================================
class _LevelStyles {
  final LevelStatus status;
  final BuildContext context;

  _LevelStyles({required this.status, required this.context});
  
  // Paleta de Cores extraída da imagem
  static const Color _green = Color(0xFF58CC02);   // Verde vibrante (Concluído)
  static const Color _purple = Color(0xFFA855F7);  // Roxo vibrante (Atual)
  static const Color _lightGray = Color(0xFFE5E7EB); // Cinza claro (Círculo Bloqueado)
  static const Color _darkGray = Color(0xFF9CA3AF);  // Cinza escuro (Ícone/Texto Bloqueado)

  // 1. Cor de Fundo do Círculo
  Color get circleColor {
    switch (status) {
      case LevelStatus.completed: return _green; 
      case LevelStatus.current:   return _purple; 
      case LevelStatus.locked:    return _lightGray; 
    }
  }

  // 2. Cor de Fundo do Balão
  Color get bubbleColor {
    switch (status) {
      // Concluído e Bloqueado possuem fundo branco na imagem
      case LevelStatus.completed: return Colors.white; 
      case LevelStatus.current:   return _purple; 
      case LevelStatus.locked:    return Colors.white; 
    }
  }

  // 3. Estilo do Texto do Balão
  TextStyle get bubbleTextStyle {
    Color textColor;
    switch (status) {
      case LevelStatus.completed: textColor = _green; break;
      case LevelStatus.current:   textColor = Colors.white; break;
      case LevelStatus.locked:    textColor = _darkGray; break;
    }

    return TextStyle(
      color: textColor,
      fontSize: 16, 
      fontWeight: FontWeight.w700, // Fonte mais bold acompanhando o design
      letterSpacing: 0.5,
    );
  }

  // 4. Ícone do Círculo
  IconData get circleIcon {
    switch (status) {
      case LevelStatus.completed: return Icons.check_rounded;
      case LevelStatus.current:   return Icons.star_rounded;
      case LevelStatus.locked:    return Icons.lock_rounded;
    }
  }

  // 5. Cor do Ícone do Círculo
  Color get circleIconColor {
    switch (status) {
      case LevelStatus.completed: return Colors.white;
      case LevelStatus.current:   return Colors.white;
      case LevelStatus.locked:    return _darkGray;
    }
  }

  // 6. Sombra Padrão (Drop Shadow Universal)
  List<BoxShadow> get commonShadow {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.12),
        blurRadius: 8,
        offset: const Offset(0, 4), // Sombra caindo levemente para baixo
      )
    ];
  }
}