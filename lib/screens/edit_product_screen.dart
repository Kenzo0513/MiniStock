import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_stock/models/producto.dart';
import 'package:mini_stock/services/firestore_service.dart';

class EditProductScreen extends StatefulWidget {
  final Producto producto;

  const EditProductScreen({super.key, required this.producto});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codigoController;
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late TextEditingController _cantidadController;
  DateTime? _caducidad;
  final _service = FirestoreService();

  @override
  void initState() {
    super.initState();
    _codigoController = TextEditingController(
      text: widget.producto.codigoBarras,
    );
    _nombreController = TextEditingController(text: widget.producto.nombre);
    _precioController = TextEditingController(
      text: widget.producto.precio.toString(),
    );
    _cantidadController = TextEditingController(
      text: widget.producto.cantidad.toString(),
    );
    _caducidad = widget.producto.caducidad;
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _precioController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  void _guardarCambios() async {
    if (_formKey.currentState!.validate() && _caducidad != null) {
      final productoActualizado = Producto(
        id: widget.producto.id,
        codigoBarras: _codigoController.text.trim(),
        nombre: _nombreController.text.trim(),
        precio: double.tryParse(_precioController.text) ?? 0,
        cantidad: int.tryParse(_cantidadController.text) ?? 0,
        caducidad: _caducidad!,
      );

      try {
        await _service.actualizarProducto(productoActualizado);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Producto actualizado correctamente')),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al actualizar producto: $e')),
        );
      }
    }
  }

  void _confirmarEliminar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este producto? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Cierra el diálogo
              await _service.eliminarProducto(widget.producto.id);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🗑️ Producto eliminado')),
              );
              Navigator.pop(context); // Cierra la pantalla de edición
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _caducidad ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _caducidad = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmarEliminar,
            tooltip: 'Eliminar producto',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(
                  labelText: 'Código de barras',
                ),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                ),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _cantidadController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _seleccionarFecha,
                child: Text(
                  _caducidad == null
                      ? 'Seleccionar Fecha de Caducidad'
                      : 'Caducidad: ${DateFormat.yMd().format(_caducidad!)}',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _guardarCambios,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
