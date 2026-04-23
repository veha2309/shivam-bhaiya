import 'package:flutter/material.dart';
import 'dart:math' as math;

class AttendancePieChart extends StatelessWidget {
  final double present;
  final double absent;
  final double leave;
  final double? size;
  final double animationValue;
  final Color? holeColor;

  const AttendancePieChart({
    super.key,
    required this.present,
    required this.absent,
    required this.leave,
    this.size,
    this.animationValue = 1.0,
    this.holeColor,
  });

  @override
  Widget build(BuildContext context) {
    if (size != null) {
      return CustomPaint(
        size: Size(size!, size!),
        painter: PieChartPainter(
          present: present,
          absent: absent,
          leave: leave,
          animationValue: animationValue,
          backgroundColor: holeColor ?? Theme.of(context).scaffoldBackgroundColor,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveSize = math.min(constraints.maxWidth, constraints.maxHeight);
        
        return CustomPaint(
          size: Size(effectiveSize, effectiveSize),
          painter: PieChartPainter(
            present: present,
            absent: absent,
            leave: leave,
            animationValue: animationValue,
            backgroundColor: holeColor ?? Theme.of(context).scaffoldBackgroundColor,
          ),
        );
      },
    );
  }
}

class PieChartPainter extends CustomPainter {
  final double present;
  final double absent;
  final double leave;
  final double animationValue;
  final Color backgroundColor;

  PieChartPainter({
    required this.present,
    required this.absent,
    required this.leave,
    required this.animationValue,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = present + absent + leave;
    if (total <= 0) return;

    // --- ELEGANCE ADJUSTMENTS ---
    // Reduced stroke width from size.width / 4 to size.width / 12
    final double strokeWidth = size.width / 12; 
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Keep round for a smooth feel

    // Adjust the rect so the thin line doesn't bleed outside the canvas
    final rect = Rect.fromLTWH(
      strokeWidth / 2, 
      strokeWidth / 2, 
      size.width - strokeWidth, 
      size.height - strokeWidth
    );
    
    double startAngle = -math.pi / 2;

    final presentSweep = (present / total) * 2 * math.pi * animationValue;
    final absentSweep = (absent / total) * 2 * math.pi * animationValue;
    final leaveSweep = (leave / total) * 2 * math.pi * animationValue;

    // Drawing with a thinner aesthetic
    _drawArc(canvas, rect, paint, startAngle, presentSweep, Colors.green[400]!);
    startAngle += presentSweep;

    _drawArc(canvas, rect, paint, startAngle, absentSweep, Colors.red[400]!);
    startAngle += absentSweep;

    _drawArc(canvas, rect, paint, startAngle, leaveSweep, Colors.orange[400]!);
  }

  void _drawArc(Canvas canvas, Rect rect, Paint paint, double start, double sweep, Color color) {
    if (sweep <= 0.01) return; // Small threshold to avoid tiny dots
    
    // Background glow/shadow (slightly reduced blur for thin lines)
    paint.color = color.withOpacity(0.15);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawArc(rect, start, sweep, false, paint);
    
    // Main Arc
    paint.maskFilter = null;
    paint.color = color;
    canvas.drawArc(rect, start, sweep, false, paint);
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) {
    return oldDelegate.present != present || 
           oldDelegate.absent != absent || 
           oldDelegate.leave != leave ||
           oldDelegate.animationValue != animationValue ||
           oldDelegate.backgroundColor != backgroundColor;
  }
}