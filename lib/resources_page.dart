import 'package:flutter/material.dart';
import 'services/routes.dart';

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kaynaklar'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('En Yakın Sığınma Alanları'),
            subtitle: const Text('Listele ve yol tarifi al'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, Routes.nearestShelters);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.medical_services_outlined),
            title: const Text('Acil Yardım Bilgileri'),
            subtitle: const Text('112 · AFAD · Kızılay'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
