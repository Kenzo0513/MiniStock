import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_stock/models/producto.dart';
import 'package:mini_stock/services/firestore_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _cantidadController = TextEditingController();
  DateTime? _caducidad;
  final _service = FirestoreService();

  void _guardarProducto() async {
    if (_formKey.currentState!.validate() && _caducidad != null) {
      final producto = Producto(
        id: _service.generarId(),
        codigoBarras: _codigoController.text.trim(),
        nombre: _nombreController.text.trim(),
        precio: double.parse(_precioController.text),
        cantidad: int.parse(_cantidadController.text),
        caducidad: _caducidad!,
      );

      await _service.agregarProducto(producto);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Producto guardado exitosamente")),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _caducidad = picked);
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _precioController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Producto')),
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
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _guardarProducto,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
