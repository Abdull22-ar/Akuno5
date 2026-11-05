import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_page.dart';
import 'category_page.dart';
import 'cart_page.dart';
import 'manage_product_page.dart';
import 'profile_page.dart';

class MainShellPage extends StatefulWidget {
  final int initialIndex;

  const MainShellPage({super.key, this.initialIndex = 0});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  late int _currentIndex;
  int _cartCount = 2;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _updateCartBadge();
  }

  Future<void> _updateCartBadge() async {
    try {
      final res = await ApiService.getCart();
      if (!mounted) return;
      setState(() {
        _cartCount = res.items.fold<int>(0, (sum, item) => sum + item.jumlah);
      });
    } catch (_) {}
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    if (index == 2) {
      _updateCartBadge();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onNavigateTab: _onTabTapped),
      const CategoryPage(),
      const CartPage(),
      const ManageProductsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabTapped,
            backgroundColor: Colors.white,
            elevation: 0,
            indicatorColor: const Color(0xFFE8F5E9),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: Color(0xFF2E7D32)),
                label: 'Beranda',
              ),
              const NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded, color: Color(0xFF2E7D32)),
                label: 'Kategori',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: _cartCount > 0,
                  label: Text('$_cartCount'),
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: _cartCount > 0,
                  label: Text('$_cartCount'),
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.shopping_cart, color: Color(0xFF2E7D32)),
                ),
                label: 'Keranjang',
              ),
              const NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long, color: Color(0xFF2E7D32)),
                label: 'Pesanan',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: Color(0xFF2E7D32)),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

