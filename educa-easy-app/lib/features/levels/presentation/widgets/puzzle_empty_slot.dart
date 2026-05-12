import 'package:flutter/material.dart';

class PuzzleEmptySlot extends StatelessWidget {
  final bool isFilled;
  final String? filledValue;

  const PuzzleEmptySlot({
    super.key,
    this.isFilled = false,
    this.filledValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isFilled ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey[200],
        border: Border.all(
          color: isFilled ? Theme.of(context).primaryColor : Colors.grey[400]!,
          width: 2,
          style: isFilled ? BorderStyle.solid : BorderStyle.none, // Pode usar pontilhado via package se preferir dps
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: isFilled
          ? Text(
              filledValue ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )
          : const SizedBox.shrink(),
    );
  }
}