import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
// Importe o seu AvatarService aqui conforme a estrutura do seu projeto
import 'package:educaeasy_app/features/store/data/avatar_service.dart';

class LevelsHeader extends StatelessWidget {
  const LevelsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Instancia o serviço que gerencia o estado global do avatar
    final AvatarService avatarService = AvatarService();

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment
            .spaceBetween, // Afasta o Fogo para a esquerda e Avatar para a direita
        children: [
          // 1. Ofensiva (Fogo)
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                '12',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          // ========================================================
          // 2. BLOCO DO AVATAR REATIVO (Acesso à Loja)
          // ========================================================
          GestureDetector(
            onTap: () {
              context.push('/store');
            },
            child: ValueListenableBuilder<String?>(
              valueListenable: avatarService.selectedAvatarNotifier,
              builder: (context, selectedSvg, child) {
                return Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: selectedSvg != null
                        ? Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: SvgPicture.string(
                              selectedSvg,
                              fit: BoxFit.contain,
                            ),
                          )
                        : const Icon(
                            Icons
                                .shopping_bag_rounded, // Fallback caso nenhum esteja selecionado
                            color: Colors.amber,
                            size: 20,
                          ),
                  ),
                );
              },
            ),
          ),
          // ========================================================
        ],
      ),
    );
  }
}
