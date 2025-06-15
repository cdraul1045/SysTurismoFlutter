import 'package:flutter/material.dart';
import '../models/destino_model.dart';
import '../services/destino_service.dart';
import 'destino_form_screen.dart';

class DestinosScreen extends StatefulWidget {
  const DestinosScreen({super.key});

  @override
  State<DestinosScreen> createState() => _DestinosScreenState();
}

class _DestinosScreenState extends State<DestinosScreen> {
  final DestinoService _destinoService = DestinoService();
  List<Destino> _destinos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarDestinos();
  }

  Future<void> _cargarDestinos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final destinos = await _destinoService.listarDestinos();
      print('Destinos cargados: ${destinos.length}');
      for (var destino in destinos) {
        print('Destino: ${destino.toString()}');
      }
      setState(() {
        _destinos = destinos;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar destinos: $e');
      setState(() {
        _errorMessage = 'Error al cargar los destinos: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _eliminarDestino(Destino destino) async {
    if (destino.idDestino == null) {
      print('Error: ID del destino es null');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: ID del destino no encontrado')),
        );
      }
      return;
    }

    try {
      print('Eliminando destino: ${destino.toString()}');
      await _destinoService.eliminarDestino(destino.idDestino!);
      if (mounted) {
        setState(() {
          _destinos.removeWhere((d) => d.idDestino == destino.idDestino);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Destino eliminado exitosamente')),
        );
      }
    } catch (e) {
      print('Error al eliminar destino: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el destino: $e')),
        );
      }
    }
  }

  Future<void> _mostrarDialogoEliminar(Destino destino) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Está seguro de eliminar el destino ${destino.nombre}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () {
                Navigator.of(context).pop();
                _eliminarDestino(destino);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editarDestino(Destino destino) async {
    try {
      print('Editando destino: ${destino.toString()}');
      final resultado = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DestinoFormScreen(destino: destino),
        ),
      );

      if (resultado != null && resultado is Destino) {
        print('Destino actualizado: ${resultado.toString()}');
        setState(() {
          final index = _destinos.indexWhere((d) => d.idDestino == destino.idDestino);
          if (index != -1) {
            _destinos[index] = resultado;
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Destino actualizado exitosamente')),
          );
        }
      }
    } catch (e) {
      print('Error al editar destino: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al editar el destino: $e')),
        );
      }
    }
  }

  Future<void> _agregarDestino() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DestinoFormScreen(),
      ),
    );

    if (resultado != null && resultado is Destino) {
      print('Nuevo destino agregado: ${resultado.toString()}');
      setState(() {
        _destinos.add(resultado);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Destinos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDestinos,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarDestinos,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _destinos.isEmpty
                  ? const Center(
                      child: Text('No hay destinos registrados'),
                    )
                  : RefreshIndicator(
                      onRefresh: _cargarDestinos,
                      child: ListView.builder(
                        itemCount: _destinos.length,
                        itemBuilder: (context, index) {
                          final destino = _destinos[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: destino.imagenPath != null
                                    ? NetworkImage('http://192.168.0.105:8081${destino.imagenPath}')
                                    : null,
                                child: destino.imagenPath == null
                                    ? const Icon(Icons.landscape)
                                    : null,
                              ),
                              title: Text(
                                destino.nombre ?? 'Sin nombre',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (destino.descripcion != null)
                                    Text('Descripción: ${destino.descripcion}'),
                                  if (destino.ubicacion != null)
                                    Text('Ubicación: ${destino.ubicacion}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editarDestino(destino),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _mostrarDialogoEliminar(destino),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarDestino,
        child: const Icon(Icons.add),
      ),
    );
  }
} 