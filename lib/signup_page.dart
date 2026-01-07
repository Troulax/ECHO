import 'dart:ui';
import 'package:flutter/material.dart';

import 'data/app_container.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _infoText;
  bool _isLoading = false;

  Future<void> _createAccount() async {
    final name = _nameController.text.trim(); // şimdilik kullanılmıyor
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || username.isEmpty || password.isEmpty) {
      setState(() => _infoText = 'Lütfen tüm alanları doldurun.');
      return;
    }

    if (username.length < 3) {
      setState(() => _infoText = 'Kullanıcı adı en az 3 karakter olmalı.');
      return;
    }

    if (password.length < 3) {
      setState(() => _infoText = 'Şifre en az 3 karakter olmalı.');
      return;
    }

    setState(() {
      _isLoading = true;
      _infoText = null;
    });

    final ok = await authRepo.register(username, password);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (ok) {
      // başarı: login sayfasına dön
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hesap oluşturuldu. Giriş yapabilirsiniz.')),
      );
      Navigator.pop(context);
    } else {
      setState(() {
        _infoText = 'Bu kullanıcı adı zaten alınmış olabilir.';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌊 Mavi Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364),
                ],
              ),
            ),
          ),

          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  width: 340,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Hesap Oluştur',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Bilgilerinizi girerek hesap oluşturun',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 24),

                      _inputField(
                        controller: _nameController,
                        label: 'Ad Soyad',
                        icon: Icons.badge,
                      ),
                      const SizedBox(height: 16),

                      _inputField(
                        controller: _usernameController,
                        label: 'Kullanıcı Adı',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 16),

                      _inputField(
                        controller: _passwordController,
                        label: 'Şifre',
                        icon: Icons.lock,
                        obscureText: true,
                      ),

                      if (_infoText != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _infoText!,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: 24),

                      SizedBox(
                        width: 220,
                        height: 42,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Hesap Oluştur'),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        child: const Text(
                          'Giriş sayfasına dön',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white38),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
