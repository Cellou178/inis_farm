import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../managers/session_manager.dart';
import '../../services/api_service.dart';

class AddCycleScreen extends StatefulWidget {
  const AddCycleScreen({super.key});
  @override
  State<AddCycleScreen> createState() => _AddCycleScreenState();
}

class _AddCycleScreenState extends State<AddCycleScreen> {
  final _nomCtrl = TextEditingController();
  final _sujetsCtrl = TextEditingController();
  final _batCtrl = TextEditingController();
  final _soucheCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _nomCtrl.dispose(); _sujetsCtrl.dispose();
    _batCtrl.dispose(); _soucheCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nomCtrl.text.trim().isEmpty) { setState(() => _error = 'Nom obligatoire'); return; }
    if (_sujetsCtrl.text.trim().isEmpty) { setState(() => _error = 'Nombre de sujets obligatoire'); return; }
    setState(() { _loading = true; _error = ''; });
    final fermeId = SessionManager.fermeId.isNotEmpty ? SessionManager.fermeId : '11111111-1111-1111-1111-111111111111';
    final ok = await ApiService.createCycle({
      'ferme_id': fermeId,
      'nom': _nomCtrl.text.trim(),
      'date_debut': DateTime.now().toIso8601String().split('T')[0],
      'nombre_sujets': int.tryParse(_sujetsCtrl.text) ?? 0,
      'type_cycle': 'chair',
      'batiment': _batCtrl.text.trim(),
      'souche': _soucheCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
      'statut': 'en_cours',
    });
    setState(() => _loading = false);
    if (ok) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('✅ Cycle créé !', style: TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: kGreen, behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
    } else {
      setState(() => _error = 'Erreur lors de la création');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: kBlue, foregroundColor: Colors.white, elevation: 0,
          title: const Text('Nouveau Cycle', style: TextStyle(fontWeight: FontWeight.w800))),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Informations générales'),
        _field(_nomCtrl, 'Nom du cycle *', Icons.label_rounded),
        const SizedBox(height: 12),
        _field(_sujetsCtrl, 'Nombre de sujets *', Icons.pets_rounded, isNumber: true),
        const SizedBox(height: 12),
        _field(_batCtrl, 'Bâtiment', Icons.home_rounded),
        const SizedBox(height: 12),
        _field(_soucheCtrl, 'Souche (ex: Cobb 500)', Icons.science_rounded),
        const SizedBox(height: 20),
        _sectionTitle('Notes'),
        TextField(controller: _notesCtrl, maxLines: 3,
            decoration: InputDecoration(hintText: 'Observations, remarques...',
                prefixIcon: const Icon(Icons.notes_rounded, color: kBlueLight),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true, fillColor: const Color(0xFFF8FAFC))),
        if (_error.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200)),
              child: Row(children: [
                Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
                const SizedBox(width: 8),
                Text(_error, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
              ])),
        ],
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton(onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: kBlue, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                child: _loading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : const Text('Créer le cycle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)))),
      ])),
    );
  }

  Widget _sectionTitle(String title) => Padding(padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kBlue)));

  Widget _field(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false}) =>
      TextField(controller: ctrl, keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: kBlueLight, size: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBlue, width: 2)),
              filled: true, fillColor: const Color(0xFFF8FAFC)));
}