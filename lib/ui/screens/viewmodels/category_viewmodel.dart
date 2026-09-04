import 'package:flutter/foundation.dart';

import '../../../data/models/ category_model.dart';
import '../../../data/repositories/category_repository.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryRepository _repository;

  CategoryViewModel({required CategoryRepository repository})
    : _repository = repository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Stream<List<CategoryModel>> get categories {
    return _repository.getCategories();
  }

  Future<bool> addCategory(String name) async {
    _startLoading();

    try {
      await _repository.addCategory(name);

      _errorMessage = null;

      return true;
    } catch (e) {
      _errorMessage = _handleError(e);

      return false;
    } finally {
      _stopLoading();
    }
  }

  Future<bool> updateCategory(String categoryId, String name) async {
    _startLoading();

    try {
      await _repository.updateCategory(categoryId, name);

      _errorMessage = null;

      return true;
    } catch (e) {
      _errorMessage = _handleError(e);

      return false;
    } finally {
      _stopLoading();
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    _startLoading();

    try {
      await _repository.deleteCategory(categoryId);

      _errorMessage = null;

      return true;
    } catch (e) {
      _errorMessage = _handleError(e);

      return false;
    } finally {
      _stopLoading();
    }
  }

  void _startLoading() {
    _errorMessage = null;
    _isLoading = true;

    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;

    notifyListeners();
  }

  String _handleError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
