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
