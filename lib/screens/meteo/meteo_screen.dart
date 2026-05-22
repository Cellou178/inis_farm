import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../services/api_service.dart';

class MeteoScreen extends StatefulWidget {
  const MeteoScreen({super.key});
  @override
  State<MeteoScreen> createState() => _MeteoScreenState();
}

class _MeteoScreenState extends State<MeteoScreen> {
  final List<String> _villes = ['Mbour', 'Dakar', 'Thies', 'Rufisque', 'Pikine', 'Kaolack', 'Saint-Louis', 'Ziguinchor', 'Tambacounda'];
  Map<String, Map> _meteos = {};
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    Map<String, Map> result = {};
    for (final ville in _villes) {
      final m = await ApiService.getMeteo(ville);
      if (m.isNotEmpty) result[ville] = m;
    }
    setState(() { _meteos = result; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return _loading ? const Center(child: CircularProgressIndicator(color: kBlue)) :
    RefreshIndicator(onRefresh: _load, color: kBlue,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Météo Sénégal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kBlue)),
            IconButton(icon: const Icon(Icons.refresh_rounded, color: kBlue), onPressed: _load),
          ]),
          const SizedBox(height: 8),
          ..._meteos.entries.map((e) => _meteoCard(e.key, e.value)),
        ]));
  }

  Widget _meteoCard(String ville, Map data) {
    final temp = (data['main']?['temp'] ?? 0).toStringAsFixed(1);
    final humidity = data['main']?['humidity'] ?? 0;
    final desc = data['weather']?[0]?['description'] ?? '';
    final windSpeed = (data['wind']?['speed'] ?? 0).toStringAsFixed(1);
    final tempMax = (data['main']?['temp_max'] ?? 0).toStringAsFixed(0);
    final tempMin = (data['main']?['temp_min'] ?? 0).toStringAsFixed(0);
    final tempVal = double.tryParse(temp) ?? 0;
    final color = tempVal > 35 ? kRed : tempVal > 30 ? kOrange : kGreen;
    final icon = tempVal > 35 ? '🌡️' : tempVal > 28 ? '☀️' : humidity > 80 ? '🌧️' : '⛅';
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
        child: Row(children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 24)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ville, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 4),
            Row(children: [
              _chip('💧 $humidity%', Colors.blue), const SizedBox(width: 6),
              _chip('💨 ${windSpeed}m/s', Colors.grey), const SizedBox(width: 6),
              _chip('↕ $tempMin-$tempMax°', kOrange),
            ]),
          ])),
          Text('$temp°C', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: color)),
        ]));
  }

  Widget _chip(String text, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)));
}