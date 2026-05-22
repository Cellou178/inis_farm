import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../services/api_service.dart';

void _snack(BuildContext context, String msg, Color color) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String _error = '';
  bool _showPass = false;

  @override
  void dispose() { _nomCtrl.dispose(); _emailCtrl.dispose(); _telCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _register() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final result = await ApiService.register({
        'nom': _nomCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'telephone': _telCtrl.text.trim(),
        'mot_de_passe': _passCtrl.text,
        'role': 'proprietaire',
        'entreprise_id': '11111111-1111-1111-1111-111111111111',
      });
      if (result['status'] == 200 || result['status'] == 201) {
        Navigator.pop(context);
        _snack(context, '✅ Compte créé ! Connectez-vous.', kGreen);
      } else {
        setState(() => _error = result['body']['detail']?.toString() ?? 'Erreur');
      }
    } catch (e) { setState(() => _error = 'Erreur de connexion'); }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F172A), Color(0xFF1E3A5F)])),
        child: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [
          const SizedBox(height: 20),
          Row(children: [
            IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
            const Text('Créer un compte', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 24),
          Container(padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Nouveau partenaire', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kBlue)),
                const SizedBox(height: 24),
                _field(_nomCtrl, 'Nom complet *', Icons.person_rounded),
                const SizedBox(height: 12),
                _field(_emailCtrl, 'Email *', Icons.email_rounded, isEmail: true),
                const SizedBox(height: 12),
                _field(_telCtrl, 'Téléphone', Icons.phone_rounded, isPhone: true),
                const SizedBox(height: 12),
                TextField(controller: _passCtrl, obscureText: !_showPass,
                    decoration: InputDecoration(labelText: 'Mot de passe *',
                        prefixIcon: const Icon(Icons.lock_outline, color: kBlueLight),
                        suffixIcon: IconButton(icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _showPass = !_showPass)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: const Color(0xFFF8FAFC))),
                if (_error.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_error, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
                ],
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, height: 52,
                    child: ElevatedButton(onPressed: _loading ? null : _register,
                        style: ElevatedButton.styleFrom(backgroundColor: kGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                        child: _loading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('Créer mon compte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)))),
              ])),
        ]))),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, {bool isEmail = false, bool isPhone = false}) =>
      TextField(controller: ctrl, keyboardType: isEmail ? TextInputType.emailAddress : isPhone ? TextInputType.phone : TextInputType.text,
          decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: kBlueLight),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true, fillColor: const Color(0xFFF8FAFC)));
}