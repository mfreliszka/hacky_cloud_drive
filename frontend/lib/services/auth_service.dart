import 'dart:convert';
import 'dart:async';  // for Timer if needed
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static final _secureStorage = FlutterSecureStorage();
  static const String _baseUrl = 'http://localhost:8000'; // Base API URL
  static String? _accessToken;
  static String? _refreshToken;

  /// Login with email and password. On success, store tokens in secure storage.
  static Future<void> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/api/auth/login/');
    final response = await http.post(url, body: {
      'email': email,
      'password': password,
    });
    if (response.statusCode == 200) {
      // Parse JSON to get tokens
      final data = json.decode(response.body);
      _accessToken = data['access'];
      _refreshToken = data['refresh'];
      // Save tokens securely
      await _secureStorage.write(key: 'accessToken', value: _accessToken);
      await _secureStorage.write(key: 'refreshToken', value: _refreshToken);
    } else {
      _handleAuthError(response);
    }
  }

  /// Register a new user. On success, store tokens (if API returns them).
  static Future<void> register(String email, String password) async {
    final url = Uri.parse('$_baseUrl/api/auth/register/');
    final response = await http.post(url, body: {
      'email': email,
      'password': password,
    });
    if (response.statusCode == 201 || response.statusCode == 200) {
      // If registration returns tokens or auto-login
      final data = json.decode(response.body);
      if (data.containsKey('access')) {
        _accessToken = data['access'];
        _refreshToken = data['refresh'];
        await _secureStorage.write(key: 'accessToken', value: _accessToken);
        await _secureStorage.write(key: 'refreshToken', value: _refreshToken);
      }
      // (If the API doesn’t return tokens on register, you might prompt the user to log in manually after registration)
    } else {
      _handleAuthError(response);
    }
  }

  /// Handle authentication errors by throwing a user-friendly Exception.
  static Never _handleAuthError(http.Response response) {
    String message = 'Authentication failed. Please try again.';
    if (response.statusCode == 400 || response.statusCode == 401) {
      final data = json.decode(response.body);
      if (data is Map) {
        if (data.containsKey('detail')) {
          // e.g., {"detail": "Invalid credentials"}
          message = data['detail'];
        } else if (data.containsKey('error')) {
          message = data['error'];
        } else if (data.containsKey('email')) {
          // e.g., {"email": ["A user with that email already exists."]}
          message = data['email'][0];
        } else if (data.containsKey('password')) {
          message = data['password'][0];
        }
      }
    }
    // Throw an exception with the friendly message
    throw Exception(message);
  }

  /// Retrieve the stored access token (from memory or secure storage).
  static Future<String?> getAccessToken() async {
    _accessToken ??= await _secureStorage.read(key: 'accessToken');
    return _accessToken;
  }

  /// Retrieve the stored refresh token.
  static Future<String?> getRefreshToken() async {
    _refreshToken ??= await _secureStorage.read(key: 'refreshToken');
    return _refreshToken;
  }

  /// Check if the current access token is expired.
  static bool isAccessTokenExpired() {
    if (_accessToken == null) return true;
    final parts = _accessToken!.split('.');
    if (parts.length != 3) return true;
    // Decode JWT payload
    String payload = parts[1];
    // Pad the payload if necessary and decode from Base64URL
    payload = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(payload));
    final payloadMap = json.decode(decoded);
    if (payloadMap is! Map || !payloadMap.containsKey('exp')) return true;
    final exp = payloadMap['exp'];  // expiration time in seconds since epoch
    final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
    return DateTime.now().toUtc().isAfter(expiry);
  }

  /// Refresh the JWT using the refresh token. Updates stored tokens on success.
  static Future<void> refreshTokens() async {
    final refresh = await getRefreshToken();
    if (refresh == null) return;  // no refresh token available
    final url = Uri.parse('$_baseUrl/api/auth/refresh/');
    final response = await http.post(url, body: {
      'refresh': refresh,
    });
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.containsKey('access')) {
        _accessToken = data['access'];
        await _secureStorage.write(key: 'accessToken', value: _accessToken);
      }
      if (data.containsKey('refresh')) {
        // Some APIs return a new refresh token as well
        _refreshToken = data['refresh'];
        await _secureStorage.write(key: 'refreshToken', value: _refreshToken);
      }
    } else {
      // Refresh token is invalid or expired – log out the user
      await logout();
    }
  }

  /// Calculate the DateTime when the current access token expires.
  static DateTime? getAccessTokenExpiry() {
    if (_accessToken == null) return null;
    final parts = _accessToken!.split('.');
    if (parts.length != 3) return null;
    final payload = base64Url.normalize(parts[1]);
    final payloadMap = json.decode(utf8.decode(base64Url.decode(payload)));
    if (payloadMap is Map && payloadMap.containsKey('exp')) {
      final exp = payloadMap['exp'];
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
    }
    return null;
  }

  /// Log out the user by clearing tokens from memory and secure storage.
  static Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
    await _secureStorage.delete(key: 'accessToken');
    await _secureStorage.delete(key: 'refreshToken');
  }
}


/*

Explanation:
We import flutter_secure_storage and use a single instance (_secureStorage) to read/write tokens securely on the device. This ensures tokens are not exposed in plain text.
The login and register functions call the Django API endpoints (assumed to be /api/auth/login/ and /api/auth/register/). On success, they store the returned JWT access and refresh tokens in memory and secure storage. On failure, _handleAuthError is called to parse the error response.
_handleAuthError looks at the HTTP response and extracts a user-friendly message. For example, if credentials are wrong, Django (using Simple JWT or similar) might return a 401 with a "detail" like "No active account found...". If an email is already registered, the API might return a 400 with an "email" field error. We prioritize these specific messages and throw an Exception with the friendly text. This exception can be caught and displayed by the UI.
getAccessToken and getRefreshToken retrieve tokens from secure storage (and cache them in memory for quick reuse). This allows other services to get the token when making API calls.
isAccessTokenExpired checks if the JWT access token is expired by decoding its payload. We split the JWT and Base64URL-decode the payload to read the "exp" (expiration time) claim. If the current UTC time is beyond the exp, the token is expired (or if any decoding issue occurs, we assume expired to be safe).
refreshTokens uses the refresh token to get a new access token from /api/auth/refresh/. On a 200 OK response, it updates the stored access token (and refresh token if the backend provides a new one). If the refresh token is invalid or expired (non-200 response), it calls logout() to clear any stored tokens – meaning the user must log in again.
getAccessTokenExpiry is a helper to get the exact expiry DateTime of the current access token (used for scheduling a refresh).
logout clears both tokens from memory and secure storage, effectively ending the authenticated session.

*/