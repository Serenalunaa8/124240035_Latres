import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PortalVortex extends StatefulWidget {
  final double size;
  final bool isRotating;
  final int characterId;

  const PortalVortex({
    super.key,
    this.size = 240,
    this.isRotating = true,
    this.characterId = 1,
  });

  @override
  State<PortalVortex> createState() => _PortalVortexState();
}

class _PortalVortexState extends State<PortalVortex>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _imageUrl = 'https://rickandmortyapi.com/api/character/avatar/1.jpeg';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    if (widget.isRotating) {
      _controller.repeat();
    }
    _loadApiImage();
  }

  // Ambil gambar karakter dari API
  Future<void> _loadApiImage() async {
    try {
      final character = await ApiService.getCharacterDetail(widget.characterId);
      if (mounted && character.image.isNotEmpty) {
        setState(() {
          _imageUrl = character.image;
        });
      }
    } catch (_) {
      _imageUrl = 'https://rickandmortyapi.com/api/character/avatar/${widget.characterId}.jpeg';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0D1510),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF76FF03).withValues(alpha: 0.35),
            blurRadius: 35,
            spreadRadius: 8,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF76FF03).withValues(alpha: 0.35),
          width: 2.5,
        ),
      ),
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animasi rotasi portal
            RotationTransition(
              turns: _controller,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Foto karakter
                  ClipOval(
                    child: Container(
                      width: widget.size * 0.72,
                      height: widget.size * 0.72,
                      color: const Color(0xFF0D1510),
                      child: Image.network(
                        _imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF0D1510),
                          child: const Icon(
                            Icons.cyclone,
                            color: Color(0xFF76FF03),
                            size: 60,
                          ),
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF76FF03),
                              strokeWidth: 2,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Efek visual portal
                  CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: PortalPainter(),
                  ),
                ],
              ),
            ),

            // Label portal
            Positioned(
              bottom: widget.size * 0.10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF76FF03).withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'INTERDIMENSIONAL',
                      style: TextStyle(
                        color: const Color(0xFFE0E0E0),
                        fontSize: widget.size * 0.042,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.8,
                      ),
                    ),
                    Text(
                      'PORTAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widget.size * 0.07,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                        shadows: [
                          Shadow(
                            color: const Color(0xFF76FF03).withValues(alpha: 0.9),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'VORTEX',
                      style: TextStyle(
                        color: const Color(0xFF76FF03),
                        fontSize: widget.size * 0.05,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PortalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.48;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final colors = [
      const Color(0xFF39FF14).withValues(alpha: 0.85),
      const Color(0xFF76FF03).withValues(alpha: 0.85),
      const Color(0xFF00E676).withValues(alpha: 0.8),
      const Color(0xFFB2FF59).withValues(alpha: 0.75),
    ];

    // Garis spiral
    for (int arm = 0; arm < 4; arm++) {
      final armOffset = arm * (math.pi / 2);
      final path = Path();
      bool isFirst = true;

      for (double theta = 0; theta < 3.2 * math.pi; theta += 0.09) {
        final r = (theta / (3.2 * math.pi)) * maxRadius;
        final angle = theta + armOffset;
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);

        if (isFirst) {
          path.moveTo(x, y);
          isFirst = false;
        } else {
          path.lineTo(x, y);
        }
      }

      paint.color = colors[arm % colors.length];
      paint.strokeWidth = 2.8 + (arm % 2);
      canvas.drawPath(path, paint);
    }

    // Partikel cahaya
    final sparkPaint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42);
    for (int i = 0; i < 28; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final dist = random.nextDouble() * maxRadius;
      final px = center.dx + dist * math.cos(angle);
      final py = center.dy + dist * math.sin(angle);
      final radius = random.nextDouble() * 2.0 + 0.8;

      sparkPaint.color = i % 2 == 0
          ? Colors.white.withValues(alpha: 0.85)
          : const Color(0xFF76FF03).withValues(alpha: 0.8);
      canvas.drawCircle(Offset(px, py), radius, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
