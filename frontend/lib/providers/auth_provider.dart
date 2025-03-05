
import '../services/auth_service.dart';
//import '../models/user.dart';

import 'dart:async';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool isAuthenticated = false;
  String? errorMessage;
  Timer? _refreshTimer;

  AuthProvider() {
    _initializeAuth();
  }

  /// Initialize auth status by checking stored tokens on app startup.
  void _initializeAuth() async {
    // If a refresh token exists, attempt to use it to keep the user logged in
    String? refresh = await AuthService.getRefreshToken();
    if (refresh != null) {
      String? access = await AuthService.getAccessToken();
      if (access == null || AuthService.isAccessTokenExpired()) {
        // If no access token or it's expired, try to refresh it
        await AuthService.refreshTokens();
        access = await AuthService.getAccessToken();
      }
      if (access != null) {
        isAuthenticated = true;
        _scheduleTokenRefresh();  // Schedule automatic refresh before expiry
      }
    }
    notifyListeners();
  }

  /// Log in and update auth state. Returns true if successful.
  Future<bool> login(String email, String password) async {
    try {
      await AuthService.login(email, password);
      // If login succeeds, update state
      isAuthenticated = true;
      errorMessage = null;
      _scheduleTokenRefresh();
      notifyListeners();
      return true;
    } catch (e) {
      // If login fails, capture the error message for UI
      isAuthenticated = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Register and update auth state (auto-login on successful registration).
  Future<bool> register(String email, String password) async {
    try {
      await AuthService.register(email, password);
      isAuthenticated = true;
      errorMessage = null;
      _scheduleTokenRefresh();
      notifyListeners();
      return true;
    } catch (e) {
      isAuthenticated = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Log out the user and cancel any scheduled token refresh.
  void logout() {
    AuthService.logout();
    isAuthenticated = false;
    errorMessage = null;
    _refreshTimer?.cancel();
    notifyListeners();
  }

  /// Schedule a token refresh a short time before the access token expires.
  void _scheduleTokenRefresh() {
    _refreshTimer?.cancel();  // Cancel any existing timer
    final expiry = AuthService.getAccessTokenExpiry();
    if (expiry != null) {
      // Calculate refresh time a bit before actual expiry (e.g., 1 minute before)
      final DateTime now = DateTime.now().toUtc();
      final DateTime refreshTime = expiry.toUtc().subtract(const Duration(minutes: 1));
      if (refreshTime.isAfter(now)) {
        final delay = refreshTime.difference(now);
        _refreshTimer = Timer(delay, () async {
          // When timer fires, refresh the token
          await AuthService.refreshTokens();
          if (AuthService.isAccessTokenExpired()) {
            // If refresh failed (token still expired), force log out
            logout();
          } else {
            // Otherwise, schedule the next refresh cycle
            _scheduleTokenRefresh();
          }
          notifyListeners();
        });
      }
    }
  }
}


/*

Explanation:
In AuthProvider, we maintain an isAuthenticated flag for whether the user is logged in, and an errorMessage to hold any login/registration error for display.
The constructor calls _initializeAuth(), which checks secure storage for a refresh token on app launch. If a refresh token exists, it attempts to refresh the access token (or uses the existing one if still valid). If successful, the user stays logged in (isAuthenticated = true). This logic ensures the app remains logged in as long as the refresh token is valid.
The login and register methods wrap the corresponding AuthService calls. On success, they update the state to authenticated and schedule a token refresh. On failure, they capture the exception’s message (set by _handleAuthError in AuthService) and store it in errorMessage for the UI to display. We notifyListeners() after each state change so that the UI (consumer of this provider) updates accordingly.
The logout method clears the tokens via AuthService.logout(), resets state, and cancels any scheduled refresh timer.
_scheduleTokenRefresh uses Timer to automatically invoke AuthService.refreshTokens() shortly before the access token expires. We first determine the token’s expiry time via AuthService.getAccessTokenExpiry(). Then we set a timer for one minute before that time to refresh the token in the background. If the refresh fails (meaning the refresh token likely expired), we call logout() to force the user to log in again. If refresh succeeds, we recursively schedule the next refresh based on the new token’s expiry. This mechanism keeps the JWT fresh without user intervention, preventing unexpected logouts.

*/