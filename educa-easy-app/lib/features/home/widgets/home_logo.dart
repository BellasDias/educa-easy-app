import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeLogo extends StatelessWidget {
  const HomeLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/svg/logo-letter.svg',
      width: 200,
    );
  }
}