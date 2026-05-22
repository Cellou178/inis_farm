import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'screens/dashboard/dashboard_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionManager.init();
  runApp(const KewereApp());
}

const String API_URL = 'https://kewere-aissa-smart.onrender.com';
const String WEATHER_KEY = 'cea65cf01b5c5db78e93a83d09cbf66c';
const Color kBlue = Color(0xFF1B3A6B);
const Color kBlueLight = Color(0xFF2563EB);
const Color kGreen = Color(0xFF16A34A);
const Color kOrange = Color(0xFFEA580C);
const Color kRed = Color(0xFFDC2626);
const Color kPurple = Color(0xFF7C3AED);
const Color kBg = Color(0xFFF1F5F9);
const Color kCard = Colors.white;

// ══════════════════════════════════════════
// FINANCE PARAMS
// ══════════════════════════════════════════
class FinanceParams {
  static double prixSacAliment = 17600;
  static double prixVentePoulet = 2500;
  static double prixPoussin = 645;
  static double salairesMois = 445000;
  static double loyerMois = 200000;
  static double coutMedicalParPoussin = 115;
}

// ══════════════════════════════════════════
// SESSION MANAGER — stockage persistant
// ══════════════════════════════════════════
class SessionManager {
  static String _token = '';
  static String _role = '';
  static String _nom = '';
  static String _email = '';
  static String _entrepriseId = '';
  static String _fermeId = '';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    _role = prefs.getString('role') ?? '';
    _nom = prefs.getString('nom') ?? '';
    _email = prefs.getString('email') ?? '';
    _entrepriseId = prefs.getString('entreprise_id') ?? '';
    _fermeId = prefs.getString('ferme_id') ?? '';
  }

  static Future<void> save({
    required String token,
    required String role,
    required String nom,
    required String email,
    required String entrepriseId,
    String fermeId = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('role', role);
    await prefs.setString('nom', nom);
    await prefs.setString('email', email);
    await prefs.setString('entreprise_id', entrepriseId);
    await prefs.setString('ferme_id', fermeId);
    _token = token;
    _role = role;
    _nom = nom;
    _email = email;
    _entrepriseId = entrepriseId;
    _fermeId = fermeId;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _token = '';
    _role = '';
    _nom = '';
    _email = '';
    _entrepriseId = '';
    _fermeId = '';
  }

  static bool get isLoggedIn => _token.isNotEmpty;
  static String get token => _token;
  static String get role => _role;
  static String get nom => _nom;
  static String get email => _email;
  static String get entrepriseId => _entrepriseId;
  static String get fermeId => _fermeId;
  static bool get isAdmin => _role == 'admin';
  static bool get isProprietaire => _role == 'proprietaire';

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
  };
}

// ══════════════════════════════════════════
// API SERVICE
// ══════════════════════════════════════════
class ApiService {
  static const Duration _timeout = Duration(seconds: 15);

  static Future<List> getCycles() async {
    try {
      final r = await http.get(Uri.parse('$API_URL/cycles/'), headers: SessionManager.headers).timeout(_timeout);
      if (r.statusCode == 200) return jsonDecode(r.body);
    } catch (e) { debugPrint('getCycles: $e'); }
    return [];
  }

  static Future<List> getDonnees({String? cycleId}) async {
    try {
      String url = '$API_URL/donnees/';
      if (cycleId != null) url += '?cycle_id=$cycleId';
      final r = await http.get(Uri.parse(url), headers: SessionManager.headers).timeout(_timeout);
      if (r.statusCode == 200) return jsonDecode(r.body);
    } catch (e) { debugPrint('getDonnees: $e'); }
    return [];
  }

  static Future<List> getStocks() async {
    try {
      final r = await http.get(Uri.parse('$API_URL/stocks/'), headers: SessionManager.headers).timeout(_timeout);
      if (r.statusCode == 200) return jsonDecode(r.body);
    } catch (e) { debugPrint('getStocks: $e'); }
    return [];
  }

  static Future<List> getEmployes() async {
    try {
      final r = await http.get(Uri.parse('$API_URL/employes/'), headers: SessionManager.headers).timeout(_timeout);
      if (r.statusCode == 200) return jsonDecode(r.body);
    } catch (e) { debugPrint('getEmployes: $e'); }
    return [];
  }

  static Future<List> getAlertes() async {
    try {
      final r = await http.get(Uri.parse('$API_URL/dashboard/alertes'), headers: SessionManager.headers).timeout(_timeout);
      if (r.statusCode == 200) return jsonDecode(r.body);
    } catch (e) { debugPrint('getAlertes: $e'); }
    return [];
  }

