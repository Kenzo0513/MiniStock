import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mini_stock/models/producto.dart';
import 'package:mini_stock/models/venta.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // Agregar producto
  Future<void> agregarProducto(Producto p) async {
    await _db.collection('productos').doc(p.id).set(p.toMap());
  }

  // Obtener productos en tiempo real
  Stream<List<Producto>> obtenerProductos() {
    return _db
        .collection('productos')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Producto.fromMap(doc.data())).toList(),
        );
  }

  // Registrar venta
  Future<void> registrarVenta(Venta venta) async {
    await _db.collection('ventas').doc(venta.id).set(venta.toMap());

    // Opcional: Actualizar cantidad del producto
    final productoRef = _db.collection('productos').doc(venta.productoId);
    final productoSnapshot = await productoRef.get();
    if (productoSnapshot.exists) {
      final data = productoSnapshot.data()!;
      final cantidadActual = data['cantidad'] as int;
      final nuevaCantidad = cantidadActual - venta.cantidadVendida;
      await productoRef.update({'cantidad': nuevaCantidad});
    }
  }

  // Obtener ventas por día
  Future<List<Venta>> obtenerVentasDelDia(DateTime fecha) async {
    final inicio = DateTime(fecha.year, fecha.month, fecha.day);
    final fin = inicio.add(const Duration(days: 1));

    final snapshot = await _db
        .collection('ventas')
        .where('fecha', isGreaterThanOrEqualTo: inicio.toIso8601String())
        .where('fecha', isLessThan: fin.toIso8601String())
        .get();

    return snapshot.docs.map((doc) => Venta.fromMap(doc.data())).toList();
  }

  // Calcular total de ventas del día
  Future<double> totalVentasDelDia(DateTime fecha) async {
    final ventas = await obtenerVentasDelDia(fecha);
    return ventas.fold(0.0, (total, v) => total + v.total);
  }

  // Generar ID único (para productos o ventas)
  String generarId() => _uuid.v4();
}
