import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/app_constants.dart';
import '../../managers/session_manager.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String _error = '';
  bool _showPass = false;

  @override
  void dispose() { _loginCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  bool _isValid() {
    if (_loginCtrl.text.trim().isEmpty) { setState(() => _error = 'Entrez votre email ou numéro'); return false; }
    if (_passCtrl.text.trim().isEmpty) { setState(() => _error = 'Entrez votre mot de passe'); return false; }
    return true;
  }

  Future<void> _login() async {
    if (!_isValid()) return;
    setState(() { _loading = true; _error = ''; });
    try {
      final r = await http.post(Uri.parse('$API_URL/auth/login'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {'username': _loginCtrl.text.trim(), 'password': _passCtrl.text})
          .timeout(const Duration(seconds: 15));
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        final token = data['access_token'] ?? '';
        final tempHeaders = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
        final meR = await http.get(Uri.parse('$API_URL/auth/me'), headers: tempHeaders).timeout(const Duration(seconds: 10));
        String role = 'proprietaire', nom = '', email = '', entrepriseId = '', fermeId = '';
        if (meR.statusCode == 200) {
          final me = jsonDecode(meR.body);
          role = me['role'] ?? 'proprietaire';
          nom = me['nom'] ?? '';
          email = me['email'] ?? '';
          entrepriseId = me['entreprise_id'] ?? '';
          fermeId = me['ferme_id'] ?? '';
        }
        await SessionManager.save(token: token, role: role, nom: nom, email: email, entrepriseId: entrepriseId, fermeId: fermeId);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        setState(() => _error = 'Email/numéro ou mot de passe incorrect');
      }
    } catch (e) {
      setState(() => _error = 'Erreur de connexion — vérifiez votre réseau');
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F172A), Color(0xFF1E3A5F)])),
        child: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [
          const SizedBox(height: 50),
          Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)), child: const Center(child: Text('🐔', style: TextStyle(fontSize: 44)))),
          const SizedBox(height: 16),
          const Text('Kewere Aissa Smart', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          const Text('Plateforme Avicole Intelligente', style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 40),
          Container(padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Connexion', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kBlue)),
                const SizedBox(height: 4),
                const Text('Email ou numéro de téléphone', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 24),
                TextField(controller: _loginCtrl, keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: 'Email ou téléphone', hintText: 'ex: nom@email.com',
                        prefixIcon: const Icon(Icons.person_outline, color: kBlueLight),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBlue, width: 2)),
                        filled: true, fillColor: const Color(0xFFF8FAFC))),
                const SizedBox(height: 16),
                TextField(controller: _passCtrl, obscureText: !_showPass,
                    decoration: InputDecoration(labelText: 'Mot de passe',
                        prefixIcon: const Icon(Icons.lock_outline, color: kBlueLight),
                        suffixIcon: IconButton(icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: () => setState(() => _showPass = !_showPass)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBlue, width: 2)),
                        filled: true, fillColor: const Color(0xFFF8FAFC))),
                if (_error.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.shade200)),
                      child: Row(children: [Icon(Icons.error_outline, color: Colors.red.shade600, size: 18), const SizedBox(width: 8), Expanded(child: Text(_error, style: TextStyle(color: Colors.red.shade700, fontSize: 13)))])),
                ],
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, height: 52,
                    child: ElevatedButton(onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(backgroundColor: kBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                        child: _loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : const Text('Se connecter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)))),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Pas encore de compte ?', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: const Text('Créer un compte', style: TextStyle(color: kBlue, fontWeight: FontWeight.w700, fontSize: 13))),
                ]),
              ])),
        ]))),
      ),
    );
  }
}