  static Future<Map<String, dynamic>> getMeteo(String ville) async {
    try {
      final r = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$ville,SN&appid=$WEATHER_KEY&units=metric&lang=fr'
      )).timeout(_timeout);
      if (r.statusCode == 200) return jsonDecode(r.body);
    } catch (e) { debugPrint('getMeteo: $e'); }
    return {};
  }

  static Future<Map<String, dynamic>> getMe() async {
    try {
      final r = await http.get(Uri.parse('$API_URL/auth/me'), headers: SessionManager.headers).timeout(_timeout);
      if (r.statusCode == 200) return jsonDecode(r.body);
    } catch (e) { debugPrint('getMe: $e'); }
    return {};
  }

  static Future<bool> createDonnee(Map<String, dynamic> data) async {
    try {
      final r = await http.post(Uri.parse('$API_URL/donnees/'), headers: SessionManager.headers, body: jsonEncode(data)).timeout(_timeout);
      return r.statusCode == 201 || r.statusCode == 200;
    } catch (e) { debugPrint('createDonnee: $e'); }
    return false;
  }

  static Future<bool> createCycle(Map<String, dynamic> data) async {
    try {
      final r = await http.post(Uri.parse('$API_URL/cycles/'), headers: SessionManager.headers, body: jsonEncode(data)).timeout(_timeout);
      return r.statusCode == 201 || r.statusCode == 200;
    } catch (e) { debugPrint('createCycle: $e'); }
    return false;
  }

  static Future<bool> createStock(Map<String, dynamic> data) async {
    try {
      final r = await http.post(Uri.parse('$API_URL/stocks/'), headers: SessionManager.headers, body: jsonEncode(data)).timeout(_timeout);
      return r.statusCode == 201 || r.statusCode == 200;
    } catch (e) { debugPrint('createStock: $e'); }
    return false;
  }

  static Future<bool> createEmploye(Map<String, dynamic> data) async {
    try {
      final r = await http.post(Uri.parse('$API_URL/employes/'), headers: SessionManager.headers, body: jsonEncode(data)).timeout(_timeout);
      return r.statusCode == 201 || r.statusCode == 200;
    } catch (e) { debugPrint('createEmploye: $e'); }
    return false;
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final r = await http.post(Uri.parse('$API_URL/auth/register'),
          headers: {'Content-Type': 'application/json'}, body: jsonEncode(data)).timeout(_timeout);
      return {'status': r.statusCode, 'body': jsonDecode(r.body)};
    } catch (e) { debugPrint('register: $e'); }
    return {'status': 500, 'body': {}};
  }
}

// ══════════════════════════════════════════
// APP
// ══════════════════════════════════════════
class KewereApp extends StatelessWidget {
  const KewereApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kewere Aissa Smart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: kBlue), fontFamily: 'Roboto', scaffoldBackgroundColor: kBg, useMaterial3: true),
      home: SessionManager.isLoggedIn ? const DashboardPage() : const SplashScreen(),
    );
  }
}

// ══════════════════════════════════════════
// SPLASH
// ══════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F172A), Color(0xFF1E3A5F), Color(0xFF166534)])),
        child: FadeTransition(opacity: _fade, child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(24)), child: const Center(child: Text('🐔', style: TextStyle(fontSize: 52)))),
          const SizedBox(height: 24),
          const Text('Kewere Aissa Smart', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)), child: const Text('Ferme Avicole Intelligente', style: TextStyle(color: Colors.white70, fontSize: 13))),
          const SizedBox(height: 8),
          const Text('Sénégal 🇸🇳', style: TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 60),
          const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)),
        ]))),
      ),
    );
  }
}

// ══════════════════════════════════════════
// LOGIN
// ══════════════════════════════════════════
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
  void dispose() {
    _loginCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool _isValid() {
    if (_loginCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Entrez votre email ou numéro'); return false;
    }
    if (_passCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Entrez votre mot de passe'); return false;
    }
    return true;
  }

  Future<void> _login() async {
    if (!_isValid()) return;
    setState(() { _loading = true; _error = ''; });
    try {
      final r = await http.post(Uri.parse('$API_URL/auth/login'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {'username': _loginCtrl.text.trim(), 'password': _passCtrl.text}).timeout(const Duration(seconds: 15));
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        final token = data['access_token'] ?? '';
        // Récupérer les infos du profil
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
      debugPrint('Login error: $e');
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
          Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Connexion', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kBlue)),
                const SizedBox(height: 4),
                const Text('Email ou numéro de téléphone', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 24),
                // Champ login universel
                TextField(
                    controller: _loginCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        labelText: 'Email ou téléphone',
                        hintText: 'ex: nom@email.com ou +221xxxxxxxx',
                        prefixIcon: const Icon(Icons.person_outline, color: kBlueLight),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBlue, width: 2)),
                        filled: true, fillColor: const Color(0xFFF8FAFC))),
                const SizedBox(height: 16),
                TextField(controller: _passCtrl, obscureText: !_showPass,
                    decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: const Icon(Icons.lock_outline, color: kBlueLight),
                        suffixIcon: IconButton(icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: () => setState(() => _showPass = !_showPass)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBlue, width: 2)),
                        filled: true, fillColor: const Color(0xFFF8FAFC))),
                if (_error.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.shade200)),
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

