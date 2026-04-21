import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UsersScreen extends StatefulWidget {
  final ApiService api;

  const UsersScreen({super.key, required this.api});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<Map<String, dynamic>> _usuarios = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await widget.api.get('/api/sesiones/en-linea');
      setState(() {
        _usuarios = List<Map<String, dynamic>>.from(response['data'] ?? []);
        _loading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _cerrarSesion(String sesionId, String nombreUsuario) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: Text('¿Cerrar sesión de $nombreUsuario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, cerrar'),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      try {
        await widget.api.patch('/api/sesiones/$sesionId/revocar', {});
        await _cargarUsuarios();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sesión de $nombreUsuario cerrada')),
          );
        }
      } on ApiException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.message}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarUsuarios,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_usuarios.isEmpty) {
      return const Center(child: Text('No hay usuarios'));
    }

    return ListView.builder(
      itemCount: _usuarios.length,
      itemBuilder: (context, index) {
        final usuario = _usuarios[index];
        final nombre = usuario['nombre'] ?? 'Sin nombre';
        final rol = usuario['rol']?['nombre'] ?? 'Sin rol';
        final sesionId = usuario['sesion_id'];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              rol,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'En línea',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      _cerrarSesion(sesionId?.toString() ?? '', nombre),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Cerrar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
