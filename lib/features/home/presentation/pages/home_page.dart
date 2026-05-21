import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lebondeal/features/categories/domain/entities/category.dart';
import 'package:lebondeal/features/deals/data/datasources/remote/firestore_service.dart';
import 'package:lebondeal/features/deals/domain/domain.dart';

import '../../../../../core/widgets/shared/common_widgets.dart';
import '../../../../../core/widgets/shared/lebondeal_logo.dart';
import '../../../../../core/widgets/shared/search_bar.dart' as custom_search;
import '../../../../features/categories/presentation/widgets/category_chip.dart';
import '../../../deals/presentation/pages/add_deal_page.dart';
import '../../../deals/presentation/widgets/deal_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Category? _selectedCategory;
  String _searchQuery = '';
  Set<String> _savedDealIds = {};
  StreamSubscription<Set<String>>? _savedSub;

  Stream<List<Deal>> _dealsStream = FirestoreService.getAllDealsStream();

  @override
  void initState() {
    super.initState();
    _listenToSavedDeals();
  }

  void _listenToSavedDeals() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;
    _savedSub = FirestoreService.getSavedDealIdsStream(user.uid).listen((ids) {
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
          ? FirestoreService.getDealsByCategoryStream(_selectedCategory!.id)
          : FirestoreService.getAllDealsStream();
    });
  }

  List<Deal> _filter(List<Deal> deals) {
    if (_searchQuery.isEmpty) return deals;
    final q = _searchQuery.toLowerCase();
    return deals
        .where(
          (d) =>
              d.title.toLowerCase().contains(q) ||
              d.description.toLowerCase().contains(q) ||
              d.storeName.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> _toggleSave(String dealId, bool isSaved) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;
    await FirestoreService.toggleSavedDeal(user.uid, dealId, isSaved);
  }

  @override
  Widget build(BuildContext context) {
    final categories = FirestoreService.getAllCategories();

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
                    custom_search.SearchBar(
                      onSearch: (q) => setState(() => _searchQuery = q),
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
                _dealsStream = FirestoreService.getAllDealsStream();
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
