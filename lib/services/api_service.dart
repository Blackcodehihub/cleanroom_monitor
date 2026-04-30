import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use this for Chrome/Web
  static const String baseUrl = 'http://localhost:5000';

  // Use this for Android Emulator instead:
  // static const String baseUrl = 'http://10.0.2.2:5000';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String fullName,
    String role = 'staff',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'fullName': fullName,
        'role': role,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getAlerts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/alerts'),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getLatestReading(String deviceId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/sensors/latest/$deviceId'),
    );

    return jsonDecode(response.body);
  }
}