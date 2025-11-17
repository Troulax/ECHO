import 'package:flutter/material.dart';

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Kaynaklar')),
    body: const Center(child: Text('Yardım noktaları (örnek)')),
  );
}