// ══════════════════════════════════════════
// REGISTER
// ══════════════════════════════════════════
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
  final _fermeCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();
  bool _loading = false;
  String _error = '';
  bool _showPass = false;

  @override
  void dispose() {
    _nomCtrl.dispose(); _emailCtrl.dispose(); _telCtrl.dispose();
    _passCtrl.dispose(); _fermeCtrl.dispose(); _villeCtrl.dispose();
    super.dispose();
  }

  bool _isValid() {
    if (_nomCtrl.text.trim().isEmpty) { setState(() => _error = 'Nom obligatoire'); return false; }
    if (_emailCtrl.text.trim().isEmpty) { setState(() => _error = 'Email obligatoire'); return false; }
    if (!_emailCtrl.text.contains('@')) { setState(() => _error = 'Email invalide'); return false; }
    if (_passCtrl.text.length < 6) { setState(() => _error = 'Mot de passe min. 6 caractères'); return false; }
    return true;
  }

  Future<void> _register() async {
    if (!_isValid()) return;
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
        final detail = result['body']['detail'] ?? 'Erreur lors de la création';
        setState(() => _error = detail.toString());
      }
    } catch (e) {
      debugPrint('Register error: $e');
      setState(() => _error = 'Erreur de connexion');
    }
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
          Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Nouveau partenaire', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kBlue)),
                const SizedBox(height: 4),
                const Text('Créez votre compte ferme avicole', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 24),
                _field(_nomCtrl, 'Nom complet *', Icons.person_rounded),
                const SizedBox(height: 12),
                _field(_emailCtrl, 'Email *', Icons.email_rounded, isEmail: true),
                const SizedBox(height: 12),
                _field(_telCtrl, 'Téléphone (WhatsApp)', Icons.phone_rounded, isPhone: true),
                const SizedBox(height: 12),
                TextField(controller: _passCtrl, obscureText: !_showPass,
                    decoration: InputDecoration(
                        labelText: 'Mot de passe * (min. 6 caractères)',
                        prefixIcon: const Icon(Icons.lock_outline, color: kBlueLight),
                        suffixIcon: IconButton(icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _showPass = !_showPass)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBlue, width: 2)),
                        filled: true, fillColor: const Color(0xFFF8FAFC))),
                const SizedBox(height: 12),
                _field(_fermeCtrl, 'Nom de la ferme', Icons.agriculture_rounded),
                const SizedBox(height: 12),
                _field(_villeCtrl, 'Ville / Localité', Icons.location_on_rounded),
                if (_error.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.shade200)),
                      child: Row(children: [Icon(Icons.error_outline, color: Colors.red.shade600, size: 18), const SizedBox(width: 8), Expanded(child: Text(_error, style: TextStyle(color: Colors.red.shade700, fontSize: 13)))])),
                ],
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, height: 52,
                    child: ElevatedButton(onPressed: _loading ? null : _register,
                        style: ElevatedButton.styleFrom(backgroundColor: kGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                        child: _loading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('Créer mon compte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)))),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Déjà un compte ?', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Se connecter', style: TextStyle(color: kBlue, fontWeight: FontWeight.w700))),
                ]),
              ])),
        ]))),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, {bool isEmail = false, bool isPhone = false}) => TextField(
      controller: ctrl,
      keyboardType: isEmail ? TextInputType.emailAddress : isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: kBlueLight),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBlue, width: 2)),
          filled: true, fillColor: const Color(0xFFF8FAFC)));
}

