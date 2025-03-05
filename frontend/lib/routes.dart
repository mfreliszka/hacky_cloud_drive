import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';

/// Map of route names to widget builders for the application.
final Map<String, WidgetBuilder> appRoutes = {
  '/login': (BuildContext context) => LoginScreen(),
  '/register': (BuildContext context) => RegisterScreen(),
  '/dashboard': (BuildContext context) => DashboardScreen(),
};
