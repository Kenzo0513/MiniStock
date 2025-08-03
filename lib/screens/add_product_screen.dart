import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _caducidad = picked);
    }
  }

  void _guardarProducto() {
    if (_formKey.currentState!.validate() && _caducidad != null) {
      // TODO: Conectar con FirestoreService para guardar el producto
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Producto registrado exitosamente")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
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
                  labelText: 'Código de Barras',
                ),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                ),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _precioController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _cantidadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _selectDate,
                child: Text(
                  _caducidad == null
                      ? 'Seleccionar Fecha de Caducidad'
                      : 'Caduca: ${DateFormat.yMd().format(_caducidad!)}',
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
