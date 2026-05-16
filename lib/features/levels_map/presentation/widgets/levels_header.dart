import 'package:flutter/material.dart';

class LevelsHeader extends StatelessWidget {
  const LevelsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        // Borda cinza suave para separar o Header do Mapa (Clean UI)
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

          // 2. Centro: Ofensiva (Dias seguidos jogando)
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded, color: Colors.orange),
              const SizedBox(width: 4),
              Text(
                '12', // Exemplo estático
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
                '5', // Exemplo estático
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}