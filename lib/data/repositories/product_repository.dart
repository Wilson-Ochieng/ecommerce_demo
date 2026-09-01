import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository({
    FirebaseFirestore? firestore,
  }) : _firestore =
          firestore ?? FirebaseFirestore.instance;

  CollectionReference get _products =>
      _firestore.collection('products');

  // CREATE
  Future<void> addProduct(ProductModel product) async {
    final document = _products.doc();

    await document.set({
      ...product.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // READ
  Stream<List<ProductModel>> getProducts() {
    return _products
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ProductModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // UPDATE
  Future<void> updateProduct(ProductModel product) async {
    await _products
        .doc(product.id)
        .update(product.toMap());
  }

  // DELETE
  Future<void> deleteProduct(String productId) async {
    await _products.doc(productId).delete();
  }
}