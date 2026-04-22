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

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 4
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(
      paint.strokeWidth / 2, 
      paint.strokeWidth / 2, 
      size.width - paint.strokeWidth, 
      size.height - paint.strokeWidth
    );
    double startAngle = -math.pi / 2;

    final presentSweep = (present / total) * 2 * math.pi * animationValue;
    final absentSweep = (absent / total) * 2 * math.pi * animationValue;
    final leaveSweep = (leave / total) * 2 * math.pi * animationValue;

    _drawArc(canvas, rect, paint, startAngle, presentSweep, Colors.green[400]!);
    startAngle += presentSweep;

    _drawArc(canvas, rect, paint, startAngle, absentSweep, Colors.red[400]!);
    startAngle += absentSweep;

    _drawArc(canvas, rect, paint, startAngle, leaveSweep, Colors.orange[400]!);
  }

  void _drawArc(Canvas canvas, Rect rect, Paint paint, double start, double sweep, Color color) {
    if (sweep <= 0) return;
    
    paint.color = color.withOpacity(0.2);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawArc(rect, start, sweep, false, paint);
    
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