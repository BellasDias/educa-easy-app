import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:educaeasy_app/design_system/tokens/colors.dart';
import 'package:educaeasy_app/design_system/tokens/typography.dart';
import '../../domain/models/level_model.dart';

class LevelDrawer extends StatelessWidget {
  final LevelModel level;

  const LevelDrawer({super.key, required this.level});

  static void show(BuildContext context, {required LevelModel level}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => LevelDrawer(level: level),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fallbacks caso a fase não tenha dados configurados
    final title = level.drawerTitle ?? level.title;
    final description =
        level.description ??
        "Em breve! Mais desafios incríveis estão sendo preparados para você nesta fase.";
    final icon = level.drawerIcon ?? Icons.extension_rounded;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray20,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Nível ${level.index}',
            style: AppTypography.body(color: AppColors.purplePrimary),
          ),
          const SizedBox(height: 8),
          Text(title, style: AppTypography.title()),
          const SizedBox(height: 16),

          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.gray05,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gray20),
            ),
            child: Icon(icon, size: 64, color: AppColors.purplePrimary),
          ),
          const SizedBox(height: 16),

          Text(description, style: AppTypography.body()),
          const SizedBox(height: 24),

          if (level.conceptTags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              children: level.conceptTags.map((tag) => _buildTag(tag)).toList(),
            ),
            const SizedBox(height: 32),
          ],

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // A gaveta navega para onde o LevelModel mandar!
              context.push(level.route);
            },
            child: const Text('Começar lição'),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Chip(
      label: Text(
        text,
        style: AppTypography.body(color: AppColors.purplePrimary),
      ),
      backgroundColor: AppColors.purplePrimary.withOpacity(0.1),
      side: BorderSide.none,
    );
  }
}
