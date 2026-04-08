import 'package:educaeasy_app/features/levels/presentation/widgets/level_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/models/level_model.dart';
// import 'level_map_node.dart'; // Importe o node que criamos acima

class LevelMapModule extends StatefulWidget {
  const LevelMapModule({super.key});

  @override
  State<LevelMapModule> createState() => _LevelMapModuleState();
}

class _LevelMapModuleState extends State<LevelMapModule> {
  static const double _virtualCanvasWidth = 375.0;
  static const double _virtualCanvasHeight = 1100.0;

  final List<LevelModel> _levelsData = [
    LevelModel(index: 1, x: 180, y: 150, title: "Introdução", status: LevelStatus.completed, starCount: 3),
    LevelModel(index: 2, x: 280, y: 300, title: "Fundamentos", status: LevelStatus.completed, starCount: 2),
    LevelModel(index: 3, x: 100, y: 450, title: "Variáveis", status: LevelStatus.current),
    LevelModel(index: 4, x: 250, y: 600, title: "Condicionais", status: LevelStatus.locked),
    LevelModel(index: 5, x: 180, y: 780, title: "Desafio 1", status: LevelStatus.locked, isSpecial: true),
    LevelModel(index: 6, x: 300, y: 950, title: "Laços", status: LevelStatus.locked),
    LevelModel(index: 7, x: 120, y: 1100, title: "Funções", status: LevelStatus.locked),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: double.infinity,
            height: _virtualCanvasHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _buildBackgroundLayer(),
                _buildPathLayer(),
                ..._buildLevelsLayer(constraints),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundLayer() {
    return Positioned.fill(
      child: IgnorePointer(
        child: SvgPicture.asset(
          'assets/svg/dots.svg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPathLayer() {
    return Positioned.fill(
      child: SvgPicture.asset(
        'assets/svg/path.svg',
        fit: BoxFit.cover,
        alignment: Alignment.center,
      ),
    );
  }

  List<Widget> _buildLevelsLayer(BoxConstraints constraints) {
    return _levelsData.map((level) {
      final double realX = (level.x / _virtualCanvasWidth) * constraints.maxWidth;
      final double realY = level.y;

      final double componentSize = level.isSpecial ? 124.0 : 108.0;
      final double halfSize = componentSize / 2;

      // LÓGICA DE DIREÇÃO: Se o node estiver na metade direita da tela,
      // a descrição deve ir para a esquerda, e vice-versa.
      final bool descriptionGoesLeft = realX >= (constraints.maxWidth / 2);

      return Positioned(
        left: realX - halfSize,
        top: realY - halfSize,
        // Removemos a Column antiga e chamamos o nosso novo Node!
        child: LevelMapItem(
          level: level,
          badgeSize: componentSize,
          descriptionOnLeft: descriptionGoesLeft,
        ),
      );
    }).toList();
  }
}