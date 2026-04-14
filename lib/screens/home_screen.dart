import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'users_screen.dart';
import 'account_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> sesion;
  final VoidCallback onLogout;

  const HomeScreen({super.key, required this.sesion, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _api = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Noche Buenas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? UsersScreen(api: _api)
          : AccountScreen(sesion: widget.sesion, api: _api, onLogout: widget.onLogout),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Usuarios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Mi Cuenta',
          ),
        ],
      ),
    );
  }
}
