import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AccountScreen extends StatefulWidget {
  final Map<String, dynamic> sesion;
  final ApiService api;
  final VoidCallback onLogout;

  const AccountScreen({
    super.key,
    required this.sesion,
    required this.api,
    required this.onLogout,
  });

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map<String, dynamic>? _usuarioData;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final usuario = widget.sesion['usuario'] as Map<String, dynamic>?;
    final usuarioId = usuario?['id'];

    if (usuarioId == null) return;

    setState(() => _loading = true);

    try {
      final response = await widget.api.get('/api/usuarios/$usuarioId');
      setState(() {
        _usuarioData = response['data'] as Map<String, dynamic>?;
        _loading = false;
      });
    } on ApiException {
      setState(() => _loading = false);
    }
  }

  Future<void> _cerrarSesion() async {
    try {
      await widget.api.post('/api/sesiones/logout', {});
    } catch (_) {
      // Ignorar error, cerrar sesión de todas formas
    }
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    final usuario =
        _usuarioData ?? widget.sesion['usuario'] as Map<String, dynamic>?;
    final nombre = usuario?['nombre']?.toString() ?? 'Usuario';
    final rol = usuario?['rol']?['nombre']?.toString() ?? 'Sin rol asignado';

    return _loading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.account_circle, size: 80, color: Colors.blue),
                const SizedBox(height: 32),
                Text(
                  'Mi Cuenta',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildInfoCard('Nombre', nombre),
                const SizedBox(height: 16),
                _buildInfoCard('Rol', rol),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  onPressed: _cerrarSesion,
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar Sesión'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
