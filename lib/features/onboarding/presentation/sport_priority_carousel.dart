import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../shared/models/models.dart';

class SportPriorityCarousel extends StatefulWidget {
  const SportPriorityCarousel({
    super.key,
    required this.selection,
    required this.onChanged,
  });

  final List<SportType?> selection;
  final ValueChanged<List<SportType?>> onChanged;

  @override
  State<SportPriorityCarousel> createState() => _SportPriorityCarouselState();
}

class _SportPriorityCarouselState extends State<SportPriorityCarousel> {
  final _controller = PageController(viewportFraction: .82);
  var _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _assign(int priority) {
    final selectedSport = SportType.values[_currentIndex];
    final next = List<SportType?>.of(widget.selection);
    final duplicateIndex = next.indexOf(selectedSport);
    if (duplicateIndex != -1) next[duplicateIndex] = null;
    next[priority] = selectedSport;
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final sport = SportType.values[_currentIndex];
    return Column(
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _controller,
            itemCount: SportType.values.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final item = SportType.values[index];
              final active = index == _currentIndex;
              return AnimatedScale(
                duration: const Duration(milliseconds: 180),
                scale: active ? 1 : .92,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  color: active ? AppColors.graphite : AppColors.carbon,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(item.assetPath, fit: BoxFit.cover),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          width: double.infinity,
                          color: Colors.black.withValues(alpha: .72),
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            item.label.toUpperCase(),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Escolhido: ${sport.label}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(3, (index) {
            const labels = [
              'PRIMÁRIO · 75%',
              'SECUNDÁRIO · 15%',
              'TERCIÁRIO · 10%',
            ];
            final assigned = widget.selection[index];
            return OutlinedButton(
              onPressed: () => _assign(index),
              child: Text(
                assigned == null
                    ? labels[index]
                    : '${index + 1}. ${assigned.label}',
              ),
            );
          }),
        ),
      ],
    );
  }
}
