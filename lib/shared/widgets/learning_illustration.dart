import 'package:flutter/material.dart';

class LearningIllustration extends StatelessWidget {
  const LearningIllustration({
    required this.semanticLabel,
    this.celebrating = false,
    super.key,
  });

  final String semanticLabel;
  final bool celebrating;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticLabel,
      image: true,
      child: ExcludeSemantics(
        child: SizedBox(
          height: 132,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
              ),
              Transform.rotate(
                angle: -0.08,
                child: Container(
                  width: 76,
                  height: 88,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(blurRadius: 10, color: Colors.black12),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'ع',
                    style: TextStyle(
                      fontFamily: 'AmiriQuran',
                      fontSize: 52,
                      color: scheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 42,
                child: Icon(
                  celebrating ? Icons.star : Icons.auto_awesome,
                  color: Colors.amber.shade700,
                  size: 28,
                ),
              ),
              Positioned(
                bottom: 8,
                left: 44,
                child: Icon(
                  celebrating ? Icons.celebration : Icons.lightbulb,
                  color: scheme.tertiary,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
