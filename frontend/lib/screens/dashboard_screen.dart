import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get current user (if needed for display)
    final user = Provider.of<AuthProvider>(context).user;
    return Scaffold(
      appBar: AppBar(title: Text('Cloud Drive Dashboard')),
      body: Center(
        child: Text(
          user != null 
            ? 'Welcome, ${user.email}!' 
            : 'Welcome!',
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logout the user
          Provider.of<AuthProvider>(context, listen: false).logout();
          // Navigate back to login after logout
          Navigator.pushReplacementNamed(context, '/login');
        },
        tooltip: 'Logout',
        child: Icon(Icons.exit_to_app),
      ),
    );
  }
}
