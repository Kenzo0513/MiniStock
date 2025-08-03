import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Consultar y mostrar total de ventas del día
    return Scaffold(
      appBar: AppBar(title: const Text('Reporte Diario')),
      body: Center(child: Text('Reporte de ventas del día')),
    );
  }
}
