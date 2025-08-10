import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_stock/models/producto.dart';
import 'package:mini_stock/services/firestore_service.dart';
import 'barcode_scanner_screen.dart';

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
  bool _guardando = false;

  void _guardarProducto() async {
    if (_formKey.currentState!.validate() && _caducidad != null) {
      setState(() => _guardando = true);

      final producto = Producto(
        id: _service.generarId(),
        codigoBarras: _codigoController.text.trim(),
        nombre: _nombreController.text.trim(),
        precio:
            double.tryParse(_precioController.text.replaceAll(',', '.')) ?? 0,
        cantidad: int.tryParse(_cantidadController.text) ?? 0,
        caducidad: _caducidad!,
      );

      try {
        await _service.agregarProducto(producto);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Producto registrado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al registrar producto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _guardando = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Completa todos los campos y selecciona caducidad'),
          backgroundColor: Colors.orange,
        ),
      );
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

  InputDecoration _inputStyle(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
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
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        title: const Text('Registrar Producto'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _codigoController,
                    decoration: _inputStyle(
                      'Código de barras',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BarcodeScannerScreen(
                                onDetect: (codigo) {
                                  _codigoController.text = codigo;
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nombreController,
                    decoration: _inputStyle('Nombre del producto'),
                    validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _precioController,
                    decoration: _inputStyle('Precio'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _cantidadController,
                    decoration: _inputStyle('Cantidad'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _seleccionarFecha,
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _caducidad == null
                          ? 'Seleccionar Fecha de Caducidad'
                          : 'Caducidad: ${DateFormat.yMd().format(_caducidad!)}',
                    ),
                  ),
                  const SizedBox(height: 20),
                  _guardando
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _guardarProducto,
                          icon: const Icon(Icons.save),
                          label: const Text(
                            'Guardar Producto',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