// ══════════════════════════════════════════
// HOME
// ══════════════════════════════════════════
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [
    DashboardPage(), CyclesPage(), GraphiquesPage(),
    FinancePage(), MeteoPage(), AlertesPage(), ProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBlue, elevation: 0,
        title: const Row(children: [
          Text('🐔', style: TextStyle(fontSize: 22)),
          SizedBox(width: 10),
          Text('Kewere Aissa Smart', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        ]),
        actions: [
          Container(margin: const EdgeInsets.only(right: 16), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                const CircleAvatar(radius: 4, backgroundColor: Colors.greenAccent),
                const SizedBox(width: 5),
                Text(SessionManager.role.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
              ])),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))]),
        child: BottomNavigationBar(
          currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed, selectedItemColor: kBlue, unselectedItemColor: Colors.grey.shade400,
          selectedFontSize: 10, unselectedFontSize: 9, backgroundColor: Colors.transparent, elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.loop_rounded), label: 'Cycles'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Graphiques'),
            BottomNavigationBarItem(icon: Icon(Icons.attach_money_rounded), label: 'Finance'),
            BottomNavigationBarItem(icon: Icon(Icons.cloud_rounded), label: 'Météo'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Alertes'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
// DASHBOARD
// ══════════════════════════════════════════
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List _cycles = [];
  List _donnees = [];
  Map _meteo = {};
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final cycles = await ApiService.getCycles();
    final donnees = await ApiService.getDonnees();
    final meteo = await ApiService.getMeteo('Mbour');
    setState(() { _cycles = cycles; _donnees = donnees; _meteo = meteo; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: kBlue));
    final cyclesActifs = _cycles.where((c) => c['statut'] == 'en_cours').length;
    final totalPoulets = _cycles.fold(0, (sum, c) => sum + (c['nombre_sujets'] as int? ?? 0));
    final dernierPoids = _donnees.isNotEmpty ? (_donnees.last['poids_moyen'] ?? 0) : 0;
    final totalMorts = _donnees.fold(0, (sum, d) => sum + (d['mortalite'] as int? ?? 0));

    return RefreshIndicator(onRefresh: _load, color: kBlue,
        child: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: double.infinity, padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [kBlue, Color(0xFF2563EB)]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: kBlue.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))]),
                  child: Row(children: [
                    Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)), child: const Center(child: Text('🏡', style: TextStyle(fontSize: 26)))),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(SessionManager.nom.isNotEmpty ? SessionManager.nom : 'Ferme Inis', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                      Text('$cyclesActifs cycle(s) actif(s) • ${SessionManager.role}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ])),
                    if (_meteo.isNotEmpty) Column(children: [
                      Text('${(_meteo['main']?['temp'] ?? 0).toStringAsFixed(0)}°C', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                      Text(_meteo['weather']?[0]?['description'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                    ]),
                    IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.white), onPressed: _load),
                  ])),
              const SizedBox(height: 16),
              GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
                  children: [
                    _kpi('🐔', '$totalPoulets', 'Poulets total', kBlue, const Color(0xFFEFF6FF)),
                    _kpi('🔄', '$cyclesActifs', 'Cycles actifs', kGreen, const Color(0xFFF0FDF4)),
                    _kpi('⚖️', '${dernierPoids}g', 'Dernier poids', kPurple, const Color(0xFFF5F3FF)),
                    _kpi('💀', '$totalMorts', 'Total morts', kRed, const Color(0xFFFEF2F2)),
                  ]),
              const SizedBox(height: 16),
              if (_cycles.isNotEmpty) ...[
                _sectionTitle('🔄 CYCLES RÉCENTS'),
                ..._cycles.take(3).map((c) => _cycleItem(c)),
              ],
              if (_donnees.isNotEmpty) ...[
                const SizedBox(height: 8),
                _sectionTitle('📊 DERNIÈRES DONNÉES'),
                ..._donnees.reversed.take(3).map((d) => _donneeItem(d)),
              ],
            ])));
  }

  Widget _kpi(String icon, String value, String label, Color color, Color bg) => Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(icon, style: const TextStyle(fontSize: 22)), const Spacer(),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: TextStyle(fontSize: 11, color: color.withOpacity(0.7))),
      ]));

  Widget _sectionTitle(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1a7a9a), letterSpacing: 0.5)));

  Widget _cycleItem(Map c) {
    final statut = c['statut'] ?? '';
    final color = statut == 'en_cours' ? kGreen : Colors.grey;
    return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
        child: Row(children: [
          Text(statut == 'en_cours' ? '🐔' : '✅', style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c['nom'] ?? 'Cycle sans nom', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text('${c['nombre_sujets'] ?? 0} sujets', style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(statut, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700))),
        ]));
  }

  Widget _donneeItem(Map d) {
    final mortalite = d['mortalite'] as int? ?? 0;
    final color = mortalite > 10 ? kRed : mortalite > 5 ? kOrange : kGreen;
    return Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(10), border: Border(left: BorderSide(color: color, width: 3))),
        child: Row(children: [
          Text('J${d['age_jours'] ?? '-'}', style: TextStyle(fontWeight: FontWeight.w800, color: color)),
          const SizedBox(width: 10),
          Text('${d['poids_moyen'] ?? 0}g', style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text('💀 $mortalite', style: TextStyle(color: color, fontSize: 12)),
        ]));
  }
}

// ══════════════════════════════════════════
// CYCLES
// ══════════════════════════════════════════
class CyclesPage extends StatefulWidget {
  const CyclesPage({super.key});
  @override
  State<CyclesPage> createState() => _CyclesPageState();
}

