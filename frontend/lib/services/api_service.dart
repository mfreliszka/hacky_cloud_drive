import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String _baseUrl = 'http://http://localhost:8000';

  /// Perform a GET request to the given endpoint, with JWT authorization.
  static Future<http.Response> get(String endpoint) async {
    // Ensure we have a valid access token
    String? token = await AuthService.getAccessToken();
    if (token == null || AuthService.isAccessTokenExpired()) {
      // If no token or token expired, attempt to refresh it
      await AuthService.refreshTokens();
      token = await AuthService.getAccessToken();
    }
    // Include Authorization header if token is available
    // final headers = token != null ? {'Authorization': 'Bearer $token'} : {};
    final Map<String, String> headers = token != null 
    ? {'Authorization': 'Bearer $token'} 
    : {};
    final response = await http.get(Uri.parse('$_baseUrl$endpoint'), headers: headers);
    if (response.statusCode == 401) {
      // If unauthorized, the access token might have just expired. Try one refresh and retry.
      await AuthService.refreshTokens();
      token = await AuthService.getAccessToken();
      if (token != null) {
        return http.get(Uri.parse('$_baseUrl$endpoint'),
            headers: {'Authorization': 'Bearer $token'});
      }
    }
    return response;
  }

  /// Perform a POST request to the given endpoint, with JWT and any provided body.
  static Future<http.Response> post(String endpoint,
      {Map<String, String>? headers, dynamic body}) async {
    // Ensure token is fresh
    String? token = await AuthService.getAccessToken();
    if (token == null || AuthService.isAccessTokenExpired()) {
      await AuthService.refreshTokens();
      token = await AuthService.getAccessToken();
    }
    // Merge Authorization header with any custom headers
    final authHeaders = <String, String>{};
    if (token != null) {
      authHeaders['Authorization'] = 'Bearer $token';
    }
    if (headers != null) {
      authHeaders.addAll(headers);
    }
    final response = await http.post(Uri.parse('$_baseUrl$endpoint'),
        headers: authHeaders, body: body);
    if (response.statusCode == 401) {
      // Try refresh once if we get unauthorized, then retry request
      await AuthService.refreshTokens();
      token = await AuthService.getAccessToken();
      if (token != null) {
        authHeaders['Authorization'] = 'Bearer $token';
        return http.post(Uri.parse('$_baseUrl$endpoint'),
            headers: authHeaders, body: body);
      }
    }
    return response;
  }

  // Similarly, you can add PUT, DELETE, etc., following the same pattern.
}


/*

Explanation:
The ApiService ensures all API calls include the JWT in the Authorization header. Before making a request, we retrieve the access token and check its validity using AuthService.
If the access token is missing or expired, we call AuthService.refreshTokens() to get a new one (using the refresh token) before sending the request. This proactive refresh means the user stays logged in as long as the refresh token remains valid.
In the get and post methods, after attempting the request, we also handle the case of a 401 Unauthorized response. If a request comes back 401, it likely means the access token was expired (perhaps just before the request). In that case, we refresh the token and retry the request once.
By always adding the header Authorization: Bearer <accessToken>, protected endpoints on the Django API will receive the JWT and allow access if it’s valid. This integration covers both initial token usage and automatic refresh, fulfilling the JWT handling and token refreshing requirements.

*/
