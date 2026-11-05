import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'pages/cart_page.dart';
import 'pages/manage_product_page.dart';
import 'pages/product_form_page.dart';
import 'pages/main_shell_page.dart';
import 'services/api_service.dart';

void main() {
  runApp(const TokoTaniApp());
}

class TokoTaniApp extends StatelessWidget {
  final Widget? home;

  const TokoTaniApp({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriMart - Belanja Cerdas, Dukung Pertanian',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7FAF5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E293B),
          elevation: 0.5,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Default: Masuk ke alur Splash AgriMart sesuai desain UI/UX
      home: home ?? const SplashPage(),
    );
  }
}

/// Halaman evaluasi dan navigasi cepat pengujian tugas Anggota 5 (Frontend)
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'TokoTani',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MainShellPage()),
              );
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone_android, size: 16),
                SizedBox(width: 4),
                Text('AgriMart UI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner Identitas Bagian 5
          Card(
            color: Colors.green.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.green.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment_ind, color: Colors.green.shade800),
                      const SizedBox(width: 8),
                      Text(
                        'Bagian Anggota 5: Frontend',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tugas: Halaman Keranjang Belanja (Subtotal server & Galat 409) '
                    'serta Halaman Kelola Produk (CRUD Produk Pertanian Lengkap).',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  // Toggle Mode API Real (Jalur A) vs Mock (Jalur B)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              ApiService.useMock ? Icons.science_outlined : Icons.cloud_done_outlined,
                              size: 18,
                              color: ApiService.useMock ? Colors.orange.shade800 : Colors.green.shade800,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              ApiService.useMock ? 'Mode: Data Tiruan (Jalur B)' : 'Mode: REST API Laravel (Jalur A)',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Switch(
                          value: ApiService.useMock,
                          activeThumbColor: const Color(0xFF2E7D32),
                          onChanged: (val) {
                            setState(() {
                              ApiService.useMock = val;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  val
                                      ? 'Beralih ke Jalur B (Data Tiruan Offline)'
                                      : 'Beralih ke Jalur A (Server Laravel ${ApiService.baseUrl})',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            'Menu Navigasi Tugas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),

          // Menu 1: Keranjang Belanja
          _MenuCard(
            icon: Icons.shopping_cart_outlined,
            title: 'Keranjang Belanja',
            subtitle: 'Membaca subtotal server, ubah kuantitas, hapus item, dan notifikasi galat 409.',
            badgeText: 'Subtotal Server',
            badgeColor: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartPage(showBackButton: true)),
            ),
          ),
          const SizedBox(height: 12),

          // Menu 2: Kelola Produk
          _MenuCard(
            icon: Icons.inventory_2_outlined,
            title: 'Kelola Produk (CRUD)',
            subtitle: 'Daftar produk dengan pencarian/kategori server, tombol ubah & hapus (galat 409).',
            badgeText: 'CRUD Lengkap',
            badgeColor: Colors.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageProductsPage()),
            ),
          ),
          const SizedBox(height: 12),

          // Menu 3: Tambah Produk Baru
          _MenuCard(
            icon: Icons.add_box_outlined,
            title: 'Tambah Produk Baru',
            subtitle: 'Formulir produk dengan validasi per kolom 422 dan atribut domain pertanian.',
            badgeText: 'Validasi 422',
            badgeColor: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductFormPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badgeText;
  final MaterialColor badgeColor;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.green.shade50,
                child: Icon(icon, color: Colors.green.shade800),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: badgeColor.shade200),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: badgeColor.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
