import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore;

  ProductService({
    FirebaseFirestore? firestore,
  }) : _firestore =
           firestore ?? FirebaseFirestore.instance;

  CollectionReference get _products =>
      _firestore.collection('products');

  // CREATE PRODUCT

  Future<void> addProduct(
    ProductModel product,
  ) async {
    await _products.doc(product.id).set(
      product.toMap(),
    );
  }

  // READ PRODUCTS

  Stream<List<ProductModel>> getProducts() {
    return _products
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) =>
                    ProductModel.fromMap(
                  document.data()
                      as Map<String, dynamic>,
                  document.id,
                ),
              )
              .toList(),
        );
  }

  // UPDATE PRODUCT

  Future<void> updateProduct(
    ProductModel product,
  ) async {
    await _products.doc(product.id).update(
      product.toMap(),
    );
  }

  // DELETE PRODUCT

  Future<void> deleteProduct(
    String productId,
  ) async {
    await _products.doc(productId).delete();
  }
}