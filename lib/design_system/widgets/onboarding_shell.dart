import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingShell extends StatelessWidget {
  final Widget child;
  final bool showBackButton;
  final VoidCallback? onBack;

  const OnboardingShell({
    super.key,
    required this.child,
    this.showBackButton = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Background (Positioned must be the direct child of Stack)
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
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios, size: 20),
      onPressed: onBack ?? () => Navigator.of(context).maybePop(),
    );
  }
}