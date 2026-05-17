import 'package:educaeasy_app/features/levels_map/presentation/widgets/level_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 🚀 Import do Riverpod adicionado
import '../../domain/models/level_model.dart';
// ⚠️ Ajuste este caminho abaixo para onde você salvou o seu map_progress_provider.dart
import '../../domain/map_progress_provider.dart';

class LevelMapModule extends ConsumerStatefulWidget {
  // 🚀 Agora é Consumer!
  const LevelMapModule({super.key});

  @override
  ConsumerState<LevelMapModule> createState() => _LevelMapModuleState();
}

class _LevelMapModuleState extends ConsumerState<LevelMapModule> {
  static const double _virtualCanvasWidth = 375.0;
  static const double _virtualCanvasHeight = 1100.0;

  // Lógica inteligente para definir se a fase está completa, atual ou trancada!
  LevelStatus _getStatus(int levelIndex, int currentProgress) {
    if (levelIndex < currentProgress) return LevelStatus.completed;
    if (levelIndex == currentProgress) return LevelStatus.current;
    return LevelStatus.locked;
  }

  // A lista agora é gerada dinamicamente baseada no progresso do jogador
  List<LevelModel> _getDynamicLevels(int currentProgress) {
    return [
      LevelModel(
        index: 1,
        x: 180,
        y: 150,
        title: "Introdução",
        status: _getStatus(1, currentProgress),
        drawerTitle: "A Ordem das Coisas",
        description:
            "Você já reparou que tudo tem um jeito certo de ser feito? Primeiro colocamos as meias, só depois os sapatos! Vamos aprender a organizar nossas ações passo a passo.",
        conceptTags: ['Passos', 'Ordem', 'Organização'],
        route: '/lesson-one',
        drawerIcon: Icons.format_list_numbered_rounded,
      ),
      LevelModel(
        index: 2,
        x: 280,
        y: 300,
        title: "Fundamentos",
        status: _getStatus(2, currentProgress),
        drawerTitle: "A Continuidade",
        description:
            "Agora que já sabemos que tudo tem uma ordem, vamos treinar a sequência correta dos números. Você sabe quem vem depois de quem?",
        conceptTags: ['Sequência', 'Números', 'Lógica'],
        route: '/lesson-two',
        drawerIcon: Icons.format_list_numbered_rtl_rounded,
      ),

      // 🚀 Fase 3 com os dados da nossa Gaveta Genérica!
      LevelModel(
        index: 3,
        x: 100,
        y: 450,
        title: "Variáveis",
        status: _getStatus(3, currentProgress),
        drawerTitle: "As Caixas Mágicas",
        description:
            "Você sabia que os computadores usam 'caixinhas' para guardar informações de certo tipo nelas? Elas se chamam Variáveis! Vamos aprender a guardar objetos dentro de seus respectivos recipientes.",
        conceptTags: ['Lancheira', '=', 'Caderno'],
        route: '/lesson-three',
        drawerIcon: Icons.backpack_rounded,
      ),

      LevelModel(
        index: 4,
        x: 250,
        y: 600,
        title: "Condicionais",
        status: _getStatus(4, currentProgress),
        drawerTitle: "Caminhos e Escolhas",
        description:
            "Às vezes precisamos decidir o que fazer dependendo do que acontece à nossa volta. Vamos ajudar a escolher o melhor caminho?",
        conceptTags: ['Escolhas', 'Caminhos', 'Decisão'],
        route: '/lesson-four',
        drawerIcon: Icons.alt_route_rounded,
      ),
      LevelModel(
        index: 5,
        x: 180,
        y: 780,
        title: "Desafio 1",
        status: _getStatus(5, currentProgress),
        isSpecial: true,
        drawerTitle: "Missão Espacial",
        description:
            "Alerta de Desafio! Prepare a nave aplicando tudo o que você aprendeu sobre sequência, lógica e condições.",
        conceptTags: ['Revisão', 'Desafio', 'Nave Espacial'],
        route: '/lesson-five',
        drawerIcon: Icons.rocket_rounded,
      ),
      LevelModel(
        index: 6,
        x: 300,
        y: 950,
        title: "Laços",
        status: _getStatus(6, currentProgress),
        drawerTitle: "A Rotina Diária",
        description:
            "Você sabia que a gente repete algumas coisas várias vezes até que elas terminem? Isso se chama Laço de Repetição! Vamos organizar nossa rotina?",
        conceptTags: ['Repetição', 'Rotina', 'Enquanto'],
        route: '/lesson-six',
        drawerIcon: Icons.loop_rounded,
      ),
      LevelModel(
        index: 7,
        x: 120,
        y: 1100,
        title: "Funções",
        status: _getStatus(7, currentProgress),
        drawerTitle: "Receitas Prontas",
        description:
            "Em vez de fazer a mesma coisa passo a passo toda vez, podemos criar uma Receita Pronta! Vamos descobrir quais comandos agrupam nossas ações?",
        conceptTags: ['Funções', 'Comandos', 'Agrupar'],
        route: '/lesson-seven',
        drawerIcon: Icons.menu_book_rounded,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // O Mapa ESCUTA o progresso do jogador em tempo real!
    final currentProgress = ref.watch(mapProgressProvider);
    final dynamicLevels = _getDynamicLevels(currentProgress);

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
                ..._buildLevelsLayer(
                  constraints,
                  dynamicLevels,
                ), // Passamos a lista dinâmica aqui
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
        child: SvgPicture.asset('assets/svg/dots.svg', fit: BoxFit.cover),
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

  // Recebe a lista dinâmica que geramos no build()
  List<Widget> _buildLevelsLayer(
    BoxConstraints constraints,
    List<LevelModel> levels,
  ) {
    return levels.map((level) {
      final double realX =
          (level.x / _virtualCanvasWidth) * constraints.maxWidth;
      final double realY = level.y;

      final double componentSize = level.isSpecial ? 124.0 : 108.0;
      final double halfSize = componentSize / 2;

      final bool descriptionGoesLeft = realX >= (constraints.maxWidth / 2);

      return Positioned(
        left: realX - halfSize,
        top: realY - halfSize,
        child: LevelMapItem(
          level: level,
          badgeSize: componentSize,
          descriptionOnLeft: descriptionGoesLeft,
        ),
      );
    }).toList();
  }
}