class _CyclesPageState extends State<CyclesPage> {
  List _cycles = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() => _loading = true);
    final c = await ApiService.getCycles();
    setState(() { _cycles = c; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _loading ? const Center(child: CircularProgressIndicator(color: kBlue)) :
    RefreshIndicator(onRefresh: _load, color: kBlue,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Mes Cycles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kBlue)),
              Text('${_cycles.length} cycle(s)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
            if (SessionManager.isProprietaire || SessionManager.isAdmin)
              ElevatedButton.icon(onPressed: () => _showAdd(context), icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Nouveau'),
                  style: ElevatedButton.styleFrom(backgroundColor: kBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0)),
          ]),
          const SizedBox(height: 16),
          if (_cycles.isEmpty) _empty('Aucun cycle', 'Créez votre premier cycle !', '🐔'),
          ..._cycles.map((c) => _card(c)),
        ])));
  }

  Widget _card(Map c) {
    final statut = c['statut'] ?? '';
    final color = statut == 'en_cours' ? kGreen : statut == 'terminé' ? Colors.blueGrey : kOrange;
    return Container(margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))]),
        child: Column(children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: color.withOpacity(0.06), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(statut == 'en_cours' ? '🐔' : '✅', style: const TextStyle(fontSize: 20)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c['nom'] ?? 'Cycle sans nom', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  Text('${c['souche'] ?? '-'} • Bâtiment ${c['batiment'] ?? '-'}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                    child: Text(statut, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700))),
              ])),
          Padding(padding: const EdgeInsets.all(12),
              child: Row(children: [
                _chip(Icons.pets_rounded, '${c['nombre_sujets'] ?? 0} sujets', kBlue),
                const SizedBox(width: 8),
                _chip(Icons.calendar_today_rounded, c['date_debut'] ?? '-', kGreen),
              ])),
        ]));
  }

  Widget _chip(IconData icon, String text, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 11, color: color), const SizedBox(width: 3), Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600))]));

  void _showAdd(BuildContext context) {
    final nomCtrl = TextEditingController();
    final sujetsCtrl = TextEditingController();
    final batCtrl = TextEditingController();
    final soucheCtrl = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Nouveau Cycle', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kBlue)),
              const SizedBox(height: 16),
              _field(nomCtrl, 'Nom du cycle', Icons.label_rounded),
              const SizedBox(height: 10),
              _field(sujetsCtrl, 'Nombre de sujets', Icons.pets_rounded, isNumber: true),
              const SizedBox(height: 10),
              _field(batCtrl, 'Bâtiment', Icons.home_rounded),
              const SizedBox(height: 10),
              _field(soucheCtrl, 'Souche', Icons.science_rounded),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, height: 50,
                  child: ElevatedButton(onPressed: () async {
                    final fermeId = SessionManager.fermeId.isNotEmpty ? SessionManager.fermeId : '11111111-1111-1111-1111-111111111111';
                    final ok = await ApiService.createCycle({'ferme_id': fermeId, 'nom': nomCtrl.text, 'date_debut': DateTime.now().toIso8601String().split('T')[0], 'nombre_sujets': int.tryParse(sujetsCtrl.text) ?? 0, 'type_cycle': 'chair', 'batiment': batCtrl.text, 'souche': soucheCtrl.text, 'statut': 'en_cours'});
                    Navigator.pop(context);
                    if (ok) { _load(); _snack(context, '✅ Cycle créé !', kGreen); }
                    else { _snack(context, '❌ Erreur création cycle', kRed); }
                  }, style: ElevatedButton.styleFrom(backgroundColor: kBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                      child: const Text('Créer', style: TextStyle(fontWeight: FontWeight.w700)))),
              const SizedBox(height: 20),
            ])));
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false}) => TextField(
      controller: ctrl, keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: kBlueLight, size: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), filled: true, fillColor: const Color(0xFFF8FAFC), contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12)));
}

// ══════════════════════════════════════════
// GRAPHIQUES
// ══════════════════════════════════════════
class GraphiquesPage extends StatefulWidget {
  const GraphiquesPage({super.key});
  @override
  State<GraphiquesPage> createState() => _GraphiquesPageState();
}

class _GraphiquesPageState extends State<GraphiquesPage> with SingleTickerProviderStateMixin {
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

