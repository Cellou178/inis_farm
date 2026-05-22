import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../../core/constants/app_constants.dart';
import '../../services/api_service.dart';

class GraphiquesScreen extends StatefulWidget {
  const GraphiquesScreen({super.key});
  @override
  State<GraphiquesScreen> createState() => _GraphiquesScreenState();
}

class _GraphiquesScreenState extends State<GraphiquesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List _cycles = [];
  List _donnees = [];
  String? _selectedCycleId;
  bool _loading = true;

  final Map<int, double> _cobbStandard = {1: 42, 7: 180, 14: 420, 21: 810, 28: 1280, 35: 1810, 42: 2520, 49: 3200};

  @override
  void initState() { super.initState(); _tabCtrl = TabController(length: 5, vsync: this); _load(); }
  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final cycles = await ApiService.getCycles();
    final donnees = await ApiService.getDonnees();
    setState(() {
      _cycles = cycles; _donnees = donnees;
      if (cycles.isNotEmpty && _selectedCycleId == null) _selectedCycleId = cycles.first['id'];
      _loading = false;
    });
  }

  List _donneesFiltered() => _selectedCycleId == null ? _donnees :
  _donnees.where((d) => d['cycle_id'] == _selectedCycleId).toList()
    ..sort((a, b) => (a['age_jours'] as int? ?? 0).compareTo(b['age_jours'] as int? ?? 0));

  double _gompertz(double age, double A, double b, double k) => A * exp(-b * exp(-k * age));

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: kBlue));
    final filtered = _donneesFiltered();
    return Column(children: [
      Container(color: kBlue, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DropdownButtonFormField<String>(
              value: _selectedCycleId, dropdownColor: kBlue, style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: 'Sélectionner un cycle', labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white30)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white30)),
                  filled: true, fillColor: Colors.white.withOpacity(0.1), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              items: _cycles.map((c) => DropdownMenuItem<String>(value: c['id'] as String,
                  child: Text(c['nom'] as String? ?? '', style: const TextStyle(color: Colors.white)))).toList(),
              onChanged: (v) => setState(() => _selectedCycleId = v))),
      Container(color: kBlue, child: TabBar(controller: _tabCtrl, isScrollable: true,
          labelColor: Colors.white, unselectedLabelColor: Colors.white54, indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          tabs: const [Tab(text: '📈 Poids'), Tab(text: '📉 GMQ'), Tab(text: '💀 Mortalité'), Tab(text: '🌾 Aliment'), Tab(text: '🔮 Gompertz')])),
      Expanded(child: TabBarView(controller: _tabCtrl, children: [
        _buildPoidsChart(filtered), _buildGMQChart(filtered),
        _buildMortaliteChart(filtered), _buildAlimentChart(filtered), _buildGompertzChart(filtered),
      ])),
    ]);
  }

  Widget _buildPoidsChart(List data) {
    if (data.isEmpty) return _emptyChart('Aucune donnée de poids');
    final spots = data.where((d) => (d['poids_moyen'] as num? ?? 0) > 0)
        .map((d) => FlSpot((d['age_jours'] as num).toDouble(), (d['poids_moyen'] as num).toDouble())).toList();
    final cobbSpots = _cobbStandard.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
    return _chartContainer('Poids Réel vs Standard COBB 500',
        LineChart(LineChartData(
            gridData: FlGridData(show: true, getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1)),
            titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text('J${v.toInt()}', style: const TextStyle(fontSize: 9)), reservedSize: 20)),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text('${v.toInt()}g', style: const TextStyle(fontSize: 9)), reservedSize: 40)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(spots: spots, isCurved: true, color: kBlue, barWidth: 3,
                  dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 4, color: kBlue, strokeWidth: 2, strokeColor: Colors.white))),
              LineChartBarData(spots: cobbSpots, isCurved: true, color: kOrange, barWidth: 2, dashArray: [6, 3], dotData: const FlDotData(show: false)),
            ])),
        legend: Row(mainAxisAlignment: MainAxisAlignment.center, children: [_legendItem(kBlue, 'Réel'), const SizedBox(width: 16), _legendItem(kOrange, 'Standard COBB')]));
  }

  Widget _buildGMQChart(List data) {
    if (data.length < 2) return _emptyChart('Pas assez de données pour le GMQ');
    final sorted = List.from(data)..sort((a, b) => (a['age_jours'] as int? ?? 0).compareTo(b['age_jours'] as int? ?? 0));
    List<BarChartGroupData> bars = [];
    for (int i = 1; i < sorted.length; i++) {
      final p1 = (sorted[i]['poids_moyen'] as num? ?? 0).toDouble();
      final p0 = (sorted[i-1]['poids_moyen'] as num? ?? 0).toDouble();
      final j = (sorted[i]['age_jours'] as int? ?? 1) - (sorted[i-1]['age_jours'] as int? ?? 0);
      if (j > 0 && p1 > 0 && p0 > 0) {
        final gmq = (p1 - p0) / j;
        bars.add(BarChartGroupData(x: sorted[i]['age_jours'] as int? ?? i,
            barRods: [BarChartRodData(toY: gmq, color: gmq > 50 ? kGreen : kOrange, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))]));
      }
    }
    return _chartContainer('GMQ — Gain Moyen Quotidien (g/j)',
        BarChart(BarChartData(
            gridData: FlGridData(show: true, getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1)),
            titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text('J${v.toInt()}', style: const TextStyle(fontSize: 9)), reservedSize: 20)),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text('${v.toInt()}g', style: const TextStyle(fontSize: 9)), reservedSize: 35)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
            borderData: FlBorderData(show: false), barGroups: bars)));
  }

  Widget _buildMortaliteChart(List data) {
    if (data.isEmpty) return _emptyChart('Aucune donnée de mortalité');
    final sorted = List.from(data)..sort((a, b) => (a['age_jours'] as int? ?? 0).compareTo(b['age_jours'] as int? ?? 0));
    int cumul = 0;
    final spots = sorted.map((d) { cumul += (d['mortalite'] as int? ?? 0); return FlSpot((d['age_jours'] as num).toDouble(), cumul.toDouble()); }).toList();
    return _chartContainer('Mortalité Cumulée',
        LineChart(LineChartData(
            gridData: FlGridData(show: true, getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1)),
            titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text('J${v.toInt()}', style: const TextStyle(fontSize: 9)), reservedSize: 20)),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 9)), reservedSize: 30)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
            borderData: FlBorderData(show: false),
            lineBarsData: [LineChartBarData(spots: spots, isCurved: true, color: kRed, barWidth: 3,
                belowBarData: BarAreaData(show: true, color: kRed.withOpacity(0.1)),
                dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 3, color: kRed, strokeWidth: 1, strokeColor: Colors.white)))])));
  }

  Widget _buildAlimentChart(List data) {
    if (data.isEmpty) return _emptyChart('Aucune donnée d\'alimentation');
    final sorted = List.from(data.where((d) => (d['consommation_aliment'] as num? ?? 0) > 0))
      ..sort((a, b) => (a['age_jours'] as int? ?? 0).compareTo(b['age_jours'] as int? ?? 0));
    if (sorted.isEmpty) return _emptyChart('Aucune donnée d\'alimentation');
    final bars = sorted.map((d) => BarChartGroupData(x: d['age_jours'] as int? ?? 0,
        barRods: [BarChartRodData(toY: (d['consommation_aliment'] as num).toDouble(), color: kGreen, width: 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))])).toList();
    return _chartContainer('Consommation Aliment (kg/j)',
        BarChart(BarChartData(
            gridData: FlGridData(show: true, getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1)),
            titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text('J${v.toInt()}', style: const TextStyle(fontSize: 9)), reservedSize: 20)),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text('${v.toInt()}kg', style: const TextStyle(fontSize: 9)), reservedSize: 40)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
            borderData: FlBorderData(show: false), barGroups: bars)));
  }

  Widget _buildGompertzChart(List data) {
    if (data.length < 3) return _emptyChart('Pas assez de données (min. 3)');
    final sorted = List.from(data.where((d) => (d['poids_moyen'] as num? ?? 0) > 0))
      ..sort((a, b) => (a['age_jours'] as int? ?? 0).compareTo(b['age_jours'] as int? ?? 0));
    if (sorted.isEmpty) return _emptyChart('Aucune donnée de poids');
    final lastAge = (sorted.last['age_jours'] as int? ?? 42).toDouble();
    final A = (sorted.last['poids_moyen'] as num? ?? 0).toDouble() * 1.3;
    const b = 3.0; const k = 0.08;
    final realSpots = sorted.map((d) => FlSpot((d['age_jours'] as num).toDouble(), (d['poids_moyen'] as num).toDouble())).toList();
    final predSpots = List.generate(20, (i) { final age = lastAge + (i + 1) * 3; return FlSpot(age, _gompertz(age, A, b, k)); });
    final poidsPredit = _gompertz(lastAge + 15, A, b, k);
    return _chartContainer('Modèle Gompertz — Prédiction Poids',
        LineChart(LineChartData(
            gridData: FlGridData(show: true, getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1)),
            titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text('J${v.toInt()}', style: const TextStyle(fontSize: 9)), reservedSize: 20)),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text('${v.toInt()}g', style: const TextStyle(fontSize: 9)), reservedSize: 40)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(spots: realSpots, isCurved: true, color: kBlue, barWidth: 3,
                  dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 4, color: kBlue, strokeWidth: 2, strokeColor: Colors.white))),
              LineChartBarData(spots: [...realSpots.sublist(realSpots.length - 1), ...predSpots], isCurved: true, color: kPurple, barWidth: 2, dashArray: [6, 3], dotData: const FlDotData(show: false)),
            ])),
        extra: Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: kPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('🔮 Poids prédit J+15 : ', style: TextStyle(fontWeight: FontWeight.w700, color: kPurple)),
              Text('${poidsPredit.toStringAsFixed(0)}g', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: kPurple)),
            ])),
        legend: Row(mainAxisAlignment: MainAxisAlignment.center, children: [_legendItem(kBlue, 'Réel'), const SizedBox(width: 16), _legendItem(kPurple, 'Prédiction')]));
  }

  Widget _chartContainer(String title, Widget chart, {Widget? legend, Widget? extra}) =>
      SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: kBlue)),
        const SizedBox(height: 16),
        Container(height: 250, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]), child: chart),
        if (legend != null) ...[const SizedBox(height: 12), legend],
        if (extra != null) extra,
      ]));

  Widget _legendItem(Color color, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 16, height: 3, color: color), const SizedBox(width: 6),
    Text(label, style: const TextStyle(fontSize: 12))]);

  Widget _emptyChart(String msg) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Text('📊', style: TextStyle(fontSize: 48)), const SizedBox(height: 12),
    Text(msg, style: const TextStyle(color: Colors.grey, fontSize: 14))]));
}