import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../managers/session_manager.dart';
import '../auth/login_screen.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
      Container(width: double.infinity, padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [kBlue, Color(0xFF2563EB)]),
              borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: kBlue.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))]),
          child: Column(children: [
            Container(width: 70, height: 70, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: const Center(child: Text('👤', style: TextStyle(fontSize: 36)))),
            const SizedBox(height: 12),
            Text(SessionManager.nom.isNotEmpty ? SessionManager.nom : 'Utilisateur',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 4),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text('⭐ ${SessionManager.role.toUpperCase()}', style: const TextStyle(color: Colors.white, fontSize: 12))),
          ])),
      const SizedBox(height: 16),
      _menuCard(Icons.email_rounded, SessionManager.email.isNotEmpty ? SessionManager.email : 'Email', 'Email', kBlue),
      _menuCard(Icons.api_rounded, 'kewere-aissa-smart.onrender.com', 'API Backend', kPurple),
      const SizedBox(height: 16),
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
    ]));
  }

  static Widget _menuCard(IconData icon, String title, String subtitle, Color color) =>
      Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 22)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ])),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 14),
          ]));
}