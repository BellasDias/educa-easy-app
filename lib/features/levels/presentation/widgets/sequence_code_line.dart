import 'package:flutter/material.dart';
import 'dart:ui'; // Necessário para criar o tracejado nativo (PathMetrics)

class SequenceCodeLine extends StatelessWidget {
  final String sequenceNumber;
  final String? filledValue;
  final bool isFixed;
  final Function(String)? onAccept;

  const SequenceCodeLine({
    super.key,
    required this.sequenceNumber,
    this.filledValue,
    this.isFixed = false,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. O número da esquerda
            _buildNumber(),

            const SizedBox(width: 16),

            // 2. A caixa da direita (vazia ou preenchida)
            Expanded(
              child: isFixed && filledValue != null
                  ? _buildFilledBox(filledValue!)
                  : DragTarget<String>(
                      onWillAcceptWithDetails: (details) => filledValue == null,
                      onAcceptWithDetails: (details) {
                        if (onAccept != null) onAccept!(details.data);
                      },
                      builder: (context, candidateData, rejectedData) {
                        if (filledValue != null) {
                          return _buildFilledBox(filledValue!);
                        }
                        return _buildEmptyBox(isHighlighted: candidateData.isNotEmpty);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumber() {
    return CustomPaint(
      // Pinta a borda tracejada apenas na direita
      painter: _RightDashedBorderPainter(
        color: const Color(0xFFCBD2D9), // gray-20
        strokeWidth: 2,
        dashHeight: 6,
        dashSpace: 4,
      ),
      child: Container(
        // Texto colado na esquerda (left: 0), e padding de 16px na direita antes da borda
        padding: const EdgeInsets.only(left: 0, top: 12, right: 16, bottom: 12),
        alignment: Alignment.centerLeft,
        child: Text(
          sequenceNumber,
          style: const TextStyle(
            color: Color(0xFF9AA5B1), // gray-30
            fontSize: 20,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyBox({required bool isHighlighted}) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: isHighlighted ? Colors.blue : const Color(0xFFE4E7EB), // gray-10
        strokeWidth: 2,
        dashWidth: 6,
        dashSpace: 4,
        borderRadius: 8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA), // gray-05
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildFilledBox(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFCBD2D9), width: 2), // gray-20
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerLeft,
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

// ============================================================================
// PINTOR CUSTOMIZADO PARA A BORDA TRACEJADA (CAIXA VAZIA)
// ============================================================================
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final dashedPath = Path();

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth ||
           oldDelegate.dashWidth != dashWidth ||
           oldDelegate.dashSpace != dashSpace;
  }
}

// ============================================================================
// PINTOR CUSTOMIZADO: BORDA TRACEJADA APENAS NA DIREITA (NÚMERO)
// ============================================================================
class _RightDashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashHeight;
  final double dashSpace;

  _RightDashedBorderPainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.dashHeight = 6.0,
    this.dashSpace = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startY = 0.0;
    final x = size.width; // Trava a posição X na extremidade direita do Container

    // Desenha pequenos traços de cima para baixo
    while (startY < size.height) {
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _RightDashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth ||
           oldDelegate.dashHeight != dashHeight ||
           oldDelegate.dashSpace != dashSpace;
  }
}