  List _donneesFiltered() => _selectedCycleId == null ? _donnees : _donnees.where((d) => d['cycle_id'] == _selectedCycleId).toList()..sort((a, b) => (a['age_jours'] as int? ?? 0).compareTo(b['age_jours'] as int? ?? 0));
  double _gompertz(double age, double A, double b, double k) => A * exp(-b * exp(-k * age));

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: kBlue));
    final filtered = _donneesFiltered();
    return Scaffold(body: Column(children: [
      Container(color: kBlue, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DropdownButtonFormField<String>(value: _selectedCycleId, dropdownColor: kBlue, style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: 'Sélectionner un cycle', labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white30)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white30)),
                  filled: true, fillColor: Colors.white.withOpacity(0.1), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              items: _cycles.map((c) => DropdownMenuItem<String>(value: c['id'] as String, child: Text(c['nom'] as String? ?? '', style: const TextStyle(color: Colors.white)))).toList(),
              onChanged: (v) => setState(() => _selectedCycleId = v))),
      Container(color: kBlue, child: TabBar(controller: _tabCtrl, isScrollable: true, labelColor: Colors.white, unselectedLabelColor: Colors.white54, indicatorColor: Colors.white, labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          tabs: const [Tab(text: '📈 Poids'), Tab(text: '📉 GMQ'), Tab(text: '💀 Mortalité'), Tab(text: '🌾 Aliment'), Tab(text: '🔮 Gompertz')])),
      Expanded(child: TabBarView(controller: _tabCtrl, children: [
        _buildPoidsChart(filtered), _buildGMQChart(filtered), _buildMortaliteChart(filtered), _buildAlimentChart(filtered), _buildGompertzChart(filtered),
      ])),
    ]));
  }

  Widget _buildPoidsChart(List data) {
    if (data.isEmpty) return _emptyChart('Aucune donnée de poids');
    final spots = data.where((d) => (d['poids_moyen'] as num? ?? 0) > 0).map((d) => FlSpot((d['age_jours'] as num).toDouble(), (d['poids_moyen'] as num).toDouble())).toList();
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
              LineChartBarData(spots: spots, isCurved: true, color: kBlue, barWidth: 3, dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 4, color: kBlue, strokeWidth: 2, strokeColor: Colors.white))),
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
        bars.add(BarChartGroupData(x: sorted[i]['age_jours'] as int? ?? i, barRods: [BarChartRodData(toY: gmq, color: gmq > 50 ? kGreen : kOrange, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))]));
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
    final sorted = List.from(data.where((d) => (d['consommation_aliment'] as num? ?? 0) > 0))..sort((a, b) => (a['age_jours'] as int? ?? 0).compareTo(b['age_jours'] as int? ?? 0));
    if (sorted.isEmpty) return _emptyChart('Aucune donnée d\'alimentation');
    final bars = sorted.map((d) => BarChartGroupData(x: d['age_jours'] as int? ?? 0,
        barRods: [BarChartRodData(toY: (d['consommation_aliment'] as num).toDouble(), color: kGreen, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))])).toList();
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
    if (data.length < 3) return _emptyChart('Pas assez de données pour Gompertz (min. 3)');
    final sorted = List.from(data.where((d) => (d['poids_moyen'] as num? ?? 0) > 0))..sort((a, b) => (a['age_jours'] as int? ?? 0).compareTo(b['age_jours'] as int? ?? 0));
    if (sorted.isEmpty) return _emptyChart('Aucune donnée de poids');
    final lastAge = (sorted.last['age_jours'] as int? ?? 42).toDouble();
    final lastPoids = (sorted.last['poids_moyen'] as num? ?? 0).toDouble();
    final A = lastPoids * 1.3; const b = 3.0; const k = 0.08;
    final realSpots = sorted.map((d) => FlSpot((d['age_jours'] as num).toDouble(), (d['poids_moyen'] as num).toDouble())).toList();
    final predSpots = List.generate(20, (i) { final age = lastAge + (i + 1) * 3; return FlSpot(age, _gompertz(age, A, b, k)); });
    final allPredSpots = [...realSpots, ...predSpots];
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
              LineChartBarData(spots: realSpots, isCurved: true, color: kBlue, barWidth: 3, dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 4, color: kBlue, strokeWidth: 2, strokeColor: Colors.white))),
              LineChartBarData(spots: allPredSpots.sublist(realSpots.length - 1), isCurved: true, color: kPurple, barWidth: 2, dashArray: [6, 3], dotData: const FlDotData(show: false)),
            ])),
        extra: Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: kPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('🔮 Poids prédit J+15 : ', style: TextStyle(fontWeight: FontWeight.w700, color: kPurple)),
              Text('${poidsPredit.toStringAsFixed(0)}g', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: kPurple)),
            ])),
        legend: Row(mainAxisAlignment: MainAxisAlignment.center, children: [_legendItem(kBlue, 'Réel'), const SizedBox(width: 16), _legendItem(kPurple, 'Prédiction Gompertz')]));
  }

  Widget _chartContainer(String title, Widget chart, {Widget? legend, Widget? extra}) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: kBlue)),
      const SizedBox(height: 16),
      Container(height: 250, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]), child: chart),
      if (legend != null) ...[const SizedBox(height: 12), legend],
      if (extra != null) extra,
    ]));
  }

  Widget _legendItem(Color color, String label) => Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 16, height: 3, color: color), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 12))]);
  Widget _emptyChart(String msg) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('📊', style: TextStyle(fontSize: 48)), const SizedBox(height: 12), Text(msg, style: const TextStyle(color: Colors.grey, fontSize: 14))]));
}

