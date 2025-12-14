import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'services/whistle_service.dart';
import 'services/base_page.dart';
import 'services/app_text.dart';
import 'services/echo_card.dart';
import 'services/routes.dart';

import 'chatbot_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _openEchoBot() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatBotPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ECHO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        toolbarHeight: 56,
        backgroundColor: const Color(0xFF3F5F8F),
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: [
          IconButton(
            tooltip: 'Düdük',
            icon: Icon(
              Icons.campaign,
              color: WhistleService.isRunning
                  ? Colors.redAccent
                  : Colors.white,
            ),
            onPressed: () async {
              if (WhistleService.isRunning) {
                await WhistleService.stop();
              } else {
                await WhistleService.start();
              }
              setState(() {});
            },
          ),
          IconButton(
            tooltip: 'Geçmiş Depremler',
            icon: const Icon(Icons.history),
            onPressed: () =>
                Navigator.pushNamed(context, Routes.pastQuakes),
          ),
        ],
      ),

      body: BasePage(
        child: Stack(
          children: [
            Column(
              children: [
                _statusBanner(),
                const SizedBox(height: 8),

                EchoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        'Durumunuz',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _statusButton(
                        'Güvendeyim',
                        Icons.verified_user,
                        Colors.green,
                      ),
                      const SizedBox(height: 6),
                      _statusButton(
                        'Yaralıyım',
                        Icons.medical_information,
                        Colors.orange,
                      ),
                      const SizedBox(height: 6),
                      _statusButton(
                        'Enkaz Altındayım',
                        Icons.report_gmailerrorred,
                        Colors.red,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.6,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      _quickAction(
                        'Uyarılar',
                        Icons.notifications_active_outlined,
                        Routes.alerts,
                      ),
                      _quickAction(
                        'Kaynaklar',
                        Icons.volunteer_activism_outlined,
                        Routes.resources,
                      ),
                      _quickAction(
                        'Tanıdıklar',
                        Icons.contacts_outlined,
                        Routes.contacts,
                      ),
                      _quickAction(
                        'Yol Durumu',
                        Icons.alt_route_rounded,
                        Routes.roads,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            /// 🔵 SABİT ECHOBOT
            Positioned(
              right: 16,
              bottom: 16,
              child: GestureDetector(
                onTap: _openEchoBot,
                child: _echoBotBall(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- UI PARÇALARI ----------------

  Widget _echoBotBall() {
    return Material(
      elevation: 10,
      shape: const CircleBorder(),
      child: Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Color(0xFF4FC3F7),
              Color(0xFF1976D2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.smart_toy, color: Colors.white, size: 30),
            SizedBox(height: 2),
            Text(
              'EchoBot',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBanner() {
    return EchoCard(
      child: Row(
        children: const [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: AppText(
              'Son durumunuz henüz bildirilmedi.',
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusButton(
      String label,
      IconData icon,
      Color color,
      ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {},
      ),
    );
  }

  Widget _quickAction(
      String title,
      IconData icon,
      String route,
      ) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 4),
            AppText(
              title,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
