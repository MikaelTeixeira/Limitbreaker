import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CustomPaint(
        size: Size(compact ? 18 : 24, compact ? 18 : 24),
        painter: _FracturePainter(),
      ),
      const SizedBox(width: 8),
      Text(
        'LIMIT BREAKER',
        style: TextStyle(
          fontSize: compact ? 10 : 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.8,
        ),
      ),
    ],
  );
}

class FocusSilhouette extends StatelessWidget {
  const FocusSilhouette({super.key, this.height = 300});
  final double height;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Imagem da marca Limit Breaker',
    image: true,
    child: ClipRect(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Image.asset(
          'assets/images/limit_breaker_hero.png',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
    ),
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.eyebrow, this.trailing});
  final String title;
  final String? eyebrow;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (eyebrow != null) ...[
              Text(
                eyebrow!.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 6),
            ],
            Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      ?trailing,
    ],
  );
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.value,
    required this.label,
    this.accent = false,
  });
  final String value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.graphite)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: accent ? AppColors.frost : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    ),
  );
}

class _FracturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.bone
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final path = Path()
      ..moveTo(size.width * .66, 0)
      ..lineTo(size.width * .26, size.height * .48)
      ..lineTo(size.width * .54, size.height * .48)
      ..lineTo(size.width * .34, size.height)
      ..lineTo(size.width * .78, size.height * .39)
      ..lineTo(size.width * .49, size.height * .39)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
