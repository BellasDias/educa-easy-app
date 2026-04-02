import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:educaeasy_app/design_system/widgets/button.dart';

class OnboardingShell extends StatelessWidget {
  final Widget child;
  final Widget? footer;
  final bool showBackButton;
  final VoidCallback? onBack;

  const OnboardingShell({
    super.key,
    required this.child,
    this.showBackButton = true,
    this.onBack, this.footer,
  });

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    resizeToAvoidBottomInset: true, // Faz o botão subir com o teclado
    body: Stack(
      fit: StackFit.expand,
      children: [
        // 1. Background
        Positioned.fill(
          child: IgnorePointer(
            child: SvgPicture.asset(
              'assets/svg/dots.svg',
              fit: BoxFit.cover,
            ),
          ),
        ),

        // 2. Main Content
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildHeader(context),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: child, // Ensure 'child' doesn't contain an Expanded/Positioned incorrectly!
                ),
              ),
              // Footer Dinâmico: Se houver algo no footer, ele renderiza aqui
              if (footer != null)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: footer,
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      // Use a Row instead of a Stack for headers to avoid 'hasSize' issues
      child: NavigationToolbar(
        leading: showBackButton ? _buildBackButton(context) : null,
        centerMiddle: true,
        middle: SvgPicture.asset(
          'assets/svg/logo.svg', 
          height: 32,
          // Adding a placeholder prevents layout jumps
          placeholderBuilder: (context) => const SizedBox(height: 32, width: 32),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return EducaeasyButton(
      text: '',
      variant: ButtonVariant.outline,
      isIconOnly: true,
      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
      onPressed: onBack ?? () => Navigator.of(context).maybePop(),
    );
  }
}