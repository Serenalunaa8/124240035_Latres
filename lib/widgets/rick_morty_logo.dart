import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class RickMortyLogo extends StatelessWidget {
  final double height;
  final double glowRadius;
  final double glowSpread;
  final double glowOpacity;
  final Color glowColor;

  const RickMortyLogo({
    super.key,
    this.height = 42,
    this.glowRadius = 24,
    this.glowSpread = 4,
    this.glowOpacity = 0.5,
    this.glowColor = AppColors.portalGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Efek glow logo
        Container(
          width: height * 2.3,
          height: height * 0.65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: glowOpacity),
                blurRadius: glowRadius,
                spreadRadius: glowSpread,
              ),
              BoxShadow(
                color: glowColor.withValues(alpha: glowOpacity * 0.4),
                blurRadius: glowRadius * 1.5,
                spreadRadius: glowSpread + 4,
              ),
            ],
          ),
        ),
        // Gambar logo
        SvgPicture.asset(
          'assets/images/Rick_and_Morty.svg',
          height: height,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}
