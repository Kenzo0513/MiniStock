import 'package:flutter/material.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Usar StreamBuilder para obtener productos
    return Scaffold(
      appBar: AppBar(title: const Text('Inventario')),
      body: Center(child: Text('Lista de productos aquí')),
    );
  }
}