// ══════════════════════════════════════════
// FINANCE
// ══════════════════════════════════════════
class FinancePage extends StatefulWidget {
  const FinancePage({super.key});
  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List _cycles = [];
  List _donnees = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _tabCtrl = TabController(length: 3, vsync: this); _load(); }
  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final c = await ApiService.getCycles();
    final d = await ApiService.getDonnees();
    setState(() { _cycles = c; _donnees = d; _loading = false; });
  }

  double _calculerRevenu(Map cycle) {
    final sujets = (cycle['nombre_sujets'] as int? ?? 0).toDouble();
    final mortalite = _donnees.where((d) => d['cycle_id'] == cycle['id']).fold(0, (sum, d) => sum + (d['mortalite'] as int? ?? 0));
    return (sujets - mortalite) * FinanceParams.prixVentePoulet;
  }

  double _calculerDepenses(Map cycle) {
    final sujets = (cycle['nombre_sujets'] as int? ?? 0).toDouble();
    final aliment = _donnees.where((d) => d['cycle_id'] == cycle['id']).fold(0.0, (sum, d) => sum + (d['consommation_aliment'] as num? ?? 0).toDouble());
    return (aliment / 50) * FinanceParams.prixSacAliment + sujets * FinanceParams.prixPoussin + sujets * FinanceParams.coutMedicalParPoussin + FinanceParams.salairesMois * 1.5 + FinanceParams.loyerMois * 1.5;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: kBlue));
    double totalRevenu = _cycles.fold(0.0, (sum, c) => sum + _calculerRevenu(c));
    double totalDepenses = _cycles.fold(0.0, (sum, c) => sum + _calculerDepenses(c));
    double marge = totalRevenu - totalDepenses;
    return Scaffold(body: Column(children: [
      Container(padding: const EdgeInsets.all(16), color: kBlue,
          child: Row(children: [
            _finKpi('💵 Revenus', _formatFcfa(totalRevenu), kGreen),
            const SizedBox(width: 8),
            _finKpi('💸 Dépenses', _formatFcfa(totalDepenses), kRed),
            const SizedBox(width: 8),
            _finKpi('📊 Marge', _formatFcfa(marge), marge >= 0 ? kGreen : kRed),
          ])),
      Container(color: kBlue, child: TabBar(controller: _tabCtrl, labelColor: Colors.white, unselectedLabelColor: Colors.white54, indicatorColor: Colors.white,
          tabs: const [Tab(text: '💵 Par Cycle'), Tab(text: '💸 Dépenses'), Tab(text: '⚙️ Paramètres')])),
      Expanded(child: TabBarView(controller: _tabCtrl, children: [_buildParCycle(), _buildDepenses(), _buildParametres()])),
    ]));
  }

  Widget _buildParCycle() => ListView(padding: const EdgeInsets.all(16), children: [
    ..._cycles.map((c) {
      final revenu = _calculerRevenu(c);
      final depenses = _calculerDepenses(c);
      final marge = revenu - depenses;
      return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c['nom'] ?? '', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: kBlue)),
            Text('${c['nombre_sujets'] ?? 0} sujets', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 12),
            Row(children: [_finRow('💵 Revenus', revenu, kGreen), const SizedBox(width: 8), _finRow('💸 Dépenses', depenses, kRed)]),
            const SizedBox(height: 8),
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: (marge >= 0 ? kGreen : kRed).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('📊 Marge', style: TextStyle(fontWeight: FontWeight.w700, color: marge >= 0 ? kGreen : kRed)),
                  Text(_formatFcfa(marge), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: marge >= 0 ? kGreen : kRed)),
                ])),
          ]));
    }),
  ]);

  Widget _buildDepenses() {
    final cycle = _cycles.isNotEmpty ? _cycles.first : <String, dynamic>{};
    final sujets = (cycle['nombre_sujets'] as int? ?? 1000).toDouble();
    final aliment = _donnees.where((d) => d['cycle_id'] == cycle['id']).fold(0.0, (sum, d) => sum + (d['consommation_aliment'] as num? ?? 0).toDouble());
    final items = [
      {'label': '🐥 Poussins', 'montant': sujets * FinanceParams.prixPoussin},
      {'label': '🌾 Aliment', 'montant': (aliment / 50) * FinanceParams.prixSacAliment},
      {'label': '💊 Médical', 'montant': sujets * FinanceParams.coutMedicalParPoussin},
      {'label': '👥 Salaires', 'montant': FinanceParams.salairesMois * 1.5},
      {'label': '🏠 Loyer', 'montant': FinanceParams.loyerMois * 1.5},
    ];
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Détail des dépenses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kBlue)),
      const SizedBox(height: 12),
      ...items.map((item) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
          child: Row(children: [Text(item['label'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)), const Spacer(), Text(_formatFcfa(item['montant'] as double), style: const TextStyle(fontWeight: FontWeight.w800, color: kRed, fontSize: 14))]))),
    ]);
  }

  Widget _buildParametres() => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Paramètres financiers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kBlue)),
    const Text('Modifiez les valeurs selon votre situation', style: TextStyle(color: Colors.grey, fontSize: 12)),
    const SizedBox(height: 16),
    _paramField('Prix sac aliment (FCFA)', FinanceParams.prixSacAliment, (v) => setState(() => FinanceParams.prixSacAliment = v)),
    _paramField('Prix vente poulet (FCFA)', FinanceParams.prixVentePoulet, (v) => setState(() => FinanceParams.prixVentePoulet = v)),
    _paramField('Prix poussin (FCFA)', FinanceParams.prixPoussin, (v) => setState(() => FinanceParams.prixPoussin = v)),
    _paramField('Salaires/mois (FCFA)', FinanceParams.salairesMois, (v) => setState(() => FinanceParams.salairesMois = v)),
    _paramField('Loyer/mois (FCFA)', FinanceParams.loyerMois, (v) => setState(() => FinanceParams.loyerMois = v)),
    _paramField('Coût médical/poussin (FCFA)', FinanceParams.coutMedicalParPoussin, (v) => setState(() => FinanceParams.coutMedicalParPoussin = v)),
  ]);

  Widget _paramField(String label, double value, Function(double) onChanged) {
    final ctrl = TextEditingController(text: value.toStringAsFixed(0));
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
        child: Row(children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          SizedBox(width: 120, child: TextField(controller: ctrl, keyboardType: TextInputType.number, textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w800, color: kBlue),
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), filled: true, fillColor: kBg),
              onSubmitted: (v) => onChanged(double.tryParse(v) ?? value))),
        ]));
  }

  Widget _finKpi(String label, String value, Color color) => Expanded(child: Container(padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
      child: Column(children: [Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)), Text(value, style: TextStyle(color: color == kGreen ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.w800, fontSize: 12))])));

  Widget _finRow(String label, double montant, Color color) => Expanded(child: Container(padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 10, color: color)), Text(_formatFcfa(montant), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: color))])));

  String _formatFcfa(double v) => '${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA';
}

// ══════════════════════════════════════════
// METEO
// ══════════════════════════════════════════
class MeteoPage extends StatefulWidget {
  const MeteoPage({super.key});
  @override
  State<MeteoPage> createState() => _MeteoPageState();
}

