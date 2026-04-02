import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tokens/colors.dart';

enum ButtonVariant { primary, outline, ghost, success, destructive, link, disabled }

class EducaeasyButton extends StatefulWidget {
  final String text;
  final ButtonVariant variant;
  final VoidCallback? onPressed;
  final bool isIconOnly;
  final Widget? icon;
  final double? size;

  const EducaeasyButton({
    super.key,
    required this.text,
    this.variant = ButtonVariant.primary,
    this.onPressed,
    this.isIconOnly = false,
    this.icon,
    this.size,
  });

  @override
  State<EducaeasyButton> createState() => _EducaeasyButtonState();
}

class _EducaeasyButtonState extends State<EducaeasyButton> {
  bool _isPressed = false;

  Color _getTextColor() {
    switch (widget.variant) {
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return AppColors.gray40;
      case ButtonVariant.disabled:
        return AppColors.gray50;
      default:
        return Colors.white;
    }
  }

  // Cores de cada variant do Button
  static const Map<ButtonVariant, ButtonColors> variants = {
    ButtonVariant.primary: ButtonColors(
      defaultBg: AppColors.purplePrimaryLighter,
      defaultBorder: AppColors.purpleDark,
      defaultShadow: AppColors.purpleDark,
      pressedBg: AppColors.purplePrimary,
      pressedBorder: AppColors.purpleDark,
      pressedShadow: AppColors.purpleDark,
    ),
    ButtonVariant.outline: ButtonColors(
      defaultBg: AppColors.gray00,
      defaultBorder: AppColors.gray20,
      defaultShadow: AppColors.gray20,
      pressedBg: Color(0xFFEEF1F5),
      pressedBorder: AppColors.gray30,
      pressedShadow: AppColors.gray30,
    ),
    ButtonVariant.ghost: ButtonColors(
      defaultBg: null,
      defaultBorder: null,
      defaultShadow: null,
      pressedBg: null,
      pressedBorder: null,
      pressedShadow: null,
    ),
    ButtonVariant.success: ButtonColors(
      defaultBg: AppColors.greenPrimary,
      defaultBorder: AppColors.greenDark,
      defaultShadow: AppColors.greenDark,
      pressedBg: AppColors.greenPrimaryDarker,
      pressedBorder: AppColors.greenDark,
      pressedShadow: AppColors.greenDark,
    ),
    ButtonVariant.destructive: ButtonColors(
      defaultBg: AppColors.redPrimary, 
      defaultBorder: AppColors.redDark,
      defaultShadow: AppColors.redDark, 
      pressedBg: AppColors.redPrimaryLighter, 
      pressedBorder: AppColors.redDark,
      pressedShadow: AppColors.redDark,
    ),
    ButtonVariant.link: ButtonColors(
      defaultBg: AppColors.bluePrimary, 
      defaultBorder: AppColors.blueDark, 
      defaultShadow: AppColors.blueDark,
      pressedBg: AppColors.bluePrimaryLighter, 
      pressedBorder: AppColors.blueDark,
      pressedShadow: AppColors.blueDark,
      ),
      ButtonVariant.disabled: ButtonColors(
      defaultBg: AppColors.gray20, 
      defaultBorder: AppColors.gray20, 
      defaultShadow: AppColors.gray30,
      pressedBg: null, 
      pressedBorder: null,
      pressedShadow: null,
      ),
  };

  @override
  Widget build(BuildContext context) {
    final colors = variants[widget.variant] ?? variants[ButtonVariant.primary]!;
    
    // 🎯 PEGA CORES CORRETAS por estado
    final bgColor = _isPressed ? colors.pressedBg : colors.defaultBg;
    final borderColor = _isPressed ? colors.pressedBorder : colors.defaultBorder;
    final shadowColor = _isPressed ? colors.pressedShadow : colors.defaultShadow;
    
    final shadow = shadowColor != null 
        ? BoxShadow(color: shadowColor, offset: const Offset(0, 4))
        : null;

    final double? buttonSize = widget.isIconOnly ? (widget.size ?? 48) : null;

    return GestureDetector(
      onTapDown: (_) => widget.onPressed != null ? setState(() => _isPressed = true) : null,
      onTapUp: (_) {
        if (widget.onPressed != null) {
          setState(() => _isPressed = false);
          widget.onPressed!();
        }
      },
      onTapCancel: () => widget.onPressed != null ? setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: buttonSize,
        height: buttonSize,
        padding: widget.isIconOnly
          ? EdgeInsets.zero // Tamanho certo do button somente com icon
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        margin: EdgeInsets.only(
          top: _isPressed ? 2 : 0,    // Quando pressiona, desce 2px
          bottom: _isPressed ? 0 : 2, // Quando solta, a margem volta para baixo
        ),
        decoration: ShapeDecoration(
          color: bgColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: borderColor ?? Colors.transparent),
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: shadow != null ? [shadow] : null,
        ),
        child: widget.isIconOnly 
            ? Center(child: widget.icon) // Centraliza o ícone no quadrado
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    widget.icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: GoogleFonts.nunito(
                      color: _getTextColor(),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}


class ButtonColors {
  final Color? defaultBg;
  final Color? defaultBorder;
  final Color? defaultShadow;
  final Color? pressedBg;
  final Color? pressedBorder;
  final Color? pressedShadow;

  const ButtonColors({
    required this.defaultBg,
    required this.defaultBorder,
    this.defaultShadow,
    required this.pressedBg,
    required this.pressedBorder,
    this.pressedShadow,
  });
}
