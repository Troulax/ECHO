import 'package:flutter/material.dart';

class BasePage extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const BasePage({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
        child: child,
      ),
    );
  }
}
