import 'package:flutter/material.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tanıdıklar')),
    body: const Center(child: Text('Kişi listesi (örnek)')),
  );
}
