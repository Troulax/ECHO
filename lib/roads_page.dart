import 'package:flutter/material.dart';

class RoadsPage extends StatelessWidget {
  const RoadsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Yol Durumu')),
    body: const Center(child: Text('Açık/Kapalı yollar (örnek)')),
  );
}
