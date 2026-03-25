import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/api_config.dart';

class AuthService {
  static String get baseUrl => ApiConfig.baseUrl;
  static const _secureStorage = FlutterSecureStorage();

  static const _keyIsLoggedIn = 'isLoggedIn';
  static const _keyAccessToken = 'access_token';
  static const _keyUserId = 'userId';
  static const _keyName = 'name';
  static const _keyIsPremium = 'is_premium';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final hasToken = (await _secureStorage.read(key: _keyAccessToken) ?? '')
        .isNotEmpty;
    return (prefs.getBool(_keyIsLoggedIn) ?? false) && hasToken;
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }


  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }

  static Future<bool> isPremiumUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsPremium) ?? false;
  }

  static Future<String?> getAccessToken() async {
    return _secureStorage.read(key: _keyAccessToken);
  }

  static Future<Map<String, String>> authHeaders({
    Map<String, String>? extra,
  }) async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('User belum login (token tidak ditemukan)');
    }

    return {
      'Authorization': 'Bearer $token',
      ...?extra,
    };
  }

  static Future<void> login(String email, String password) async {
    final res = await http.post(
      Uri.parse(ApiConfig.endpoint('/login')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode != 200) {
      throw Exception('Login gagal. Periksa email/password Anda.');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    await _saveSessionFromResponse(data);
  }

  static Future<void> loginWithGoogle(
    String token, {
    String? accessToken,
  }) async {
    final body = {
      'token': token,
      if (accessToken != null && accessToken.isNotEmpty)
        'access_token': accessToken,
    };

    final res = await http.post(
      Uri.parse(ApiConfig.endpoint('/auth/google')),
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception('Login Google gagal. Silakan coba lagi.');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    await _saveSessionFromResponse(data);
  }

  static Future<void> _saveSessionFromResponse(Map<String, dynamic> data) async {
    final accessToken = data['access_token']?.toString();
    final userIdRaw = data['userId'] ?? data['user_id'] ?? data['id'];
    final name = data['name']?.toString();
    final premiumRaw =
        data['is_premium'] ?? data['premium'] ?? data['isPremium'] ?? data['pro'];

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Response login tidak mengandung access_token');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await _secureStorage.write(key: _keyAccessToken, value: accessToken);

    if (userIdRaw != null) {
      final parsed = int.tryParse(userIdRaw.toString());
      if (parsed != null) {
        await prefs.setInt(_keyUserId, parsed);
      }
    }

    if (name != null && name.isNotEmpty) {
      await prefs.setString(_keyName, name);
    }

    final premium = premiumRaw == true ||
        premiumRaw == 1 ||
        premiumRaw?.toString() == '1' ||
        premiumRaw?.toString().toLowerCase() == 'true';
    await prefs.setBool(_keyIsPremium, premium);
  }

  static Future<void> register(String email, String password, String name) async {
    final res = await http.post(
      Uri.parse(ApiConfig.endpoint('/register')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );

    if (res.statusCode != 200) {
      throw Exception('Registrasi gagal. Silakan cek data Anda.');
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await _secureStorage.delete(key: _keyAccessToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyName);
    await prefs.remove(_keyIsPremium);
  }

  static Future<void> resetPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final headers = await authHeaders(
      extra: {'Content-Type': 'application/x-www-form-urlencoded'},
    );

    final res = await http.post(
      Uri.parse(ApiConfig.endpoint('/reset-password')),
      headers: headers,
      body: {
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Reset password gagal. Silakan coba lagi.');
    }
  }
}
