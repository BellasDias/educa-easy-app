import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/level_model.dart';
import 'level_drawer.dart';

/// Widget responsável por exibir o nó de nível no mapa.
///
/// Regras de negócio visuais:
/// - Mantém o visual principal do design (container branco com borda cinza e sombra inferior);
/// - Ajusta estados (locked/current/completed) sem acoplar lógica diretamente na árvore;
/// - Exibe estrelas apenas quando o nível pode ser acessado e possui progresso.
class LevelIconWidget extends StatelessWidget {
  final LevelModel level;

  const LevelIconWidget({super.key, required this.level});

  // Tokens visuais centralizados para facilitar manutenção e evolução de design system.
  static const Color _baseBackgroundColor = Colors.white;
  static const Color _defaultBorderColor = Color(0xFFE4E7EB); // gray-10
  static const Color _defaultBottomShadowColor = Color(0xFFCBD2D9); // gray-30
  static const Color _numberColor = Color(0xFF323F4B); // gray-80
  static const Color _activeAccentColor = Color(0xFF2D9CDB);
  static const Color _completedAccentColor = Color(0xFF4CAF50);

  // Escala visual do componente.
  static const double _regularSize = 108;
  static const double _specialSize = 124;
  static const double _borderWidth = 4;
  static const double _bottomShadowOffsetY = 8;
  static const double _numberFontSize = 56;
  static const double _specialIconSize = 42;
  static const double _lockIconSize = 40;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Habilita clique apenas para níveis desbloqueados.
      onTap: _isLocked ? null : () => _handleTap(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLevelBadge(),
          if (_shouldShowStars) ...[
            const SizedBox(height: 8),
            _buildStarsRow(),
          ],
        ],
      ),
    );
  }

  /// Indica se o nível está bloqueado.
  bool get _isLocked => level.status == LevelStatus.locked;

  /// Indica se o nível está atualmente ativo.
  bool get _isCurrent => level.status == LevelStatus.current;

  /// Exibe estrelas apenas em níveis acessíveis com progresso.
  bool get _shouldShowStars => !_isLocked && level.starCount > 0;

  /// Define tamanho do badge conforme tipo do nível.
  double get _badgeSize => level.isSpecial ? _specialSize : _regularSize;

  /// Cor de borda orientada ao estado para reforço visual discreto.
  Color get _borderColor {
    if (_isLocked) return _defaultBorderColor;
    if (_isCurrent) return _activeAccentColor;
    return _completedAccentColor;
  }

  /// Constrói o badge principal no estilo do design desejado.
  Widget _buildLevelBadge() {
    return Container(
      width: _badgeSize,
      height: _badgeSize,
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: _baseBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: _borderColor, width: _borderWidth),
        ),
        shadows: const [
          // Sombra seca no eixo Y para aproximar do mock de referência.
          BoxShadow(
            color: _defaultBottomShadowColor,
            blurRadius: 0,
            offset: Offset(0, _bottomShadowOffsetY),
          ),
        ],
      ),
      child: Center(child: _buildInnerContent()),
    );
  }

  /// Renderiza conteúdo interno do badge com prioridade por regra:
  /// 1) nível especial -> ícone de recompensa;
  /// 2) nível bloqueado -> cadeado;
  /// 3) nível comum acessível -> número do nível.
  Widget _buildInnerContent() {
    if (level.isSpecial) {
      return Icon(
        Icons.redeem_rounded,
        size: _specialIconSize,
        color: _isLocked ? Colors.grey.shade500 : _numberColor,
      );
    }

    if (_isLocked) {
      return Icon(
        Icons.lock_rounded,
        size: _lockIconSize,
        color: Colors.grey.shade500,
      );
    }

    return Text(
      '${level.index}',
      style: const TextStyle(
        color: _numberColor,
        fontSize: _numberFontSize,
        fontWeight: FontWeight.w800,
        height: 0.97,
      ),
    );
  }

  /// Componente isolado para facilitar evolução (animação, badges extras, etc).
  Widget _buildStarsRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        level.starCount,
        (_) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 1),
          child: Icon(Icons.star, color: Color(0xFFFFD700), size: 18),
        ),
      ),
    );
  }

  /// Callback do clique em nível acessível.
  void _handleTap(BuildContext context) {
    // Não importa qual fase seja clicada, a gaveta universal resolve!
    LevelDrawer.show(context, level: level);
  }
}
