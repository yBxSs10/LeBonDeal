import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lebondeal/features/deals/domain/domain.dart';
import 'package:lebondeal/features/categories/domain/entities/category.dart';
import 'package:lebondeal/features/deals/data/datasources/remote/data_service.dart';
import '../../../../../core/widgets/shared/lebondeal_logo.dart';
import '../../../deals/presentation/widgets/deal_card.dart';
import '../../../../features/categories/presentation/widgets/category_chip.dart';
import '../../../../../core/widgets/shared/search_bar.dart' as custom_search;
import '../../../deals/presentation/pages/add_deal_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Category? _selectedCategory;
  String _searchQuery = '';
  final List<String> _savedDealIds = ['1', '3', '5'];

  void _refreshDeals() {
    setState(() {
      // Reset category filter to show all deals including the newly added one
      _selectedCategory = null;
    });
  }

  List<Deal> _getFilteredDeals() {
    final categories = DataService.getAllCategories();
    if (categories.isEmpty) return [];

    List<Deal> deals;
    if (_selectedCategory != null) {
      deals = DataService.getDealsByCategory(_selectedCategory!.id);
    } else {
      // When no category is selected, show all deals to ensure new deals appear
      deals = DataService.getAllDeals();
    }

    if (_searchQuery.isNotEmpty) {
      deals = DataService.searchDeals(_searchQuery);
    }

    return deals;
  }

  @override
  Widget build(BuildContext context) {
    final deals = _getFilteredDeals();
    final categories = DataService.getAllCategories();

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
                      onSearch: (query) => setState(() => _searchQuery = query),
                    ),
                    const SizedBox(height: 16),
                    _buildCategoriesSection(categories),
                    const SizedBox(height: 24),
                    _buildDealsHeader(),
                  ],
                ),
              ),
            ),
            if (deals.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('Aucun deal trouvé')),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final deal = deals[index];
                  final isSaved = _savedDealIds.contains(deal.id);

                  return DealCard(
                    deal: deal,
                    isSaved: isSaved,
                    onSave: () => _toggleSave(deal.id, isSaved),
                  );
                }, childCount: deals.length),
              ),
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
              final category = categories[index];
              final isSelected = _selectedCategory?.id == category.id;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CategoryChip(
                  category: category,
                  isSelected: isSelected,
                  onTap: () => setState(() {
                    _selectedCategory = isSelected ? null : category;
                  }),
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

  void _toggleSave(String dealId, bool isSaved) {
    setState(() {
      if (isSaved) {
        _savedDealIds.remove(dealId);
      } else {
        _savedDealIds.add(dealId);
      }
    });
  }

  Widget? _buildFab() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return null;

    return FloatingActionButton(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddDealPage(onDealAdded: _refreshDeals),
        ),
      ),
      child: const Icon(Icons.add),
    );
  }
}
