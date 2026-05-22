import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../services/api_service.dart';

class EmployesScreen extends StatefulWidget {
  const EmployesScreen({super.key});
  @override
  State<EmployesScreen> createState() => _EmployesScreenState();
}

class _EmployesScreenState extends State<EmployesScreen> {
  List _employes = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final e = await ApiService.getEmployes();
    setState(() { _employes = e; _loading = false; });
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
                const Text('Employés', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kBlue)),
                Text('${_employes.length} employé(s)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ]),
              ElevatedButton.icon(onPressed: () => _showAdd(context),
                  icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Ajouter'),
                  style: ElevatedButton.styleFrom(backgroundColor: kBlue, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0)),
            ]),
            const SizedBox(height: 16),
            if (_employes.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(40),
                child: Column(children: [
                  Text('👥', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 12),
                  Text('Aucun employé', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: kBlue)),
                  Text('Ajoutez votre premier employé !', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ]))),
            ..._employes.map((e) => _employeCard(e)),
          ])),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAdd(context),
          backgroundColor: kBlue, child: const Icon(Icons.add_rounded, color: Colors.white)),
    );
  }

  Widget _employeCard(Map e) {
    final poste = e['poste'] ?? e['role'] ?? 'Employé';
    final salaire = (e['salaire'] as num? ?? 0).toDouble();
    final color = poste == 'manager' || poste == 'admin' ? kPurple : kBlue;
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
        child: Row(children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.15), radius: 24,
              child: Text((e['nom'] as String? ?? 'E').substring(0, 1).toUpperCase(),
                  style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e['nom'] ?? 'Sans nom', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            Text(poste, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            if (e['telephone'] != null)
              Text('📞 ${e['telephone']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ])),
          if (salaire > 0) Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${salaire.toStringAsFixed(0)} FCFA', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: kGreen)),
            const Text('/ mois', style: TextStyle(color: Colors.grey, fontSize: 10)),
          ]),
        ]));
  }

  void _showAdd(BuildContext context) {
    final nomCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    final salaireCtrl = TextEditingController();
    String posteSelected = 'employe';
    showModalBottomSheet(context: context, isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (ctx) => StatefulBuilder(builder: (ctx, setModalState) =>
            Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 24),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Nouvel Employé', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kBlue)),
                  const SizedBox(height: 16),
                  _field(nomCtrl, 'Nom complet', Icons.person_rounded),
                  const SizedBox(height: 10),
                  _field(telCtrl, 'Téléphone', Icons.phone_rounded, isPhone: true),
                  const SizedBox(height: 10),
                  _field(salaireCtrl, 'Salaire mensuel (FCFA)', Icons.attach_money_rounded, isNumber: true),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(value: posteSelected,
                      decoration: InputDecoration(labelText: 'Poste',
                          prefixIcon: const Icon(Icons.work_rounded, color: kBlueLight),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true, fillColor: const Color(0xFFF8FAFC)),
                      items: ['employe', 'manager', 'veterinaire', 'chauffeur', 'gardien']
                          .map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (v) => setModalState(() => posteSelected = v!)),
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity, height: 50,
                      child: ElevatedButton(
                          onPressed: () async {
                            final ok = await ApiService.createEmploye({
                              'nom': nomCtrl.text.trim(),
                              'telephone': telCtrl.text.trim(),
                              'salaire': double.tryParse(salaireCtrl.text) ?? 0,
                              'poste': posteSelected,
                              'ferme_id': '11111111-1111-1111-1111-111111111111',
                            });
                            Navigator.pop(context);
                            if (ok) { _load(); _snack('✅ Employé ajouté !', kGreen); }
                            else { _snack('❌ Erreur', kRed); }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: kBlue, foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                          child: const Text('Ajouter', style: TextStyle(fontWeight: FontWeight.w700)))),
                  const SizedBox(height: 20),
                ]))));
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false, bool isPhone = false}) =>
      TextField(controller: ctrl,
          keyboardType: isNumber ? TextInputType.number : isPhone ? TextInputType.phone : TextInputType.text,
          decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: kBlueLight, size: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true, fillColor: const Color(0xFFF8FAFC)));
}