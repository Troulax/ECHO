import 'package:flutter/material.dart';

class EchoCard extends StatelessWidget {
  final Widget child;

  const EchoCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
