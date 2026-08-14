import 'package:flutter/material.dart';

class ArabicText extends StatelessWidget {
  const ArabicText(
    this.data, {
    this.style,
    this.textAlign = TextAlign.start,
    super.key,
  });

  final String data;
  final TextStyle? style;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Text(
        data,
        textAlign: textAlign,
        style: const TextStyle(
          fontFamily: 'AmiriQuran',
          height: 1.8,
        ).merge(style),
      ),
    );
  }
}
