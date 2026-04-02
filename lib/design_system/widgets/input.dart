// lib/design_system/widgets/educaeasy_input.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tokens/colors.dart';

// Default == Cinza
// onFocus == Azul

class EducaeasyInput extends StatefulWidget{
  final String placeholder;
  final Color? focusColor;
  final TextEditingController? controller;
  final bool obscureText; // Senha? true/false
  final ValueChanged<String>? onChanged; // Callback quando digita
  final TextInputType? keyboardType; // Teclado numérico/email...
  
  const EducaeasyInput({
    super.key,
    required this.placeholder,
    this.focusColor,
    this.controller,
    this.obscureText = false,
    this.onChanged,
    this.keyboardType,
  });

  @override
  State<EducaeasyInput> createState() => _EducaeasyInputState();

}

// Estado Interno   
class _EducaeasyInputState extends State<EducaeasyInput> {
  final FocusNode _focusNode = FocusNode(); // Detecta quando o user cliaca/foca
  bool _isFocused = false; // Estado local: Focado ou não?
  
  @override
  void initState() {
    super.initState(); // Listener: quando foco muda → atualiza _isFocused
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    // limpeza: Evita memória leak
    _focusNode.dispose();
    super.dispose();
  }

  // Cores dinâmicas 
  Color get _borderColor {
    if (_isFocused){
      // Focado: cor custom ou azul padrão
      return widget.focusColor ?? AppColors.bluePrimary;
    }
    // Cor default
    return AppColors.gray20;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200), // Animação suave de 200ms
      height: 52, // Altura fixa
      decoration: BoxDecoration(
        color: Colors.white, // Cor de fundo
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _borderColor,
          width: 2,  // ← Stroke 2px
        ),
        boxShadow: [ 
          if (_isFocused)// Sombra baseada na cor da borda
            BoxShadow(
              // Cor da borda externa (mesma do foco, mas com baixa opacidade)
              color: _borderColor.withValues(alpha: 0.2), 
              spreadRadius: 4, // Define o quanto ela "vaza" para fora
              blurRadius: 0,   // 0 deixa ela sólida como uma borda real
            ),
            // Sombra padrão (você pode manter ou remover quando focado)
          BoxShadow(
            color: _borderColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        onChanged: widget.onChanged, // Callback interno
        style: GoogleFonts.nunito(
          fontSize: 18,
          color: AppColors.gray90, // Cor do texto
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          // Placeholder customizável
          hintText: widget.placeholder,
          hintStyle: GoogleFonts.nunito(
            fontSize: 18,
            color: AppColors.gray50, // Cor do placeholder
          ),
          border: InputBorder.none, // Sem borda interna
          contentPadding: const EdgeInsets.symmetric( // Padding interno
            horizontal: 16,
            vertical: 12,
          ),
          isDense: true,
        ),
      ),
    );
  }
}