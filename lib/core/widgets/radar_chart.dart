import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../shared/models/models.dart';

class RadarChart extends StatelessWidget {
  const RadarChart({
    super.key,
    required this.attributes,
    this.emptyLabel = 'Registre atividades para formar seu gráfico.',
  });
  final List<RadarAttribute> attributes;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (attributes.length < 3) {
      return SizedBox(
        height: 250,
        child: Center(child: Text(emptyLabel, textAlign: TextAlign.center)),
      );
    }
    final summary = attributes
        .map((item) => '${item.label}: ${item.value.round()}')
        .join(', ');
    return Semantics(
      label: 'Gráfico poligonal. $summary',
      image: true,
      child: AspectRatio(
        aspectRatio: 1.12,
        child: CustomPaint(painter: _RadarPainter(attributes)),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter(this.attributes);
  final List<RadarAttribute> attributes;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * .32;
    final grid = Paint()
      ..color = AppColors.graphite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final axis = Paint()
      ..color = AppColors.steel.withValues(alpha: .26)
      ..style = PaintingStyle.stroke;
    for (var ring = 1; ring <= 4; ring++) {
      canvas.drawPath(
        _polygon(center, radius * ring / 4, List.filled(attributes.length, 1)),
        grid,
      );
    }
    for (var i = 0; i < attributes.length; i++) {
      canvas.drawLine(center, _point(center, radius, i), axis);
    }
    final values = attributes
        .map((item) => item.value.clamp(0, 100) / 100)
        .toList();
    final shape = _polygon(center, radius, values);
    canvas.drawPath(
      shape,
      Paint()..color = AppColors.frost.withValues(alpha: .13),
    );
    canvas.drawPath(
      shape,
      Paint()
        ..color = AppColors.frost
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final dot = Paint()..color = AppColors.bone;
    final textStyle = const TextStyle(
      color: AppColors.steel,
      fontSize: 9,
      fontWeight: FontWeight.w700,
    );
    for (var i = 0; i < attributes.length; i++) {
      canvas.drawCircle(_point(center, radius * values[i], i), 3, dot);
      final labelPoint = _point(center, radius + 24, i);
      final painter = TextPainter(
        text: TextSpan(
          text: attributes[i].label.toUpperCase(),
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 76);
      painter.paint(
        canvas,
        labelPoint - Offset(painter.width / 2, painter.height / 2),
      );
    }
  }

  Path _polygon(Offset center, double radius, List<double> values) {
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final point = _point(center, radius * values[i], i);
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  Offset _point(Offset center, double radius, int index) {
    final angle = -math.pi / 2 + (math.pi * 2 * index / attributes.length);
    return center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.attributes != attributes;
}
