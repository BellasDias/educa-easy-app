import 'package:flutter/material.dart';
import '../../domain/models/level_model.dart';

class LevelIconWidget extends StatelessWidget {
  final LevelModel level;
  
  const LevelIconWidget({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    Color mainColor = const Color(0xFF4CAF50); // Verde (Concluído)
    Color textColor = Colors.white;
    
    // 1. CLEAN CODE: Lendo o Enum em vez dos antigos booleanos
    if (level.status == LevelStatus.current) {
      mainColor = const Color(0xFF2196F3); // Azul (Atual/Ativo)
    } else if (level.status == LevelStatus.locked) {
      mainColor = Colors.grey.shade300; // Cinza (Bloqueado)
      textColor = Colors.grey.shade600;
    }

    return GestureDetector(
      onTap: () {
        // 2. CLEAN CODE: Validação de clique baseada no Enum
        if (level.status != LevelStatus.locked) {
          print('Abrindo nível ${level.index}');
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: level.isSpecial ? 80 : 64,
            height: level.isSpecial ? 80 : 64,
            decoration: BoxDecoration(
              color: mainColor,
              shape: BoxShape.circle,
              border: Border.all(
                // 3. CLEAN CODE: Validação de borda baseada no Enum
                color: level.status == LevelStatus.locked ? Colors.grey.shade400 : Colors.white,
                width: 5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: level.isSpecial
                  ? const Icon(Icons.redeem, color: Colors.white, size: 40)
                  : (level.status == LevelStatus.locked
                      ? const Icon(Icons.lock_rounded, color: Colors.grey)
                      : Text(
                          '${level.index}',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
            ),
          ),
          // 4. CLEAN CODE: Mostra estrelas apenas se não estiver bloqueado e tiver estrelas
          if (level.status != LevelStatus.locked && level.starCount > 0) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                level.starCount,
                (index) => const Icon(Icons.star, color: Color(0xFFFFD700), size: 20),
              ),
            ),
          ],
        ],
      ),
    );
  }
}