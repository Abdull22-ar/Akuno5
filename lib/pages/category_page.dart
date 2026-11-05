import 'package:flutter/material.dart';
import '../widgets/agrimart_logo.dart';
import 'manage_product_page.dart';

class CategoryPage extends StatelessWidget {
  final bool showBackButton;

  const CategoryPage({super.key, this.showBackButton = false});

  final List<Map<String, dynamic>> _categories = const [
    {
      'title': 'Produk Pertanian',
      'icon': Icons.eco,
      'color': Color(0xFF2E7D32),
      'bgColor': Color(0xFFE8F5E9),
      'filter': 'Sayuran',
    },
    {
      'title': 'Sembako',
      'icon': Icons.shopping_bag_outlined,
      'color': Color(0xFFE65100),
      'bgColor': Color(0xFFFFF3E0),
      'filter': 'Beras & Biji-bijian',
    },
    {
      'title': 'Buah & Sayur',
      'icon': Icons.lunch_dining_outlined,
      'color': Color(0xFFC62828),
      'bgColor': Color(0xFFFFEBEE),
      'filter': 'Buah-buahan',
    },
    {
      'title': 'Peralatan Pertanian',
      'icon': Icons.agriculture,
      'color': Color(0xFF00695C),
      'bgColor': Color(0xFFE0F2F1),
      'filter': 'Umbi-umbian',
    },
    {
      'title': 'Produk Olahan',
      'icon': Icons.soup_kitchen_outlined,
      'color': Color(0xFFF57F17),
      'bgColor': Color(0xFFFFFDE7),
      'filter': 'Bumbu & Rempah',
    },
    {
      'title': 'Kebutuhan Harian',
      'icon': Icons.sanitizer_outlined,
      'color': Color(0xFF1565C0),
      'bgColor': Color(0xFFE3F2FD),
      'filter': 'Semua',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF5),
      appBar: AppBar(
        title: const Text(
          'Kategori',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0.5,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageProductsPage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Lanskap perbukitan hijau di bagian bawah
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: size.height * 0.18,
            child: CustomPaint(
              painter: FarmLandscapePainter(
                hillColor1: const Color(0xFFC8E6C9),
                hillColor2: const Color(0xFFA5D6A7),
                hillColor3: const Color(0xFF4CAF50),
              ),
            ),
          ),

          // Rumah kebun kecil di perbukitan bawah
          Positioned(
            bottom: size.height * 0.08,
            right: 32,
            child: const Icon(
              Icons.cottage,
              size: 38,
              color: Color(0xFF2E7D32),
            ),
          ),

          // Grid Kategori 2 Kolom Sesuai Desain
          GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.05,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageProductsPage(),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: cat['bgColor'] as Color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          cat['icon'] as IconData,
                          size: 34,
                          color: cat['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        cat['title'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

