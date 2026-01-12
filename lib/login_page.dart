import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/routes.dart';
import 'data/app_container.dart';
import 'data/social_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final SocialRepository _socialRepo = SocialRepository();

  String? _errorText;
  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorText = 'Kullanıcı adı ve şifre gerekli.');
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      
      final ok = await authRepo.login(username, password);

      if (!ok) {
        setState(() {
          _errorText = 'Kullanıcı adı veya şifre hatalı';
          _loading = false;
        });
        return;
      }


      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_username', username);

      () async {
        try {
          await _socialRepo
              .ensureUserDoc(username)
              .timeout(const Duration(seconds: 5));
        } catch (_) {
          
        }
      }();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.root);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = 'Giriş sırasında hata: $e';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          
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
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Hoş Geldiniz',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Devam etmek için giriş yapın',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 24),

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

                      if (_errorText != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorText!,
                          style: const TextStyle(color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: 24),

                      SizedBox(
                        width: 220,
                        height: 42,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Giriş Yap'),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: 220,
                        height: 42,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                          label: const Text('Google ile Giriş'),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.signup);
                        },
                        child: const Text(
                          'Hesap Oluştur',
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
