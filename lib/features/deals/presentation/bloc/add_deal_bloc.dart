import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../../categories/domain/entities/category.dart';
import '../../domain/entities/deal.dart';
import '../../data/datasources/remote/data_service.dart';

class AddDealBloc extends ChangeNotifier {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String? _selectedCategoryId;
  bool _isSubmitting = false;
  List<Category> _categories = [];

  // Getters
  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get titleController => _titleController;
  TextEditingController get descriptionController => _descriptionController;
  TextEditingController get priceController => _priceController;
  TextEditingController get originalPriceController => _originalPriceController;
  TextEditingController get storeNameController => _storeNameController;
  TextEditingController get imageUrlController => _imageUrlController;
  String? get selectedCategoryId => _selectedCategoryId;
  bool get isSubmitting => _isSubmitting;
  List<Category> get categories => _categories;

  AddDealBloc() {
    _initializeCategories();
  }

  void _initializeCategories() {
    _categories = DataService.getAllCategories();
    if (_categories.isNotEmpty) {
      _selectedCategoryId = _categories.first.id;
    }
    notifyListeners();
  }

  void updateCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  Deal createDealFromForm() {
    final price = double.parse(_priceController.text.trim());
    final originalPriceText = _originalPriceController.text.trim();
    final originalPrice = originalPriceText.isNotEmpty
        ? double.parse(originalPriceText)
        : price;
    final discountPercent = originalPrice > 0
        ? ((originalPrice - price) / originalPrice * 100).round()
        : 0;

    final user = auth.FirebaseAuth.instance.currentUser!;
    
    return Deal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? 'https://via.placeholder.com/300x200'
          : _imageUrlController.text.trim(),
      storeName: _storeNameController.text.trim(),
      price: price,
      originalPrice: originalPrice,
      discountPercent: discountPercent,
      author: user.displayName ?? 'Utilisateur actuel',
      authorId: user.uid,
      publishedHoursAgo: 0,
      badge: discountPercent > 50 ? 'HOT' : 'NEW',
      comments: 0,
      favorites: 0,
      shares: 0,
      categoryId: _selectedCategoryId!,
    );
  }

  Future<void> submitDeal(VoidCallback? onDealAdded) async {
    if (!validateForm()) return;

    final user = auth.FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      throw Exception('Utilisateur non connecté');
    }

    if (_selectedCategoryId == null) {
      throw Exception('Veuillez sélectionner une catégorie');
    }

    setSubmitting(true);

    try {
      final newDeal = createDealFromForm();
      DataService.addDeal(newDeal);
      onDealAdded?.call();
    } finally {
      setSubmitting(false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _storeNameController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
