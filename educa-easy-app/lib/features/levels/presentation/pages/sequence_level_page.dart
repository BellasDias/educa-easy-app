import 'package:educaeasy_app/design_system/widgets/button.dart';
import 'package:educaeasy_app/features/levels/presentation/widgets/sequence_code_line.dart';
import 'package:flutter/material.dart';
import '../widgets/gameplay_header.dart';
import '../widgets/puzzle_draggable_item.dart';

class SequenceLevelPage extends StatefulWidget {
  const SequenceLevelPage({super.key});

  @override
  State<SequenceLevelPage> createState() => _SequenceLevelPageState();
}

class _SequenceLevelPageState extends State<SequenceLevelPage> {
  // Estado do jogo: Map onde a key é o sequenceNumber e o value é a resposta dada.
  // null significa que o slot está vazio.
  Map<String, String?> userAnswers = {
    '1': '1', // Fixo
    '2': '2', // Fixo
    '3': null, // Vazio, aguardando
    '4': '4', // Fixo
    '5': '5', // Fixo
    '6': null, // Vazio, aguardando
  };

  // As peças disponíveis na base
  List<String> availablePieces = ['3', '6'];

  // Verifica se todos os slots que precisavam ser preenchidos já não são null
  bool get allFieldsFilled {
    return userAnswers.values.every((value) => value != null);
  }

  void _onAcceptPiece(String sequenceKey, String droppedValue) {
    setState(() {
      userAnswers[sequenceKey] = droppedValue;
      availablePieces.remove(droppedValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            GameplayHeader(
              progress: 0.3,
              onBackPressed: () => Navigator.of(context).pop(),
              svgIconPath: 'assets/svg/Prop=star.svg',
            ),
            
            const SizedBox(height: 24),

            // Título
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Complete com a sequência',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // O Corpo principal com a lista de slots
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 8), // Baseado no código do Figma
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SequenceCodeLine(
                    sequenceNumber: '1',
                    filledValue: '1', // Fixo
                    isFixed: true,
                  ),
                  SequenceCodeLine(
                    sequenceNumber: '2',
                    filledValue: '2', // Fixo
                    isFixed: true,
                  ),
                  SequenceCodeLine(
                    sequenceNumber: '3',
                    filledValue: userAnswers['3'], // Gerido pelo estado
                    onAccept: (value) => _onAcceptPiece('3', value),
                  ),
                  SequenceCodeLine(
                    sequenceNumber: '4',
                    filledValue: '4', // Fixo
                    isFixed: true,
                  ),
                  SequenceCodeLine(
                    sequenceNumber: '5',
                    filledValue: '5', // Fixo
                    isFixed: true,
                  ),
                  SequenceCodeLine(
                    sequenceNumber: '6',
                    filledValue: userAnswers['6'], // Gerido pelo estado
                    onAccept: (value) => _onAcceptPiece('6', value),
                  ),
                ],
              ),
            ),

            // A base cinza com as opções
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC), // Fundo suave para a área inferior
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Column(
                children: [
                  // Área para as peças drag-and-drop
                  SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: availablePieces.map((piece) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: PuzzleDraggableItem(value: piece),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Botão de verificar
                  EducaeasyButton(
                    text: 'Verificar Resposta',
                    onPressed: allFieldsFilled ? () {
                      // Lógica final de validação aqui
                      print('Verificando respostas: $userAnswers');
                    } : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}