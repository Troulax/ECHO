import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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
  final SocialRepository _socialRepo = SocialRepository();

  String? _me;

  String? _currentStatus; // null => henüz bildirilmedi
  IconData _statusIcon = Icons.info_outline;
  Color _statusColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  Future<void> _loadMe() async {
    final sp = await SharedPreferences.getInstance();
    final username = sp.getString('current_username');
    if (!mounted) return;
    setState(() => _me = username);

    if (username != null && username.trim().isNotEmpty) {
      await _socialRepo.ensureUserDoc(username);
    }
  }

  void _openChatBot() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatBotPage()),
    );
  }

  String _statusCodeFromLabel(String label) {
    switch (label) {
      case 'Güvendeyim':
        return 'safe';
      case 'Yaralıyım':
        return 'injured';
      case 'Enkaz Altındayım':
        return 'trapped';
      default:
        return 'unknown';
    }
  }

  String _statusLabelFromCode(String code) {
    switch (code) {
      case 'safe':
        return 'Güvende';
      case 'injured':
        return 'Yaralı';
      case 'trapped':
        return 'Enkaz';
      default:
        return 'Bilinmiyor';
    }
  }

  IconData _statusIconFromCode(String code) {
    switch (code) {
      case 'safe':
        return Icons.verified_user;
      case 'injured':
        return Icons.medical_information;
      case 'trapped':
        return Icons.report_gmailerrorred;
      default:
        return Icons.help_outline;
    }
  }

  Color _statusColorFromCode(String code) {
    switch (code) {
      case 'safe':
        return Colors.green;
      case 'injured':
        return Colors.orange;
      case 'trapped':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('dd.MM.yyyy HH:mm').format(dt.toLocal());
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

                      // ✅ İSTEDİĞİN: Favoriler, durum butonlarının AŞAĞISINDA
                      const SizedBox(height: 14),
                      _favoritesSection(),
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
                clipBehavior: Clip.antiAlias,
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

  Widget _favoritesSection() {
    final me = _me;

    if (me == null || me.trim().isEmpty) {
      return const EchoCard(
        child: Row(
          children: [
            Icon(Icons.star_border, size: 18),
            SizedBox(width: 10),
            Expanded(child: AppText('Favoriler için giriş gerekli.')),
          ],
        ),
      );
    }

    return EchoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star, size: 18),
              SizedBox(width: 10),
              AppText(
                'Favoriler',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<String>>(
            stream: _socialRepo.favoritesStream(me),
            builder: (context, favSnap) {
              final favs = favSnap.data ?? <String>[];
              if (favs.isEmpty) {
                return const AppText(
                  'Henüz favori yok. Tanıdıklardan en fazla 3 kişi ekleyebilirsin.',
                  maxLines: 2,
                );
              }

              return StreamBuilder<List<UserProfile>>(
                stream: _socialRepo.favoriteProfilesStream(favs.take(3).toList()),
                builder: (context, profSnap) {
                  final profiles = profSnap.data ?? <UserProfile>[];

                  if (profiles.isEmpty) {
                    return const AppText('Favoriler yükleniyor...', maxLines: 1);
                  }

                  return Column(
                    children: profiles.take(3).map((p) {
                      final color = _statusColorFromCode(p.status);
                      final timeText = p.statusUpdatedAt == null
                          ? ''
                          : ' • ${_formatDateTime(p.statusUpdatedAt!)}';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              _statusIconFromCode(p.status),
                              size: 18,
                              color: color,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppText(
                                '${p.username} • ${_statusLabelFromCode(p.status)}$timeText',
                                style: TextStyle(color: color),
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        ],
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
        onPressed: () async {
          setState(() {
            _currentStatus = label;
            _statusIcon = icon;
            _statusColor = color;
          });

          final me = _me;
          if (me == null || me.trim().isEmpty) return;

          final code = _statusCodeFromLabel(label);
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
