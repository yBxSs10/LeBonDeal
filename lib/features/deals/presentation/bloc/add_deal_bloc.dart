import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

import 'package:lebondeal/core/di/injection.dart';
import 'package:lebondeal/features/categories/domain/entities/category.dart';
import 'package:lebondeal/features/deals/data/datasources/remote/firestore_service.dart';
import 'package:lebondeal/features/deals/domain/entities/deal.dart';
import 'package:lebondeal/features/deals/domain/services/spam_detector.dart';

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
    _categories = getIt<FirestoreService>().getAllCategories();
    if (_categories.isNotEmpty) _selectedCategoryId = _categories.first.id;
  }

  void updateCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  bool validateForm() => _formKey.currentState?.validate() ?? false;

  Deal _buildDeal() {
    final price = double.parse(_priceController.text.trim());
    final origText = _originalPriceController.text.trim();
    final originalPrice = origText.isNotEmpty ? double.parse(origText) : price;
    final discountPercent = originalPrice > price
        ? ((originalPrice - price) / originalPrice * 100).round()
        : 0;
    final user = auth.FirebaseAuth.instance.currentUser!;

    return Deal(
      id: '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? 'https://via.placeholder.com/300x200'
          : _imageUrlController.text.trim(),
      storeName: _storeNameController.text.trim(),
      price: price,
      originalPrice: originalPrice,
      discountPercent: discountPercent,
      author: user.displayName ?? 'Utilisateur',
      authorId: user.uid,
      publishedHoursAgo: 0,
      badge: discountPercent > 50 ? 'HOT' : 'NEW',
      comments: 0,
      favorites: 0,
      shares: 0,
      categoryId: _selectedCategoryId!,
    );
  }

  Future<void> submitDeal([VoidCallback? onDealAdded]) async {
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
      final deal = _buildDeal();
      final dealRef = await getIt<FirestoreService>().addDeal(deal);
      await _flagIfSuspicious(dealRef.id, deal, user.uid);
      onDealAdded?.call();
    } finally {
      setSubmitting(false);
    }
  }

  /// Détection automatique (SEC — anti-spam) : un deal suspect est publié
  /// normalement mais signalé pour revue par un modérateur, plutôt que
  /// bloqué — un faux positif ne doit pas empêcher un auteur légitime de
  /// publier. Best-effort : ne fait jamais échouer la publication.
  Future<void> _flagIfSuspicious(
    String dealId,
    Deal deal,
    String authorId,
  ) async {
    final check = SpamDetector.check(
      title: deal.title,
      description: deal.description,
    );
    if (!check.isSuspicious) return;

    try {
      await getIt<FirestoreService>().createReport(
        targetId: dealId,
        targetType: 'deal',
        targetTitle: deal.title,
        reason: 'Détection automatique — ${check.reasons.join(' ; ')}',
        authorId: authorId,
      );
    } catch (_) {
      // Best-effort.
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
