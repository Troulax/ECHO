import 'package:flutter/material.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Uyarılar')),
    body: const Center(child: Text('Uyarılar listesi (örnek)')),
  );
}
