import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:educaeasy_app/design_system/tokens/colors.dart';
import 'package:educaeasy_app/design_system/tokens/typography.dart';
import 'package:educaeasy_app/design_system/widgets/button.dart';
import 'package:educaeasy_app/features/store/data/avatar_service.dart';

// ✅ CORREÇÃO: Inclusão dos códigos SVG válidos para renderização correta
const String _owlSvg = '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="50" r="40" fill="#6D3DF2"/>
  <circle cx="35" cy="40" r="10" fill="#FFF"/>
  <circle cx="65" cy="40" r="10" fill="#FFF"/>
  <circle cx="35" cy="40" r="4" fill="#1F2933"/>
  <circle cx="65" cy="40" r="4" fill="#1F2933"/>
  <polygon points="45,55 55,55 50,65" fill="#FFCC00"/>
</svg>
''';

const String _catSvg = '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="55" r="35" fill="#FFB700"/>
  <polygon points="20,20 40,35 20,50" fill="#FFB700"/>
  <polygon points="80,20 60,35 80,50" fill="#FFB700"/>
  <circle cx="35" cy="50" r="6" fill="#FFF"/>
  <circle cx="65" cy="50" r="6" fill="#FFF"/>
  <circle cx="35" cy="50" r="3" fill="#1F2933"/>
  <circle cx="65" cy="50" r="3" fill="#1F2933"/>
  <polygon points="45,60 55,60 50,65" fill="#E83D3D"/>
</svg>
''';

const String _robotSvg = '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="20" width="60" height="60" rx="10" fill="#2E81F5"/>
  <circle cx="35" cy="45" r="8" fill="#FFF"/>
  <circle cx="65" cy="45" r="8" fill="#FFF"/>
  <circle cx="35" cy="45" r="3" fill="#1F2933"/>
  <circle cx="65" cy="45" r="3" fill="#1F2933"/>
  <rect x="30" y="65" width="40" height="5" rx="2" fill="#FFF"/>
  <rect x="45" y="5" width="10" height="15" fill="#CBD2D9"/>
  <circle cx="50" cy="5" r="5" fill="#E83D3D"/>
</svg>
''';

class CharacterModel {
  final String name;
  final String svgData;
  final int price;

  CharacterModel({
    required this.name,
    required this.svgData,
    required this.price,
  });
}

class StorePage extends StatelessWidget {
  StorePage({super.key});

  final AvatarService _avatarService = AvatarService();

  final List<CharacterModel> characters = [
    CharacterModel(name: 'Prof. Coruja', svgData: _owlSvg, price: 50),
    CharacterModel(name: 'Gato Laranjinha', svgData: _catSvg, price: 150),
    CharacterModel(name: 'Robô Byte', svgData: _robotSvg, price: 300),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray05,
      appBar: AppBar(
        backgroundColor: AppColors.gray00,
        elevation: 0,
        centerTitle: true,
        title: Text('Loja de Avatares', style: AppTypography.title(color: AppColors.gray90)),
        actions: [
          // Escuta reativa do saldo de moedas no topo
          ValueListenableBuilder<int>(
            valueListenable: _avatarService.coinsNotifier,
            builder: (context, coins, child) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.yellowPastelPrimary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.yellowDark, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on_rounded, color: AppColors.yellowDark, size: 20),
                    const SizedBox(width: 4),
                    Text('$coins', style: AppTypography.button(color: AppColors.gray90)),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Escolha seu parceiro de estudos!', style: AppTypography.body(color: AppColors.gray60)),
            const SizedBox(height: 24),
            Expanded(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _avatarService.selectedAvatarNotifier,
                  _avatarService.ownedAvatarsNotifier,
                ]),
                builder: (context, child) {
                  final equippedSvg = _avatarService.selectedAvatarNotifier.value;
                  final ownedList = _avatarService.ownedAvatarsNotifier.value;

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.65, // Ajustado ligeiramente para evitar overflow
                    ),
                    itemCount: characters.length,
                    itemBuilder: (context, index) {
                      final character = characters[index];
                      final isOwned = ownedList.contains(character.name);
                      final isSelected = equippedSvg == character.svgData;

                      return _CharacterCard(
                        character: character,
                        isOwned: isOwned,
                        isSelected: isSelected,
                        onEquip: () => _avatarService.selectAvatar(character.svgData),
                        onBuy: () async {
                          final success = await _avatarService.purchaseAvatar(character.name, character.price);
                          if (!success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Moedas insuficientes para a compra!')),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final CharacterModel character;
  final bool isOwned;
  final bool isSelected;
  final VoidCallback onEquip;
  final VoidCallback onBuy;

  const _CharacterCard({
    required this.character,
    required this.isOwned,
    required this.isSelected,
    required this.onEquip,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray00,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.bluePrimary : AppColors.gray20, 
          width: isSelected ? 2.0 : 1.5,
        ),
        boxShadow: const [
          BoxShadow(color: AppColors.gray10, offset: Offset(0, 4), blurRadius: 8),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: SvgPicture.string(character.svgData, fit: BoxFit.contain, width: 80),
          ),
          const SizedBox(height: 12),
          Text(
            character.name,
            style: AppTypography.title(color: AppColors.gray90).copyWith(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.monetization_on_rounded, color: AppColors.yellowDark, size: 16),
              const SizedBox(width: 4),
              Text(
                '${character.price}',
                style: AppTypography.body(color: AppColors.gray70).copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: isOwned
                ? EducaeasyButton(
                    text: isSelected ? 'Equipado' : 'Equipar',
                    variant: isSelected ? ButtonVariant.primary : ButtonVariant.outline,
                    onPressed: isSelected ? () {} : onEquip,
                  )
                : EducaeasyButton(
                    text: 'Comprar',
                    variant: ButtonVariant.success,
                    onPressed: onBuy,
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}