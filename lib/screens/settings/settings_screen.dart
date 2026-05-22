import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../managers/session_manager.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Paramètres', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kBlue)),
        const SizedBox(height: 20),
        _section('Compte', [
          _tile(Icons.person_rounded, 'Nom', SessionManager.nom, kBlue),
          _tile(Icons.email_rounded, 'Email', SessionManager.email, kBlue),
          _tile(Icons.badge_rounded, 'Rôle', SessionManager.role, kPurple),
        ]),
        const SizedBox(height: 16),
        _section('Application', [
          _tile(Icons.api_rounded, 'API Backend', 'kewere-aissa-smart.onrender.com', kGreen),
          _tile(Icons.info_rounded, 'Version', '1.0.0', Colors.grey),
        ]),
        const SizedBox(height: 16),
        _section('Notifications', [
          _switchTile('Alertes stock', true),
          _switchTile('Alertes mortalité', true),
          _switchTile('Rapports hebdomadaires', false),
        ]),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton.icon(
                onPressed: () async {
                  await SessionManager.clear();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Se déconnecter', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0,
                    side: BorderSide(color: Colors.red.shade200)))),
      ]),
    );
  }

  Widget _section(String title, List<Widget> children) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 1)),
    const SizedBox(height: 8),
    Container(decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
        child: Column(children: children)),
  ]);

  Widget _tile(IconData icon, String title, String value, Color color) =>
      ListTile(leading: Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(value, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 14));

  Widget _switchTile(String title, bool value) =>
      StatefulBuilder(builder: (_, setState) => SwitchListTile(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          value: value, activeColor: kBlue,
          onChanged: (v) => setState(() {})));
}