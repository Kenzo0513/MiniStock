import 'package:flutter/material.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Formulario de selección de producto y cantidad
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Venta')),
      body: Center(child: Text('Formulario de venta')),
    );
  }
}
