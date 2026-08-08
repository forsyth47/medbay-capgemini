import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController(text: 'arete@test.com');
  final _passCtrl = TextEditingController(text: '');
  bool _loading = false;
  bool _obscurePassword = true; // NEW

  Future<void> _login() async {
    setState(() => _loading = true);
    final ok = await SupabaseService.signIn(_emailCtrl.text, _passCtrl.text);
    setState(() => _loading = false);
    if (ok && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // NEW: auto-resize when keyboard opens
      body: Column(
        children: [
          // Blue header with pills illustration
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade400],
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _pill(Colors.blue.shade300, Colors.white),
                  const SizedBox(width: 12),
                  _pill(Colors.green.shade300, Colors.yellow.shade200),
                  const SizedBox(width: 12),
                  _pill(Colors.orange.shade300, Colors.white),
                ],
              ),
            ),
          ),
          // NEW: Expanded + SingleChildScrollView kills the bottom overflow
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Welcome Back!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Sign in to manage your medications',
                      style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 24),
                  _field('EMAIL / MOBILE NUMBER', _emailCtrl, false),
                  const SizedBox(height: 16),
                  _passField(), // NEW: extracted password field with toggle
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(value: false, onChanged: (_) {}),
                      const Text('Remember Me'),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Forgot Password?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Login', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text('OR', style: TextStyle(color: Colors.grey.shade500)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialBtn(Icons.g_mobiledata),
                      const SizedBox(width: 16),
                      _socialBtn(Icons.facebook),
                    ],
                  ),
                  const SizedBox(height: 24), // breathing room for scroll
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, bool obscure) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  // NEW: password field with eye icon
  Widget _passField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PASSWORD', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 6),
        TextField(
          controller: _passCtrl,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade600,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pill(Color c1, Color c2) => Container(
        width: 50,
        height: 20,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [c1, c2]),
          borderRadius: BorderRadius.circular(10),
        ),
      );

  Widget _socialBtn(IconData icon) => CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey.shade200,
        child: Icon(icon, color: Colors.grey.shade700),
      );
}
