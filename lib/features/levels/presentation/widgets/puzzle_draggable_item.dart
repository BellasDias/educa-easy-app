import 'package:flutter/material.dart';

class PuzzleDraggableItem extends StatelessWidget {
  final String value;

  const PuzzleDraggableItem({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    // O Draggable precisa do widget normal (child) e de um widget para mostrar enquanto arrasta (feedback)
    return Draggable<String>(
      data: value,
      feedback: Material( // O Material previne que o texto perca a formatação ao ser arrastado
        color: Colors.transparent,
        child: _buildBox(isDragging: true),
      ),
      childWhenDragging: Opacity( // Fica meio transparente na base enquanto arrasta
        opacity: 0.3,
        child: _buildBox(),
      ),
      child: _buildBox(),
    );
  }

  Widget _buildBox({bool isDragging = false}) {
    return Container(
      width: 60,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD2D9), width: 2),
        boxShadow: isDragging 
            ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))]
            : [], // Adiciona sombra apenas quando está a ser arrastado
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        style: const TextStyle(
          color: Color(0xFF323F4B),
          fontSize: 20,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}