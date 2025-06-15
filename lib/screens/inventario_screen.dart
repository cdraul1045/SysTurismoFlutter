import 'package:flutter/material.dart';
import '../models/inventario_model.dart';
import '../services/inventario_service.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({Key? key}) : super(key: key);

  @override
  _InventarioScreenState createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  final InventarioService _inventarioService = InventarioService();
  List<Inventario> _inventarioList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarInventario();
  }

  Future<void> _cargarInventario() async {
    try {
      final inventario = await _inventarioService.listarInventario();
      setState(() {
        _inventarioList = inventario;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar el inventario: $e')),
      );
    }
  }

  Future<void> _mostrarFormulario([Inventario? inventario]) async {
    final _formKey = GlobalKey<FormState>();
    String nombreItem = inventario?.nombreItem ?? '';
    int cantidadDisponible = inventario?.cantidadDisponible ?? 0;
    int idDestino = inventario?.idDestino ?? 0;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(inventario == null ? 'Nuevo Item' : 'Editar Item'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: nombreItem,
                decoration: const InputDecoration(labelText: 'Nombre del Item'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
                onSaved: (value) => nombreItem = value!,
              ),
              TextFormField(
                initialValue: cantidadDisponible.toString(),
                decoration: const InputDecoration(labelText: 'Cantidad Disponible'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una cantidad';
                  }
                  return null;
                },
                onSaved: (value) => cantidadDisponible = int.parse(value!),
              ),
              TextFormField(
                initialValue: idDestino.toString(),
                decoration: const InputDecoration(labelText: 'ID Destino'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un ID de destino';
                  }
                  return null;
                },
                onSaved: (value) => idDestino = int.parse(value!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                try {
                  if (inventario == null) {
                    await _inventarioService.guardarInventario(
                      Inventario(
                        nombreItem: nombreItem,
                        cantidadDisponible: cantidadDisponible,
                        idDestino: idDestino,
                      ),
                    );
                  } else {
                    await _inventarioService.editarInventario(
                      Inventario(
                        idInventario: inventario.idInventario,
                        nombreItem: nombreItem,
                        cantidadDisponible: cantidadDisponible,
                        idDestino: idDestino,
                      ),
                    );
                  }
                  Navigator.pop(context);
                  _cargarInventario();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarInventario(int id) async {
    try {
      await _inventarioService.eliminarInventario(id);
      _cargarInventario();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Inventario'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _inventarioList.length,
              itemBuilder: (context, index) {
                final item = _inventarioList[index];
                return ListTile(
                  title: Text(item.nombreItem ?? ''),
                  subtitle: Text(
                    'Cantidad: ${item.cantidadDisponible} - Destino ID: ${item.idDestino}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _mostrarFormulario(item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar eliminación'),
                            content: const Text(
                              '¿Está seguro de que desea eliminar este item?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _eliminarInventario(item.idInventario!);
                                },
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
} 