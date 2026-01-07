import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/social_repository.dart';

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
  String? _currentStatus; // null => henüz bildirilmedi
  IconData _statusIcon = Icons.info_outline;
  Color _statusColor = Colors.white;

  // ✅ Status sync için eklendi (UI değişmez)
  final SocialRepository _socialRepo = SocialRepository();
  String? _me; // current_username

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  Future<void> _loadMe() async {
    final prefs = await SharedPreferences.getInstance();
    final u = prefs.getString('current_username');
    setState(() => _me = u);

    // Firestore'da user doc garanti olsun (hata olursa UI'ı bozmaz)
    if (u != null) {
      try {
        await _socialRepo.ensureUserDoc(u);
      } catch (_) {}
    }
  }

  void _openChatBot() {
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
              color: WhistleService.isRunning ? Colors.redAccent : Colors.white,
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
            onPressed: () => Navigator.pushNamed(context, Routes.pastQuakes),
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),

                      _statusButton(
                        'Güvendeyim',
                        Icons.verified_user,
                        Colors.green,
                      ),
                      const SizedBox(height: 10),

                      _statusButton(
                        'Yaralıyım',
                        Icons.medical_information,
                        Colors.orange,
                      ),
                      const SizedBox(height: 10),

                      _statusButton(
                        'Enkaz Altındayım',
                        Icons.report_gmailerrorred,
                        Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Positioned(
              right: 16,
              bottom: 16,
              child: Material(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.antiAlias, // 👈 gerçek kırpma
                child: InkWell(
                  onTap: _openChatBot,
                  splashColor: Colors.white12,
                  highlightColor: Colors.transparent,
                  child: Ink(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3F5F8F),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.smart_toy_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBanner() {
    final text = _currentStatus == null
        ? 'Durumunuz henüz bildirilmedi.'
        : 'Durumunuz: $_currentStatus';

    return EchoCard(
      child: Row(
        children: [
          Icon(_statusIcon, size: 18, color: _statusColor),
          const SizedBox(width: 10),
          Expanded(
            child: AppText(
              text,
              maxLines: 2,
              style: TextStyle(
                color: _currentStatus == null ? null : _statusColor,
                fontWeight: _currentStatus == null ? null : FontWeight.w600,
              ),
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
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // ✅ SADECE BURAYA status sync eklendi
        onPressed: () async {
          setState(() {
            _currentStatus = label;
            _statusIcon = icon;
            _statusColor = color;
          });

          final me = _me;
          if (me == null) return;

          // label -> firestore status code
          final String code;
          switch (label) {
            case 'Güvendeyim':
              code = 'safe';
              break;
            case 'Yaralıyım':
              code = 'injured';
              break;
            case 'Enkaz Altındayım':
              code = 'trapped';
              break;
            default:
              code = 'unknown';
          }

          try {
            await _socialRepo.setMyStatus(username: me, status: code);
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Status sync hatası: $e')),
            );
          }
        },
      ),
    );
  }
}
