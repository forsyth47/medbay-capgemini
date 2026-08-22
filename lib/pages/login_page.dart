import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _selectedRole = 'patient';
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  // Role-based demo credentials
  final Map<String, Map<String, String>> _creds = {
    'patient': {'email': 'patient1@arete.com', 'pass': 'password123'},
    'doctor': {'email': 'doctor@arete.com', 'pass': 'password123'},
    'caretaker': {'email': 'caretaker@arete.com', 'pass': 'password123'},
  };

  @override
  void initState() {
    super.initState();
    _applyCreds();
  }

  void _applyCreds() {
    _emailCtrl.text = _creds[_selectedRole]!['email']!;
    _passCtrl.text = _creds[_selectedRole]!['pass']!;
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    final ok = await SupabaseService.signIn(_emailCtrl.text, _passCtrl.text);
    setState(() => _loading = false);

    if (ok && mounted) {
      await navigateToRoleHome(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed')),
      );
    }
  }

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
      _applyCreds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade900, Colors.deepPurple.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.medication,
                        size: 40, color: Colors.deepPurple.shade700),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Medbay',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"Right Medicine. Right Time. Every Time."',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  // Role selector
                  Text('CONTINUE AS',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _roleBtn('Patient', Icons.person_outline, 'patient'),
                      const SizedBox(width: 12),
                      _roleBtn('Doctor', Icons.monitor_heart_outlined, 'doctor'),
                      const SizedBox(width: 12),
                      _roleBtn('Caretaker', Icons.favorite_outline, 'caretaker'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Welcome back!',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Sign in to manage your medications',
                      style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 24),
                  _field('EMAIL', _emailCtrl, false),
                  const SizedBox(height: 16),
                  _passField(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(value: false, onChanged: (_) {}),
                      const Text('Remember me'),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Forgot password?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_outline, size: 18),
                                SizedBox(width: 8),
                                Text('Sign In Securely',
                                    style: TextStyle(fontSize: 16)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user_outlined,
                          size: 14, color: Colors.teal),
                      const SizedBox(width: 6),
                      Text('Secured with 256-bit encryption',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text("Don't have an account? Create Account"),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleBtn(String label, IconData icon, String role) {
    final active = _selectedRole == role;
    return GestureDetector(
      onTap: () => _selectRole(role),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.3),
            width: active ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: active ? Colors.white : Colors.white70, size: 24),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    color: active ? Colors.white : Colors.white70,
                    fontSize: 11,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, bool obscure) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            prefixIcon:
                Icon(label == 'EMAIL' ? Icons.email_outlined : Icons.lock_outline,
                    size: 18, color: Colors.grey.shade500),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _passField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PASSWORD',
            style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: _passCtrl,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            prefixIcon: Icon(Icons.lock_outline,
                size: 18, color: Colors.grey.shade500),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade600,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
