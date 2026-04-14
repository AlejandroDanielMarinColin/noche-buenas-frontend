import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noche Buenas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  Map<String, dynamic>? _sesion;

  void _onLoginSuccess(Map<String, dynamic> sesionData) {
    setState(() => _sesion = sesionData);
  }

  void _onLogout() {
    ApiService().clearToken();
    setState(() => _sesion = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_sesion == null) {
      return LoginScreen(onLoginSuccess: _onLoginSuccess);
    }
    return HomeScreen(sesion: _sesion!, onLogout: _onLogout);
  }
}
