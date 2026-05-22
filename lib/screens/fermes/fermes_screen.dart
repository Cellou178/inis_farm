import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/app_constants.dart';
import '../../managers/session_manager.dart';

class FermesScreen extends StatefulWidget {
  const FermesScreen({super.key});
  @override
  State<FermesScreen> createState() => _FermesScreenState();
}

class _FermesScreenState extends State<FermesScreen> {
  List _fermes = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await http.get(Uri.parse('$API_URL/fermes/'), headers: SessionManager.headers)
          .timeout(const Duration(seconds: 15));
      if (r.statusCode == 200) setState(() => _fermes = jsonDecode(r.body));
    } catch (e) { debugPrint('getFermes: $e'); }
    setState(() => _loading = false);
  }

  Future<void> _createFerme(Map<String, dynamic> data) async {
    try {
      final r = await http.post(Uri.parse('$API_URL/fermes/'),
          headers: SessionManager.headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 15));
      if (r.statusCode == 200 || r.statusCode == 201) {
        _load();
        _snack('✅ Ferme créée !', kGreen);
      } else {
        _snack('❌ Erreur création ferme', kRed);
      }
    } catch (e) { _snack('❌ Erreur réseau', kRed); }
  }

  void _snack(String msg, Color color) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: color, behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading ? const Center(child: CircularProgressIndicator(color: kBlue)) :
      RefreshIndicator(onRefresh: _load, color: kBlue,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Mes Fermes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kBlue)),
                Text('${_fermes.length} ferme(s)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ]),
              ElevatedButton.icon(onPressed: () => _showAdd(context),
                  icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Ajouter'),
                  style: ElevatedButton.styleFrom(backgroundColor: kBlue, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0)),
            ]),
            const SizedBox(height: 16),
            if (_fermes.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(40),
                child: Column(children: [
                  Text('🏡', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 12),
                  Text('Aucune ferme', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: kBlue)),
                  Text('Ajoutez votre première ferme !', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ]))),
            ..._fermes.map((f) => _fermeCard(f)),
          ])),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAdd(context),
          backgroundColor: kBlue, child: const Icon(Icons.add_rounded, color: Colors.white)),
    );
  }

  Widget _fermeCard(Map f) {
    final type = f['type_elevage'] ?? f['type'] ?? 'aviculture';
    final emoji = type == 'aviculture' ? '🐔' : type == 'bovins' ? '🐄' : type == 'ovins' ? '🐑' : '🏡';
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))]),
        child: Row(children: [
          Container(width: 50, height: 50,
              decoration: BoxDecoration(color: kBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26)))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(f['nom'] ?? 'Ferme sans nom', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on_rounded, size: 13, color: Colors.grey),
              const SizedBox(width: 4),
              Text(f['localisation'] ?? f['ville'] ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
            const SizedBox(height: 4),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: kBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(type, style: const TextStyle(color: kBlue, fontSize: 11, fontWeight: FontWeight.w600))),
          ])),
          IconButton(icon: const Icon(Icons.more_vert_rounded, color: Colors.grey), onPressed: () {}),
        ]));
  }

  void _showAdd(BuildContext context) {
    final nomCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    String typeSelected = 'aviculture';
    showModalBottomSheet(context: context, isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (ctx) => StatefulBuilder(builder: (ctx, setModalState) =>
            Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 24),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Nouvelle Ferme', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kBlue)),
                  const SizedBox(height: 16),
                  _field(nomCtrl, 'Nom de la ferme', Icons.agriculture_rounded),
                  const SizedBox(height: 10),
                  _field(locCtrl, 'Localisation / Ville', Icons.location_on_rounded),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(value: typeSelected,
                      decoration: InputDecoration(labelText: 'Type d\'élevage',
                          prefixIcon: const Icon(Icons.category_rounded, color: kBlueLight),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true, fillColor: const Color(0xFFF8FAFC)),
                      items: ['aviculture', 'bovins', 'ovins', 'porcins', 'mixte']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setModalState(() => typeSelected = v!)),
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity, height: 50,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _createFerme({
                              'nom': nomCtrl.text.trim(),
                              'localisation': locCtrl.text.trim(),
                              'type_elevage': typeSelected,
                              'proprietaire_id': SessionManager.entrepriseId,
                            });
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: kBlue, foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                          child: const Text('Créer', style: TextStyle(fontWeight: FontWeight.w700)))),
                  const SizedBox(height: 20),
                ]))));
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon) =>
      TextField(controller: ctrl,
          decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: kBlueLight, size: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true, fillColor: const Color(0xFFF8FAFC)));
}