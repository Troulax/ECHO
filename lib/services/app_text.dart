import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;

  const AppText(
      this.text, {
        super.key,
        this.style,
        this.maxLines = 1,
      });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      style: style,
    );
  }
}
