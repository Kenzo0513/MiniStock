import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mini_stock/models/producto.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> agregarProducto(Producto p) async {
    await _db.collection('productos').doc(p.id).set(p.toMap());
  }

  Stream<List<Producto>> obtenerProductos() {
    return _db
        .collection('productos')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Producto.fromMap(doc.data())).toList(),
        );
  }
}
