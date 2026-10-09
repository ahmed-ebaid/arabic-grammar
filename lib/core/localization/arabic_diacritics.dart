import 'package:flutter/material.dart';

class ArabicDiacriticsText extends StatelessWidget {
  const ArabicDiacriticsText(
    this.data, {
    this.style,
    this.textAlign,
    this.textDirection,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.textWidthBasis,
    super.key,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final TextWidthBasis? textWidthBasis;

  @override
  Widget build(BuildContext context) {
    final formatted = makeArabicDiacriticsVisible(data);
    final effectiveStyle = style ?? DefaultTextStyle.of(context).style;
    final markStyle = effectiveStyle.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontSize: (effectiveStyle.fontSize ?? 14) + 6,
      fontWeight: FontWeight.w700,
    );
    final spans = <InlineSpan>[];
    final marks = RegExp(r'ـ[\u064B-\u0652\u0670]+');
    var offset = 0;

    for (final match in marks.allMatches(formatted)) {
      if (match.start > offset) {
        spans.add(TextSpan(text: formatted.substring(offset, match.start)));
      }
      spans.add(TextSpan(text: match.group(0), style: markStyle));
      offset = match.end;
    }
    if (offset < formatted.length) {
      spans.add(TextSpan(text: formatted.substring(offset)));
    }

    return Text.rich(
      TextSpan(children: spans),
      style: style,
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textWidthBasis: textWidthBasis,
    );
  }
}

String makeArabicDiacriticsVisible(String text) {
  final withSeparatedMarks = text.replaceAllMapped(
    RegExp(r':\s*([\u064B-\u0652\u0670]+)'),
    (match) => ' (ـ${match[1]})',
  );
  final runes = withSeparatedMarks.runes.toList(growable: false);
  final output = StringBuffer();

  for (var index = 0; index < runes.length; index++) {
    final rune = runes[index];
    if (_isArabicDiacritic(rune) &&
        (index == 0 ||
            (!_isArabicLetter(runes[index - 1]) &&
                runes[index - 1] != 0x0640 &&
                !_isArabicDiacritic(runes[index - 1])))) {
      output.writeCharCode(0x0640);
    }
    output.writeCharCode(rune);
  }
  return output.toString();
}

bool _isArabicDiacritic(int rune) =>
    (rune >= 0x064B && rune <= 0x0652) || rune == 0x0670;

bool _isArabicLetter(int rune) =>
    (rune >= 0x0621 && rune <= 0x064A) ||
    (rune >= 0x066E && rune <= 0x06D3) ||
    (rune >= 0x06FA && rune <= 0x06FC);
