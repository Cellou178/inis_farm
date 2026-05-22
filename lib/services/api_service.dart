import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../managers/session_manager.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (SessionManager.token != null)
      'Authorization': 'Bearer ${SessionManager.token}',
  };

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _client
          .get(Uri.parse('${AppConstants.baseUrl}$endpoint'), headers: _headers)
          .timeout(AppConstants.timeout);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(statusCode: 0, message: 'Pas de connexion internet');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await _client
          .post(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: _headers,
        body: jsonEncode(body),
      )
          .timeout(AppConstants.timeout);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(statusCode: 0, message: 'Pas de connexion internet');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await _client
          .put(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: _headers,
        body: jsonEncode(body),
      )
          .timeout(AppConstants.timeout);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(statusCode: 0, message: 'Pas de connexion internet');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _client
          .delete(Uri.parse('${AppConstants.baseUrl}$endpoint'), headers: _headers)
          .timeout(AppConstants.timeout);
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(statusCode: 0, message: 'Pas de connexion internet');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 401:
        SessionManager.clear();
        throw ApiException(statusCode: 401, message: 'Session expirée');
      case 403:
        throw ApiException(statusCode: 403, message: 'Accès refusé');
      case 404:
        throw ApiException(statusCode: 404, message: 'Ressource introuvable');
      case 422:
        final errors = body['detail'] ?? body['message'] ?? 'Erreur de validation';
        throw ApiException(statusCode: 422, message: errors.toString());
      case 500:
        throw ApiException(statusCode: 500, message: 'Erreur serveur');
      default:
        throw ApiException(statusCode: response.statusCode, message: body['message'] ?? 'Erreur inconnue');
    }
  }
}