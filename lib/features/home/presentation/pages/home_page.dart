import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lebondeal/core/di/injection.dart';
import 'package:lebondeal/features/categories/domain/domain.dart';
import 'package:lebondeal/features/deals/data/datasources/remote/firestore_service.dart';
import 'package:lebondeal/features/deals/domain/domain.dart';

import 'package:lebondeal/core/widgets/shared/common_widgets.dart';
import 'package:lebondeal/core/widgets/shared/lebondeal_logo.dart';
import 'package:lebondeal/core/widgets/shared/search_bar.dart' as custom_search;
import 'package:lebondeal/features/categories/presentation/widgets/category_chip.dart';
import 'package:lebondeal/features/deals/presentation/pages/add_deal_page.dart';
import 'package:lebondeal/features/deals/presentation/widgets/deal_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Category? _selectedCategory;
  String _searchQuery = '';
  double? _minPrice;
  double? _maxPrice;
  Set<String> _savedDealIds = {};
  StreamSubscription<Set<String>>? _savedSub;

  late Stream<List<Deal>> _dealsStream;

  @override
  void initState() {
    super.initState();
    _dealsStream = getIt<FirestoreService>().getAllDealsStream();
    _listenToSavedDeals();
  }

  void _listenToSavedDeals() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;
    _savedSub = getIt<FirestoreService>()
        .getSavedDealIdsStream(user.uid)
        .listen((ids) {
          if (mounted) setState(() => _savedDealIds = ids);
        });
  }

  @override
  void dispose() {
    _savedSub?.cancel();
    super.dispose();
  }

  void _onCategorySelected(Category category) {
    final alreadySelected = _selectedCategory?.id == category.id;
    setState(() {
      _selectedCategory = alreadySelected ? null : category;
      _dealsStream = _selectedCategory != null
          ? getIt<FirestoreService>().getDealsByCategoryStream(
              _selectedCategory!.id,
            )
          : getIt<FirestoreService>().getAllDealsStream();
    });
  }

  List<Deal> _filter(List<Deal> deals) {
    var result = deals;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (d) =>
                d.title.toLowerCase().contains(q) ||
                d.description.toLowerCase().contains(q) ||
                d.storeName.toLowerCase().contains(q),
          )
          .toList();
    }

    if (_minPrice != null) {
      result = result.where((d) => d.price >= _minPrice!).toList();
    }
    if (_maxPrice != null) {
      result = result.where((d) => d.price <= _maxPrice!).toList();
    }

    return result;
  }

  bool get _hasPriceFilter => _minPrice != null || _maxPrice != null;

  Future<void> _showPriceFilterDialog() async {
    final minController = TextEditingController(
      text: _minPrice?.toStringAsFixed(0) ?? '',
    );
    final maxController = TextEditingController(
      text: _maxPrice?.toStringAsFixed(0) ?? '',
    );

    final apply = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrer par prix'),
        content: Row(
          children: [
            Expanded(
              child: TextField(
                controller: minController,
                keyboardType: const TextInputType.numberWithOptions(),
                decoration: const InputDecoration(labelText: 'Min (€)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: maxController,
                keyboardType: const TextInputType.numberWithOptions(),
                decoration: const InputDecoration(labelText: 'Max (€)'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              minController.clear();
              maxController.clear();
              Navigator.of(context).pop(true);
            },
            child: const Text('Réinitialiser'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );

    if (apply == true) {
      setState(() {
        _minPrice = double.tryParse(minController.text.trim());
        _maxPrice = double.tryParse(maxController.text.trim());
      });
    }
  }

  Future<void> _toggleSave(String dealId, bool isSaved) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;
    await getIt<FirestoreService>().toggleSavedDeal(user.uid, dealId, isSaved);
  }

  @override
  Widget build(BuildContext context) {
    final categories = GetAllCategoriesUseCase(getIt<CategoryRepository>())();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: custom_search.SearchBar(
                            onSearch: (q) => setState(() => _searchQuery = q),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Semantics(
                          label: _hasPriceFilter
                              ? 'Filtre de prix actif, ${_minPrice?.toStringAsFixed(0) ?? '0'}€ à ${_maxPrice?.toStringAsFixed(0) ?? '∞'}€'
                              : 'Filtrer par prix',
                          button: true,
                          child: IconButton(
                            icon: Icon(
                              Icons.filter_alt,
                              color: _hasPriceFilter
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[600],
                            ),
                            onPressed: _showPriceFilterDialog,
                          ),
                        ),
                      ],
                    ),
                    if (_hasPriceFilter)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: InputChip(
                          label: Text(
                            'Prix : ${_minPrice?.toStringAsFixed(0) ?? '0'}€ - ${_maxPrice?.toStringAsFixed(0) ?? '∞'}€',
                          ),
                          onDeleted: () => setState(() {
                            _minPrice = null;
                            _maxPrice = null;
                          }),
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildCategoriesSection(categories),
                    const SizedBox(height: 24),
                    _buildDealsHeader(),
                  ],
                ),
              ),
            ),
            _buildDealsList(),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: const LebonDealLogo(height: 40),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.1),
    );
  }

  Widget _buildCategoriesSection(List<Category> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catégories',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CategoryChip(
                  category: cat,
                  isSelected: _selectedCategory?.id == cat.id,
                  onTap: () => _onCategorySelected(cat),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDealsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Deals populaires',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: () {}, child: const Text('Voir tout')),
      ],
    );
  }

  Widget _buildDealsList() {
    return StreamBuilder<List<Deal>>(
      stream: _dealsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(child: LoadingWidget());
        }
        if (snapshot.hasError) {
          return SliverFillRemaining(
            child: CustomErrorWidget(
              message: 'Erreur de chargement',
              onRetry: () => setState(() {
                _dealsStream = getIt<FirestoreService>().getAllDealsStream();
              }),
            ),
          );
        }

        final deals = _filter(snapshot.data ?? []);

        if (deals.isEmpty) {
          return const SliverFillRemaining(
            child: EmptyStateWidget(
              message: 'Aucun deal trouvé',
              icon: Icons.search_off,
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final deal = deals[index];
            final isSaved = _savedDealIds.contains(deal.id);
            return DealCard(
              deal: deal,
              isSaved: isSaved,
              onSave: () => _toggleSave(deal.id, isSaved),
            );
          }, childCount: deals.length),
        );
      },
    );
  }

  Widget? _buildFab() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return null;

    return Semantics(
      label: 'Publier un nouveau deal',
      button: true,
      child: FloatingActionButton(
        tooltip: 'Publier un deal',
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddDealPage())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