class _MeteoPageState extends State<MeteoPage> {
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
    return Scaffold(body: _loading ? const Center(child: CircularProgressIndicator(color: kBlue)) :
    RefreshIndicator(onRefresh: _load, color: kBlue,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Météo Sénégal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kBlue)),
            IconButton(icon: const Icon(Icons.refresh_rounded, color: kBlue), onPressed: _load),
          ]),
          const SizedBox(height: 8),
          ..._meteos.entries.map((e) => _meteoCard(e.key, e.value)),
        ])));
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
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
        child: Row(children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(icon, style: const TextStyle(fontSize: 24)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ville, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 4),
            Row(children: [_meteoChip('💧 $humidity%', Colors.blue), const SizedBox(width: 6), _meteoChip('💨 ${windSpeed}m/s', Colors.grey), const SizedBox(width: 6), _meteoChip('↕ $tempMin-$tempMax°', kOrange)]),
          ])),
          Column(children: [
            Text('$temp°C', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: color)),
            if (tempVal > 35) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: kRed.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: const Text('⚠️ Chaud', style: TextStyle(color: kRed, fontSize: 10, fontWeight: FontWeight.w700))),
          ]),
        ]));
  }

  Widget _meteoChip(String text, Color color) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)));
}

// ══════════════════════════════════════════
// ALERTES
// ══════════════════════════════════════════
class AlertesPage extends StatefulWidget {
  const AlertesPage({super.key});
  @override
  State<AlertesPage> createState() => _AlertesPageState();
}

class _AlertesPageState extends State<AlertesPage> {
  List _alertes = [];
  List _donnees = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() => _loading = true);
    final a = await ApiService.getAlertes();
    final d = await ApiService.getDonnees();
    setState(() { _alertes = a; _donnees = d; _loading = false; });
  }

  List _alertesAuto() {
    List alertes = [];
    final sorted = List.from(_donnees)..sort((a, b) => (b['age_jours'] as int? ?? 0).compareTo(a['age_jours'] as int? ?? 0));
    if (sorted.isNotEmpty) {
      final mort = sorted.first['mortalite'] as int? ?? 0;
      if (mort > 10) alertes.add({'titre': '🚨 Mortalité élevée', 'description': '$mort morts au J${sorted.first['age_jours']}', 'type': 'danger'});
      else if (mort > 5) alertes.add({'titre': '⚠️ Mortalité à surveiller', 'description': '$mort morts au J${sorted.first['age_jours']}', 'type': 'warning'});
    }
    return alertes;
  }

  @override
  Widget build(BuildContext context) {
    final toutesAlertes = [..._alertesAuto(), ..._alertes];
    return RefreshIndicator(onRefresh: _load, color: kBlue,
        child: _loading ? const Center(child: CircularProgressIndicator(color: kBlue)) :
        ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Alertes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kBlue)),
          const SizedBox(height: 16),
          if (toutesAlertes.isEmpty) _empty('Aucune alerte', 'Tout va bien !', '✅'),
          ...toutesAlertes.map((a) => _alerteCard(a)),
        ]));
  }

  Widget _alerteCard(Map a) {
    final type = a['type'] ?? 'info';
    final color = type == 'danger' ? kRed : type == 'warning' ? kOrange : kBlue;
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.2))),
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(type == 'danger' ? '🚨' : type == 'warning' ? '⚠️' : 'ℹ️', style: const TextStyle(fontSize: 20)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a['titre'] ?? a['message'] ?? '', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color)),
            if (a['description'] != null) Text(a['description'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ])),
        ]));
  }
}

// ══════════════════════════════════════════
// PROFIL
// ══════════════════════════════════════════
class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
      Container(width: double.infinity, padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [kBlue, Color(0xFF2563EB)]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: kBlue.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))]),
          child: Column(children: [
            Container(width: 70, height: 70, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: const Center(child: Text('👤', style: TextStyle(fontSize: 36)))),
            const SizedBox(height: 12),
            Text(SessionManager.nom.isNotEmpty ? SessionManager.nom : 'Utilisateur', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 4),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text('⭐ ${SessionManager.role.toUpperCase()}', style: const TextStyle(color: Colors.white, fontSize: 12))),
          ])),
      const SizedBox(height: 16),
      _menuCard(Icons.email_rounded, SessionManager.email.isNotEmpty ? SessionManager.email : 'Email', 'Email', kBlue),
      _menuCard(Icons.agriculture_rounded, SessionManager.nom, SessionManager.email, kGreen),
      _menuCard(Icons.api_rounded, 'kewere-aissa-smart.onrender.com', 'API', kPurple),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, height: 52,
          child: ElevatedButton.icon(
              onPressed: () async {
                await SessionManager.clear();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Se déconnecter', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red.shade700, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0, side: BorderSide(color: Colors.red.shade200)))),
    ]));
  }

  static Widget _menuCard(IconData icon, String title, String subtitle, Color color) => Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)), Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12))])),
        Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 14),
      ]));
}

// ══════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════
Widget _empty(String title, String subtitle, String emoji) => Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(children: [
  Text(emoji, style: const TextStyle(fontSize: 48)), const SizedBox(height: 12),
  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: kBlue)), const SizedBox(height: 4),
  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
])));

void _snack(BuildContext context, String msg, Color color) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)), backgroundColor: color, behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));