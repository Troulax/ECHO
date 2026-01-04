import 'package:flutter/material.dart';
import 'services/routes.dart';

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kaynaklar')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('En Yakın Sığınma Alanları'),
            subtitle: const Text('Konumuna göre en yakın toplanma alanları'),
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.nearestShelters,
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.medical_services),
            title: const Text('Acil Yardım Bilgileri'),
            subtitle: const Text('112 · AFAD · Kızılay'),
            onTap: () {
              // ileride
            },
          ),
        ],
      ),
    );
  }
}
