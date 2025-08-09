import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mini_stock/models/producto.dart';
import 'package:mini_stock/models/venta.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  FirestoreService() {
    // ✅ Habilitar persistencia offline (Firestore guarda datos localmente)
    _db.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // Sin límite de caché
    );
  }

  // 📌 Agregar producto (funciona offline, se sincroniza al volver conexión)
  Future<void> agregarProducto(Producto p) async {
    await _db.collection('productos').doc(p.id).set(p.toMap());
  }

  // 📌 Actualizar producto
  Future<void> actualizarProducto(Producto producto) async {
    await _db.collection('productos').doc(producto.id).update(producto.toMap());
  }

  // 📌 Eliminar producto
  Future<void> eliminarProducto(String id) async {
    await _db.collection('productos').doc(id).delete();
  }

  // 📌 Obtener productos (incluye metadatos para detectar modo offline)
  Stream<QuerySnapshot<Map<String, dynamic>>> obtenerProductosConMetadata() {
    return _db.collection('productos').snapshots(includeMetadataChanges: true);
  }

  // 📌 Obtener productos (versión simple en List<Producto>)
  Stream<List<Producto>> obtenerProductos() {
    return _db
        .collection('productos')
        .snapshots(includeMetadataChanges: true)
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Producto.fromMap(doc.data())).toList(),
        );
  }

  // 📌 Registrar venta y actualizar stock (funciona offline)
  Future<void> registrarVenta(Venta venta) async {
    await _db.collection('ventas').doc(venta.id).set(venta.toMap());

    final productoRef = _db.collection('productos').doc(venta.productoId);
    final productoSnapshot = await productoRef.get();
    if (productoSnapshot.exists) {
      final data = productoSnapshot.data()!;
      final cantidadActual = data['cantidad'] as int;
      final nuevaCantidad = cantidadActual - venta.cantidadVendida;
      await productoRef.update({'cantidad': nuevaCantidad});
    }
  }

  // 📌 Obtener ventas por día (prioriza caché, luego red)
  Future<List<Venta>> obtenerVentasDelDia(DateTime fecha) async {
    final inicio = DateTime(fecha.year, fecha.month, fecha.day);
    final fin = inicio.add(const Duration(days: 1));

    try {
      // Intentar primero desde caché
      final snapshot = await _db
          .collection('ventas')
          .where('fecha', isGreaterThanOrEqualTo: inicio.toIso8601String())
          .where('fecha', isLessThan: fin.toIso8601String())
          .get(const GetOptions(source: Source.cache));

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => Venta.fromMap(doc.data())).toList();
      }
    } catch (_) {}

    // Si no hay en caché o hay error, buscar en la nube
    final snapshot = await _db
        .collection('ventas')
        .where('fecha', isGreaterThanOrEqualTo: inicio.toIso8601String())
        .where('fecha', isLessThan: fin.toIso8601String())
        .get();

    return snapshot.docs.map((doc) => Venta.fromMap(doc.data())).toList();
  }

  // 📌 Calcular total de ventas del día
  Future<double> totalVentasDelDia(DateTime fecha) async {
    final ventas = await obtenerVentasDelDia(fecha);
    return ventas.fold<double>(0.0, (total, v) => total + v.total);
  }

  // 📌 Generar ID único
  String generarId() => _uuid.v4();
}
