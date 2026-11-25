import 'package:flutter/material.dart';

import '../../core/localization/arabic_diacritics.dart';
import '../../core/models/content_models.dart';
import '../../core/theme/app_theme.dart';

class LessonMindMapView extends StatelessWidget {
  const LessonMindMapView({
    required this.mindMap,
    required this.languageCode,
    super.key,
  });

  final LessonMindMap mindMap;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = Theme.of(context).extension<LearningColors>()!;
    final palette = [
      (colors.blueContainer, colors.onBlueContainer),
      (colors.sunshineContainer, colors.onSunshineContainer),
      (colors.coralContainer, colors.onCoralContainer),
      (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      (scheme.secondaryContainer, scheme.onSecondaryContainer),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          key: const ValueKey('mindMapCenter'),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Icon(Icons.account_tree_rounded, color: scheme.onPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: ArabicDiacriticsText(
                  mindMap.center.forLanguage(languageCode),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        for (final (index, branch) in mindMap.branches.indexed)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 32,
                  child: CustomPaint(
                    painter: _ConnectorPainter(
                      color: scheme.primary,
                      isLast: index == mindMap.branches.length - 1,
                      textDirection: Directionality.of(context),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: _BranchCard(
                      branch: branch,
                      languageCode: languageCode,
                      background: palette[index % palette.length].$1,
                      foreground: palette[index % palette.length].$2,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({
    required this.branch,
    required this.languageCode,
    required this.background,
    required this.foreground,
  });

  final MindMapNode branch;
  final String languageCode;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ArabicDiacriticsText(
            branch.label.forLanguage(languageCode),
            style: textTheme.titleMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.bold,
            ),
          ),
          ..._nodeDetails(branch, textTheme),
          for (final child in branch.children)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(14),
                  border: BorderDirectional(
                    start: BorderSide(color: foreground, width: 4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ArabicDiacriticsText(
                      child.label.forLanguage(languageCode),
                      style: textTheme.titleSmall?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    ..._nodeDetails(child, textTheme),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _nodeDetails(MindMapNode node, TextTheme textTheme) {
    final detail = node.detail;
    return [
      if (detail != null) ...[
        const SizedBox(height: 6),
        ArabicDiacriticsText(
          detail.forLanguage(languageCode),
          style: textTheme.bodyMedium?.copyWith(color: foreground),
        ),
      ],
      if (node.examples.isNotEmpty) ...[
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final example in node.examples)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: ArabicDiacriticsText(
                    example,
                    style: textTheme.titleMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    ];
  }
}

class _ConnectorPainter extends CustomPainter {
  const _ConnectorPainter({
    required this.color,
    required this.isLast,
    required this.textDirection,
  });

  final Color color;
  final bool isLast;
  final TextDirection textDirection;

  static const _branchY = 40.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final trunkX = size.width / 2;
    final cardX = textDirection == TextDirection.rtl ? 0.0 : size.width;
    canvas.drawLine(
      Offset(trunkX, 0),
      Offset(trunkX, isLast ? _branchY : size.height),
      paint,
    );
    canvas.drawLine(Offset(trunkX, _branchY), Offset(cardX, _branchY), paint);
    canvas.drawCircle(Offset(trunkX, _branchY), 5, paint);
  }

  @override
  bool shouldRepaint(_ConnectorPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.isLast != isLast ||
      oldDelegate.textDirection != textDirection;
}
