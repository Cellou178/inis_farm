import '../models/user_model.dart';
import '../managers/session_manager.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });
    final user = UserModel.fromJson(data['user']);
    await SessionManager.saveSession(
      token: data['access_token'],
      user: user,
    );
    return user;
  }

  Future<UserModel> register({
    required String nom,
    required String email,
    required String password,
  }) async {
    final data = await _api.post('/auth/register', {
      'nom': nom,
      'email': email,
      'password': password,
    });
    final user = UserModel.fromJson(data['user']);
    await SessionManager.saveSession(
      token: data['access_token'],
      user: user,
    );
    return user;
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout', {});
    } finally {
      await SessionManager.clear();
    }
  }

  Future<UserModel> getProfile() async {
    final data = await _api.get('/auth/me');
    return UserModel.fromJson(data);
  }
}