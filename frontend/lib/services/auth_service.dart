import 'api_service.dart';
import '../models/user.dart';

class AuthService {
  final ApiService _api = ApiService();

  /// Logs in with [email] and [password]. Returns a [User] on success, or null on failure.
  Future<User?> login(String email, String password) async {
    // In a real app, call the API and check response status:
    // final response = await _api.post('/login/', {'email': email, 'password': password});
    // if response indicates success, parse user data.
    // Here, we simulate a successful login if both fields are non-empty.
    if (email.isNotEmpty && password.isNotEmpty) {
      // Assuming the backend returns user info on success
      return User(email: email);
    }
    return null; // Login failed (invalid credentials)
  }

  /// Registers a new user with [email] and [password]. Returns a [User] on success.
  Future<User?> register(String email, String password) async {
    // In a real app, call the register API and check response.
    // For now, assume registration always succeeds if inputs are non-empty.
    if (email.isNotEmpty && password.isNotEmpty) {
      return User(email: email);
    }
    return null;
  }
}
