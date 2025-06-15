import 'package:flutter/material.dart';
import '../models/cliente_model.dart';
import '../services/cliente_service.dart';
import 'cliente_form_screen.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final ClienteService _clienteService = ClienteService();
  List<Cliente> _clientes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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

  Future<void> _eliminarCliente(Cliente cliente) async {
    print('Intentando eliminar cliente: ${cliente.toString()}'); // Debug

    if (cliente.idCliente == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: ID del cliente no encontrado')),
        );
      }
      return;
    }

    try {
      await _clienteService.eliminarCliente(cliente.idCliente!);
      if (mounted) {
        setState(() {
          _clientes.removeWhere((c) => c.idCliente == cliente.idCliente);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente eliminado exitosamente')),
        );
      }
    } catch (e) {
      print('Error al eliminar cliente: $e'); // Debug
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el cliente: $e')),
        );
      }
    }
  }

  Future<void> _mostrarDialogoEliminar(Cliente cliente) async {
    print('Mostrando diálogo para eliminar cliente: ${cliente.toString()}'); // Debug

    if (cliente.idCliente == null) {
      print('ID del cliente es nulo'); // Debug
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No se puede eliminar un cliente sin ID')),
        );
      }
      return;
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Está seguro de eliminar al cliente ${cliente.nombres} ${cliente.apellidos}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () {
                Navigator.of(context).pop();
                _eliminarCliente(cliente);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editarCliente(Cliente cliente) async {
    try {
      final resultado = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClienteFormScreen(cliente: cliente),
        ),
      );

      if (resultado != null && resultado is Cliente) {
        setState(() {
          final index = _clientes.indexWhere((c) => c.idCliente == cliente.idCliente);
          if (index != -1) {
            _clientes[index] = resultado;
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cliente actualizado exitosamente')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al editar el cliente: $e')),
        );
      }
    }
  }

  Future<void> _agregarCliente() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ClienteFormScreen(),
      ),
    );

    if (resultado != null) {
      setState(() {
        _clientes.add(resultado as Cliente);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarClientes,
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
                        onPressed: _cargarClientes,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _clientes.isEmpty
                  ? const Center(
                      child: Text('No hay clientes registrados'),
                    )
                  : RefreshIndicator(
                      onRefresh: _cargarClientes,
                      child: ListView.builder(
                        itemCount: _clientes.length,
                        itemBuilder: (context, index) {
                          final cliente = _clientes[index];
                          print('Construyendo item para cliente: ${cliente.toString()}'); // Debug
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: cliente.imagenPerfil != null
                                    ? NetworkImage(cliente.imagenPerfil!)
                                    : null,
                                child: cliente.imagenPerfil == null
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              title: Text(
                                '${cliente.nombres} ${cliente.apellidos}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Correo: ${cliente.correo}'),
                                  Text('Documento: ${cliente.tipoDocumento} - ${cliente.numeroDocumento}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editarCliente(cliente),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _mostrarDialogoEliminar(cliente),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarCliente,
        child: const Icon(Icons.add),
      ),
    );
  }
} 