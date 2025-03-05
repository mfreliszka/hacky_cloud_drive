import 'dart:convert';  // For JSON encoding/decoding
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';  // Base URL for Django API

  // Example POST request method
  Future<http.Response> post(String endpoint, Map<String, dynamic> data) {
    final url = Uri.parse('$baseUrl$endpoint');
    // In a real implementation, you would include headers, handle errors, etc.
    return http.post(url, body: jsonEncode(data), headers: {
      'Content-Type': 'application/json',
    });
  }

  // Example GET request method
  Future<http.Response> get(String endpoint) {
    final url = Uri.parse('$baseUrl$endpoint');
    return http.get(url);
  }
}
