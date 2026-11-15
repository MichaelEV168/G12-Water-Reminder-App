import 'package:flutter/material.dart';

class BottleVisualizer extends StatelessWidget {
  const BottleVisualizer({
    required this.progress,
    required this.percentage,
    required this.consumed,
    required this.goal,
    super.key,
  });

  final double progress;
  final int percentage;
  final int consumed;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 190,
      height: 298,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            child: Container(
              width: 52,
              height: 13,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
              ),
            ),
          ),
          Positioned(
            top: 12,
            child: Container(
              width: 70,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade500,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ),
          ),
          Positioned(
            top: 31,
            child: Container(
              width: 170,
              height: 264,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFE2E8F0),
                border: Border(
                  left: BorderSide(color: Colors.blueGrey.shade300, width: 6),
                  right: BorderSide(color: Colors.blueGrey.shade300, width: 6),
                  bottom: BorderSide(color: Colors.blueGrey.shade300, width: 6),
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(42),
                  top: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(.12),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(36),
                  top: Radius.circular(8),
                ),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeInOut,
                      height: (252 * progress.clamp(0, 1)).toDouble(),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 16,
                      bottom: 34,
                      child: Container(
                        width: 10,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.35),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 20,
                      bottom: 20,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('100%', style: TextStyle(fontSize: 9, color: Colors.blueGrey)),
                          Text('75%', style: TextStyle(fontSize: 9, color: Colors.blueGrey)),
                          Text('50%', style: TextStyle(fontSize: 9, color: Colors.blueGrey)),
                          Text('25%', style: TextStyle(fontSize: 9, color: Colors.blueGrey)),
                        ],
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              fontSize: 31,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.onSurface,
                              shadows: const [Shadow(color: Colors.white54, blurRadius: 8)],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor.withOpacity(.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${_format(consumed)} / ${_format(goal)} ml', style: const TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _format(int value) => value.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );
}
