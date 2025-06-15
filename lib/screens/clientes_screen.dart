import 'package:flutter/material.dart';
import '../models/cliente_model.dart';
import '../services/cliente_service.dart';
import 'cliente_form_screen.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({Key? key}) : super(key: key);

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final _clienteService = ClienteService();
  List<Cliente> _clientes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    try {
      final clientes = await _clienteService.listarClientes();
      setState(() {
        _clientes = clientes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los clientes: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _eliminarCliente(int id) async {
    try {
      await _clienteService.eliminarCliente(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente eliminado exitosamente')),
        );
        _cargarClientes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el cliente: $e')),
        );
      }
    }
  }

  Future<void> _navegarAFormulario([Cliente? cliente]) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClienteFormScreen(cliente: cliente),
      ),
    );

    if (resultado == true) {
      _cargarClientes();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Clientes'),
      ),
      body: _errorMessage != null
          ? Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : _clientes.isEmpty
              ? const Center(
                  child: Text('No hay clientes registrados'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _clientes.length,
                  itemBuilder: (context, index) {
                    final cliente = _clientes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: cliente.imagenPerfil != null
                              ? NetworkImage(
                                  'http://192.168.0.105:8081${cliente.imagenPerfil}')
                              : null,
                          child: cliente.imagenPerfil == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(
                          '${cliente.nombres ?? ''} ${cliente.apellidos ?? ''}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (cliente.correo != null)
                              Text('Correo: ${cliente.correo}'),
                            if (cliente.whatsappContacto != null)
                              Text('WhatsApp: ${cliente.whatsappContacto}'),
                            if (cliente.direccion != null)
                              Text('Dirección: ${cliente.direccion}'),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'editar',
                              child: Text('Editar'),
                            ),
                            const PopupMenuItem(
                              value: 'eliminar',
                              child: Text('Eliminar'),
                            ),
                          ],
                          onSelected: (value) async {
                            if (value == 'eliminar') {
                              final confirmar = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirmar eliminación'),
                                  content: const Text(
                                    '¿Está seguro de eliminar este cliente?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmar == true && mounted) {
                                await _eliminarCliente(cliente.idCliente!);
                              }
                            } else if (value == 'editar') {
                              _navegarAFormulario(cliente);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navegarAFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
} 