import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart'; // 💡 Certifique-se de importar o flutter_svg
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Lado Esquerdo: Bandeira / Módulo Atual
          Row(
            children: [
              Container(
                width: 32,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50, 
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Icon(Icons.flag_rounded, size: 16, color: Colors.blue),
              ),
            ],
          ),

          // 2. Centro: Ofensiva
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded, color: Colors.orange),
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

          // 3. Lado Direito: Vidas / Corações
          Row(
            children: [
              const Icon(Icons.favorite_rounded, color: Colors.red),
              const SizedBox(width: 4),
              Text(
                '5', 
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          // ========================================================
          // 4. BLOCO DO AVATAR REATIVO (Acesso à Loja)
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
                            Icons.shopping_bag_rounded, // Fallback caso nenhum esteja selecionado
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