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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedUbicacion;
  
  // Lista de ubicaciones disponibles
  final List<String> _ubicaciones = ["Capachica", "Chifrón", "Isla", "Llachón"];

  List<Destino> _destinos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarDestinos();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<Destino> get _filteredDestinos {
    return _destinos.where((destino) {
      final matchesSearch = destino.nombre?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
      final matchesUbicacion = _selectedUbicacion == null || destino.ubicacion == _selectedUbicacion;
      return matchesSearch && matchesUbicacion;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Destinos'),
      ),
      body: Column(
        children: [
          // Campo de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar Destinos',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),

          // Filtros de ubicación
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Todos'),
                  selected: _selectedUbicacion == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedUbicacion = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ..._ubicaciones.map((ubicacion) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(ubicacion),
                      selected: _selectedUbicacion == ubicacion,
                      onSelected: (selected) {
                        setState(() {
                          _selectedUbicacion = selected ? ubicacion : null;
                        });
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          // Lista de destinos
          Expanded(
            child: _isLoading
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
                    : _filteredDestinos.isEmpty
                        ? const Center(
                            child: Text('No hay destinos registrados'),
                          )
                        : RefreshIndicator(
                            onRefresh: _cargarDestinos,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredDestinos.length,
                              itemBuilder: (context, index) {
                                final destino = _filteredDestinos[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: ListTile(
                                    title: Text(
                                      destino.nombre ?? 'Sin nombre',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          destino.descripcion ?? 'Sin descripción',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            destino.ubicacion ?? 'Sin ubicación',
                                            style: TextStyle(
                                              color: Colors.blue.shade900,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    isThreeLine: true,
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarDestino,
        child: const Icon(Icons.add),
      ),
    );
  }
} 