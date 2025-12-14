import 'package:flutter/material.dart';
import 'services/base_page.dart';
import 'services/app_text.dart';
import 'services/echo_card.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Uyarılar',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          EchoCard(
            child: Row(
              children: const [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 12),
                Expanded(
                  child: AppText(
                    'AFAD tarafından yayınlanan aktif bir uyarı bulunmamaktadır.',
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
