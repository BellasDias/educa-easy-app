// Enum isolado para garantir segurança de tipos
enum LevelStatus { completed, current, locked }

class LevelModel {
  final int index;
  final double x;
  final double y;
  
  // Propriedades de Design e Estado
  final String title;
  final LevelStatus status;
  final bool bubbleOnRight; 
  
  // Propriedades que estavam faltando!
  final bool isSpecial;
  final int starCount;

  LevelModel({
    required this.index,
    required this.x,
    required this.y,
    required this.title,
    this.status = LevelStatus.locked, // Padrão é bloqueado
    this.bubbleOnRight = true,        // Padrão é balão na direita
    this.isSpecial = false,           // Padrão é nível normal
    this.starCount = 0,               // Padrão é 0 estrelas
  });
}