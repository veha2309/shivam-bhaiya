import 'package:flutter/material.dart';
import 'package:school_app/utils/app_theme.dart';

class SophisticatedHUDBackground extends StatelessWidget {
  final Widget child;
  
  const SophisticatedHUDBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Base light color (Off-white/Light Gray for a clean look)
        Container(color: const Color(0xFFFDFDFD)),
        
        // 2. The custom faint geometric grid
        Positioned.fill(
          child: CustomPaint(
            painter: _SubtleBlueprintPainter(),
          ),
        ),
        
        // 3. Soft Radial Gradient Glow (anchored to the top left)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.8, -0.6), // Top-left bias
                radius: 1.5,
                colors: [
                  AppColors.primary.withOpacity(0.06), // Very soft primary tint
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        
        // 4. The actual scrollable content
        child,
      ],
    );
  }
}

class _SubtleBlueprintPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Faint line paint
    final linePaint = Paint()
      ..color = AppColors.outlineVariant.withOpacity(0.15) // Extremely subtle
      ..strokeWidth = 0.5;

    // Crosshair paint (slightly more visible)
    final crosshairPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.12)
      ..strokeWidth = 1.0;

    const double spacing = 40.0; // Wide spacing looks more elegant

    // Draw grid lines
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }

    // Draw sophisticated crosshairs at alternating intersections
    const double crosshairSize = 3.0;
    for (double x = spacing; x < size.width; x += spacing * 2) {
      for (double y = spacing; y < size.height; y += spacing * 2) {
        // Horizontal dash
        canvas.drawLine(
          Offset(x - crosshairSize, y), 
          Offset(x + crosshairSize, y), 
          crosshairPaint
        );
        // Vertical dash
        canvas.drawLine(
          Offset(x, y - crosshairSize), 
          Offset(x, y + crosshairSize), 
          crosshairPaint
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
