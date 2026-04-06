import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/models/level_model.dart';
// Importe o novo widget que criamos juntos no passo anterior
import 'map_level_item_widget.dart' hide LevelStatus; 

class LevelMapModule extends StatefulWidget {
  const LevelMapModule({super.key});

  @override
  State<LevelMapModule> createState() => _LevelMapModuleState();
}

class _LevelMapModuleState extends State<LevelMapModule> {
  static const double _virtualCanvasWidth = 375.0; 
  static const double _virtualCanvasHeight = 1100.0; 

  // DADOS ATUALIZADOS COM CLEAN ARCHITECTURE
  // Agora temos o Título e o Status explícito (Enum).
  // Brinque com o "bubbleOnRight" false/true para ver os balões mudando de lado
  // dependendo da curva da pista!
  final List<LevelModel> _levelsData = [
    LevelModel(index: 1, x: 180, y: 150, title: "Introdução", status: LevelStatus.completed, bubbleOnRight: false),
    LevelModel(index: 2, x: 280, y: 300, title: "Fundamentos", status: LevelStatus.completed, bubbleOnRight: false),
    LevelModel(index: 3, x: 100, y: 450, title: "Variáveis", status: LevelStatus.current, bubbleOnRight: true),
    LevelModel(index: 4, x: 250, y: 600, title: "Condicionais", status: LevelStatus.locked, bubbleOnRight: false),
    LevelModel(index: 5, x: 180, y: 780, title: "Desafio 1", status: LevelStatus.locked, bubbleOnRight: true), 
    LevelModel(index: 6, x: 300, y: 950, title: "Laços de Repetição", status: LevelStatus.locked, bubbleOnRight: false),
    LevelModel(index: 7, x: 120, y: 1100, title: "Funções", status: LevelStatus.locked, bubbleOnRight: true),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        width: double.infinity,
        height: _virtualCanvasHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.none, 
              children: [
                // 1. A CAMADA DO CAMINHO (Pista SVG)
                Positioned.fill(
                  child: SvgPicture.asset(
                    'assets/svg/path.svg',
                    fit: BoxFit.cover, 
                    alignment: Alignment.center,
                  ),
                ),

                // 2. A CAMADA DOS NÍVEIS
                ..._levelsData.map((level) {
                  final double realX = (level.x / _virtualCanvasWidth) * constraints.maxWidth;
                  final double realY = level.y;
                  
                  // Raio do círculo (56px / 2 = 28). Usado para ancorar exatamente o meio da bolinha.
                  const double circleRadius = 28.0; 

                  return Positioned(
                    // GEOMETRIA DE INTERFACE LIMPA:
                    // Se o balão está na direita, o canto esquerdo da linha é a bolinha.
                    left: level.bubbleOnRight ? (realX - circleRadius) : null,
                    // Se o balão está na esquerda, o canto direito da linha é a bolinha.
                    right: level.bubbleOnRight ? null : (constraints.maxWidth - realX - circleRadius),
                    // O eixo Y sempre desconta o raio para o meio da bolinha ficar na coordenada
                    top: realY - circleRadius,
                    
                    child: MapLevelItemWidget(
                      levelNumber: level.index,
                      title: level.title,
                      status: level.status,
                      bubbleOnRight: level.bubbleOnRight,
                    ),
                  );
                }),
              ],
            );
          }
        ),
      ),
    );
  }
}