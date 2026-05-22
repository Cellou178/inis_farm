import 'package:shared_preferences/shared_preferences.dart';

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
    _token = token; _role = role; _nom = nom;
    _email = email; _entrepriseId = entrepriseId; _fermeId = fermeId;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _token = ''; _role = ''; _nom = '';
    _email = ''; _entrepriseId = ''; _fermeId = '';
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