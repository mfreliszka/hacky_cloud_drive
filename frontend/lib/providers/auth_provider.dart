import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;                        // Currently authenticated user (null if not logged in)
  final AuthService _authService = AuthService();  // Service to handle API calls

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  /// Attempts to log in a user with [email] and [password].
  /// Returns true if login was successful.
  Future<bool> login(String email, String password) async {
    _user = await _authService.login(email, password);
    notifyListeners();               // Notify UI of changes
    return _user != null;
  }

  /// Attempts to register a new user with [email] and [password].
  /// Returns true if registration (and auto-login) was successful.
  Future<bool> register(String email, String password) async {
    _user = await _authService.register(email, password);
    notifyListeners();
    return _user != null;
  }

  /// Logs out the current user.
  void logout() {
    _user = null;
    notifyListeners();
  }
}
