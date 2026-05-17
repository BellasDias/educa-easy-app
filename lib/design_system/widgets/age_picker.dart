import 'package:flutter/material.dart';

class AgePicker extends StatefulWidget {
  final int initialAge;
  final int minAge;
  final int maxAge;
  final ValueChanged<int> onAgeChanged;

  const AgePicker({
    super.key,
    this.initialAge = 19,
    this.minAge = 5,
    this.maxAge = 100,
    required this.onAgeChanged,
  });

  @override
  State<AgePicker> createState() => _AgePickerState();
}

class _AgePickerState extends State<AgePicker> {
  late PageController _pageController;
  late int _selectedAge;

  @override
  void initState() {
    super.initState();
    _selectedAge = widget.initialAge;
    
    // Calcula qual página (index) corresponde à idade inicial
    final initialPage = _selectedAge - widget.minAge;
    
    // O viewportFraction diz que cada item vai ocupar 35% da tela.
    // Isso permite que o item central e os das laterais apareçam juntos.
    _pageController = PageController(
      initialPage: initialPage,
      viewportFraction: 0.35, 
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120, // Altura fixa para conter os números grandes
      child: PageView.builder(
        controller: _pageController,
        // Garante o efeito de "snap" (travar no centro)
        physics: const BouncingScrollPhysics(), 
        onPageChanged: (index) {
          final newAge = widget.minAge + index;
          setState(() {
            _selectedAge = newAge;
          });
          // Avisa a tela pai (ex: AgeInputPage) que a idade mudou
          widget.onAgeChanged(newAge); 
        },
        itemCount: widget.maxAge - widget.minAge + 1,
        itemBuilder: (context, index) {
          // AnimatedBuilder escuta o movimento do scroll em tempo real
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double scale = 1.0;
              double opacity = 1.0;

              // Calcula a distância da página atual para este item específico
              if (_pageController.position.haveDimensions) {
                double distance = (_pageController.page! - index).abs();
                
                // Quanto mais distante do centro, menor a escala e a opacidade
                // Escala varia de 1.0 (centro) para ~0.6 (laterais)
                scale = (1 - (distance * 0.4)).clamp(0.6, 1.0);
                opacity = (1 - (distance * 0.5)).clamp(0.3, 1.0);
              } else {
                // Fallback para o frame inicial de renderização
                scale = index == (_selectedAge - widget.minAge) ? 1.0 : 0.6;
                opacity = index == (_selectedAge - widget.minAge) ? 1.0 : 0.3;
              }

              final isSelected = index == (_selectedAge - widget.minAge);
              
              // Pegando a cor primária do seu AppTheme (ou fallback para azul)
              final color = isSelected 
                  ? Theme.of(context).primaryColor 
                  : Colors.grey.shade400;

              return Center(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Text(
                      '${widget.minAge + index}',
                      style: TextStyle(
                        fontSize: 80, // Tamanho base do número central
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: color,
                        height: 1.0, // Evita margens extras na fonte
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}