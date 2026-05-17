import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:educaeasy_app/design_system/tokens/colors.dart';
import 'package:educaeasy_app/design_system/tokens/typography.dart';
import 'package:educaeasy_app/design_system/widgets/button.dart';
// Importe o seu AvatarService aqui
import 'package:educaeasy_app/features/store/data/avatar_service.dart';

const String _owlSvg = '''...'''; // Seus SVGs mantidos aqui
const String _catSvg = '''...''';
const String _robotSvg = '''...''';

class CharacterModel {
  final String name;
  final String svgData;
  final int price;
  bool isOwned;

  CharacterModel({
    required this.name,
    required this.svgData,
    required this.price,
    this.isOwned = false,
  });
}

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final AvatarService _avatarService = AvatarService();
  
  late final List<CharacterModel> characters;
  String? _currentlyEquippedSvg;

  @override
  void initState() {
    super.initState();
    _currentlyEquippedSvg = _avatarService.selectedAvatarNotifier.value;
    
    characters = [
      CharacterModel(name: 'Prof. Coruja', svgData: _owlSvg, price: 50, isOwned: true),
      CharacterModel(name: 'Gato Laranjinha', svgData: _catSvg, price: 150),
      CharacterModel(name: 'Robô Byte', svgData: _robotSvg, price: 300),
    ];
  }

  void _equipCharacter(String svgData) {
    _avatarService.selectAvatar(svgData);
    setState(() {
      _currentlyEquippedSvg = svgData;
    });
  }

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
          Container(
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
                Text('420', style: AppTypography.button(color: AppColors.gray90)),
              ],
            ),
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
              child: GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    // 💡 AJUSTE CLEAN CODE: Mudamos de 0.75 para 0.68 para dar espaço vertical aos botões 
    childAspectRatio: 0.68, 
  ),
  itemCount: characters.length,
  itemBuilder: (context, index) {
    final character = characters[index];
    final isSelected = _currentlyEquippedSvg == character.svgData;

    return _CharacterCard(
      character: character,
      isSelected: isSelected,
      onEquip: () => _equipCharacter(character.svgData),
    );
  },
)
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final CharacterModel character;
  final bool isSelected;
  final VoidCallback onEquip;

  const _CharacterCard({
    required this.character,
    required this.isSelected,
    required this.onEquip,
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
            child: character.isOwned
                ? EducaeasyButton(
                    text: isSelected ? 'Selecionado' : 'Equipar',
                    variant: isSelected ? ButtonVariant.primary : ButtonVariant.outline,
                    onPressed: isSelected ? () {} : onEquip,
                  )
                : EducaeasyButton(
                    text: 'Comprar',
                    variant: ButtonVariant.success,
                    onPressed: () {
                      // Lógica de compra omitida por brevidade
                    },
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}