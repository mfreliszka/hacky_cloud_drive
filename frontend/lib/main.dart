import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'providers/auth_provider.dart';
import 'routes.dart';  // Contains the route definitions

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hacky Cloud Drive',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',          // Start with the login screen
      routes: appRoutes,               // Routes defined in routes.dart
      // Alternatively, use onGenerateRoute for more complex routing needs
    );
  }
}
