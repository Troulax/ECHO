import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool isTyping = false;

  final List<_Msg> messages = [
    _Msg(
      role: _Role.bot,
      text:
          "Merhaba, ben EchoBot.\nBuradayım ve seni dinliyorum.",
    ),
  ];

  // 🔴 API KEY
  static const String openAiApiKey = "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";

  Future<void> sendMessage(String userText) async {

    final scenario = _detectScenario(userText);

    if (scenario != null) {
      setState(() {
        messages.add(_Msg(role: _Role.user, text: userText));
        messages.add(
          _Msg(
            role: _Role.bot,
            text: _scenarioResponse(scenario),
          ),
        );
      });
      _scrollToBottom();
      return; // 
}

    if (_isCrisisMessage(userText)) {
      setState(() {
        messages.add(
          _Msg(
            role: _Role.bot,
            text:
              "Buradayım. Yalnız değilsin.\nŞimdi birlikte yavaşlayalım.\n4 saniye nefes al, 4 saniye tut, 6 saniye ver.\nBunu 3 kez dene.",
          ),
        );
      });
    _scrollToBottom();
  }

    setState(() {
      messages.add(_Msg(role: _Role.user, text: userText));
      isTyping = true;
    });
    controller.clear();
    _scrollToBottom();

    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $openAiApiKey",
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {
            "role": "system",
            "content": """
You are the ECHO AI Chatbot Assistant, designed to support users during and after earthquakes.

Your primary responsibilities are:

1. Psychological Support
- Provide calm, empathetic, non-judgmental, emotionally supportive guidance.
- Help users manage panic, stress, fear, or confusion.
- Offer simple breathing or grounding exercises when appropriate.
- Never give clinical diagnoses or medical advice.

2. Crisis Communication Helper
- Communicate clearly and simply, optimized for stressful situations.
- Guide the user step-by-step when needed.
- Prioritize emotional stability and clarity.

3. Information & Assistance Guidance
- Explain how ECHO app features work when asked.
- You do NOT perform actions on behalf of the user.
- You only guide, clarify, and support.

4. Tone & Behavior
- Always be calm, warm, and reassuring.
- Keep messages short and easy to understand.
- Never make unrealistic promises (e.g., “Help is definitely coming”).
- Respect user privacy; never ask unnecessary personal data.

5. Safety Protocol
- If the user expresses fear, panic, or danger, reassure them and help them slow their breathing.
- Encourage using the app’s emergency features when appropriate.
- You are not emergency services.

Your goal is to keep the user calm, supported, and informed.
"""
          },
          ...messages.map((m) => {
                "role": m.role == _Role.user ? "user" : "assistant",
                "content": m.text
              }),
          {"role": "user", "content": userText}
        ],
        "max_tokens": 200
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final reply = data["choices"][0]["message"]["content"];

      setState(() {
        messages.add(_Msg(role: _Role.bot, text: reply));
        isTyping = false;
      });
      _scrollToBottom();
    }

    else {
      setState(() {
        isTyping = false;
        messages.add(
          _Msg(
            role: _Role.bot,
            text: "Şu an yanıt veremiyorum. Lütfen biraz sonra tekrar dene.",
      ),
    );
  });
}

  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
}

  bool _isCrisisMessage(String text) {
    final keywords = [
      "korkuyorum",
      "panik",
      "nefes",
      "yardım",
      "enkaz",
      "ölüyorum",
      "kan",
      "yaralıyım",
      "çok korktum"
    ];

    final lower = text.toLowerCase();
    return keywords.any((k) => lower.contains(k));
  }

  String? _detectScenario(String text) {
    final lower = text.toLowerCase();

    if (lower.contains("enkaz")) return "trapped";
    if (lower.contains("yaralı") || lower.contains("kan")) return "injured";
    if (lower.contains("güvendeyim") || lower.contains("iyiyim")) return "safe";

    return null;
}

  String _scenarioResponse(String scenario) {
    switch (scenario) {
      case "trapped":
        return
            "Buradayım. Yalnız değilsin.\n\n"
            "• Enerjini koru\n"
            "• Telefonu gereksiz kullanma\n"
            "• Ses duyduğunda cevap ver\n"
            "• Toz varsa ağzını burnunu kapat\n\n"
            "Durum Bildir özelliğini kullanmayı dene.";

      case "injured":
        return
            "Buradayım.\n\n"
            "• Kanamaya baskı uygula\n"
            "• Hareketi minimumda tut\n\n"
            "Durumunu bildirmen önemli.";

      case "safe":
        return
            "Bunu duymak iyi.\n\n"
            "• Güvenli bir yerde kal\n"
            "• Artçılara dikkat et\n\n"
            "EchoBot buradayım.";

      default:
        return "";
    }
  }




  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFF7F4EF);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("EchoBot"),
        backgroundColor: bg,
        elevation: 0,
      ),
      body: Column(
        children: [
          
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0E9DF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Acil Durum İletişim",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _emergencyChip(Icons.local_hospital, "112"),
                    _emergencyChip(Icons.local_fire_department, "110"),
                    _emergencyChip(Icons.local_police, "155"),
                    _emergencyChip(Icons.warning_amber_rounded, "AFAD 122"),
                  ],
                ),
            ],
          ),
        ),

          // 🔹 CHAT LIST
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg.role == _Role.user;

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    constraints: const BoxConstraints(maxWidth: 520),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.text,
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                            height: 1.4,
                        ),
                      ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(msg.time),
                          style: TextStyle(
                            fontSize: 10,
                            color: isUser ? Colors.white70 : Colors.grey,
      ),
    ),
  ],
),

                  ),
                );
              },
            ),
          ),

          if (isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 6),
              child: Row(
                children: const [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                  "EchoBot yazıyor…",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    ),
  ),


          // 🔹 INPUT BAR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onSubmitted: (v) {
                        if (v.trim().isNotEmpty) sendMessage(v.trim());
                      },
                      decoration: InputDecoration(
                        hintText: "Mesaj yaz…",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        final text = controller.text.trim();
                        if (text.isNotEmpty) sendMessage(text);
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _emergencyChip(IconData icon, String label) {
    return ActionChip(
      avatar: Icon(icon, color: Colors.red),
      label: Text(label),
      onPressed: () {
      },
    );
  }
}

enum _Role { user, bot }

class _Msg {
  final _Role role;
  final String text;
  final DateTime time;
  
  _Msg({
    required this.role,
    required this.text,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}
