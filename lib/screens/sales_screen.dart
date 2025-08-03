import 'package:flutter/material.dart';
import 'package:mini_stock/models/producto.dart';
import 'package:mini_stock/models/venta.dart';
import 'package:mini_stock/services/firestore_service.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final _formKey = GlobalKey<FormState>();
  Producto? _productoSeleccionado;
  int _cantidadVendida = 1;
  final _firestore = FirestoreService();

  void _registrarVenta() async {
    if (_productoSeleccionado == null || _cantidadVendida <= 0) return;

    if (_cantidadVendida > _productoSeleccionado!.cantidad) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cantidad excede el inventario disponible'),
        ),
      );
      return;
    }

    final venta = Venta(
      id: _firestore.generarId(),
      productoId: _productoSeleccionado!.id,
      nombreProducto: _productoSeleccionado!.nombre,
      cantidadVendida: _cantidadVendida,
      total: _productoSeleccionado!.precio * _cantidadVendida,
      fecha: DateTime.now(),
    );

    await _firestore.registrarVenta(venta);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Venta registrada exitosamente')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Venta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              StreamBuilder<List<Producto>>(
                stream: _firestore.obtenerProductos(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final productos = snapshot.data!;
                  return DropdownButtonFormField<Producto>(
                    hint: const Text('Seleccionar producto'),
                    value: _productoSeleccionado,
                    items: productos.map((producto) {
                      return DropdownMenuItem(
                        value: producto,
                        child: Text(
                          '${producto.nombre} (Disp: ${producto.cantidad})',
                        ),
                      );
                    }).toList(),
                    onChanged: (nuevo) =>
                        setState(() => _productoSeleccionado = nuevo),
                    validator: (value) =>
                        value == null ? 'Selecciona un producto' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Cantidad vendida',
                ),
                keyboardType: TextInputType.number,
                initialValue: '1',
                validator: (value) =>
                    (value == null ||
                        int.tryParse(value) == null ||
                        int.parse(value) <= 0)
                    ? 'Cantidad inválida'
                    : null,
                onChanged: (value) =>
                    _cantidadVendida = int.tryParse(value) ?? 1,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) _registrarVenta();
                },
                icon: const Icon(Icons.sell),
                label: const Text('Registrar Venta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
