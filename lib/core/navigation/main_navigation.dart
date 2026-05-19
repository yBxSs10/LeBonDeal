import 'package:flutter/material.dart';
import 'package:lebondeal/features/deals/presentation/pages/trending_page.dart';
import 'package:lebondeal/features/deals/presentation/pages/saved_deals_page.dart';
import 'package:lebondeal/features/profile/presentation/pages/profile_page.dart';
import 'package:lebondeal/features/home/presentation/pages/home_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const TrendingPage(),
    const SavedDealsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Tendances',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Sauvegardés',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
