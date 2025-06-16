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
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  
  String? _selectedTipoDocumento;
  final List<String> _tiposDocumento = ["DNI", "Pasaporte", "Carné"];

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

  List<Cliente> get _filteredClientes {
    return _clientes.where((cliente) {
      final nombreMatch = cliente.nombres?.toLowerCase().contains(_nombreController.text.toLowerCase()) ?? false;
      final apellidoMatch = cliente.apellidos?.toLowerCase().contains(_apellidoController.text.toLowerCase()) ?? false;
      final documentoMatch = cliente.numeroDocumento?.toLowerCase().contains(_documentoController.text.toLowerCase()) ?? false;
      final correoMatch = cliente.correo?.toLowerCase().contains(_correoController.text.toLowerCase()) ?? false;
      final direccionMatch = cliente.direccion?.toLowerCase().contains(_direccionController.text.toLowerCase()) ?? false;
      final tipoDocumentoMatch = _selectedTipoDocumento == null || cliente.tipoDocumento == _selectedTipoDocumento;

      return nombreMatch && 
             apellidoMatch && 
             documentoMatch && 
             correoMatch && 
             direccionMatch && 
             tipoDocumentoMatch;
    }).toList();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _documentoController.dispose();
    _correoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Clientes'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Filtros de búsqueda
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar por nombre',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _apellidoController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar por apellido',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedTipoDocumento,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Documento',
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Todos'),
                    ),
                    ..._tiposDocumento.map((tipo) => DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
                    )),
                  ],
                  onChanged: (value) => setState(() => _selectedTipoDocumento = value),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _documentoController,
                  decoration: const InputDecoration(
                    labelText: 'Número de Documento',
                    prefixIcon: Icon(Icons.numbers),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _correoController,
                  decoration: const InputDecoration(
                    labelText: 'Correo',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _direccionController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ],
            ),
          ),
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
                              onPressed: _cargarClientes,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : _filteredClientes.isEmpty
                        ? const Center(
                            child: Text('No hay clientes registrados'),
                          )
                        : RefreshIndicator(
                            onRefresh: _cargarClientes,
                            child: ListView.builder(
                              itemCount: _filteredClientes.length,
                              itemBuilder: (context, index) {
                                final cliente = _filteredClientes[index];
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarCliente,
        child: const Icon(Icons.add),
      ),
    );
  }
} 