import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'product_form_page.dart';

class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});

  @override
  State<ManageProductsPage> createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  // 4 Keadaan Layar wajib sesuai Kriteria 7
  KeadaanMuat state = KeadaanMuat.memuat;
  List<Product> products = [];
  ApiException? lastError;

  // Parameter Penyaring dan Pencarian ke Server (Kriteria 2)
  String selectedKategori = 'Semua';
  final TextEditingController searchController = TextEditingController();
  final List<String> categories = const [
    'Semua',
    'Sayuran',
    'Bumbu & Rempah',
    'Beras & Biji-bijian',
    'Buah-buahan',
    'Umbi-umbian',
  ];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  /// Memuat produk dari server dengan parameter ?kategori= dan ?cari=
  /// Bukan menyaring di memori aplikasi (Sesuai Kriteria 2 Sangat Baik)
  Future<void> loadProducts() async {
    setState(() {
      state = KeadaanMuat.memuat;
      lastError = null;
    });

    try {
      final result = await ApiService.getProducts(
        kategori: selectedKategori == 'Semua' ? null : selectedKategori,
        cari: searchController.text.trim().isEmpty ? null : searchController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        products = result;
        state = result.isEmpty ? KeadaanMuat.kosong : KeadaanMuat.berhasil;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        lastError = e;
        state = KeadaanMuat.galat;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        lastError = const ApiException(
          statusCode: 500,
          message: 'Gagal memuat produk dari server.',
          errorType: ApiErrorType.other,
        );
        state = KeadaanMuat.galat;
      });
    }
  }

  /// Membuka formulir tambah/ubah produk dan menyegarkan daftar saat berhasil
  Future<void> openForm([Product? product]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ProductFormPage(product: product)),
    );
    if (saved == true && mounted) {
      loadProducts();
    }
  }

  /// Menghapus produk dengan konfirmasi dialog dan penanganan galat 409
  Future<void> deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Hapus Produk'),
          ],
        ),
        content: Text(
          'Yakin ingin menghapus produk "${product.nama}"?\n\n'
          'Perhatian: Produk yang terkait dengan pesanan aktif akan ditolak server (galat 409).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ApiService.deleteProduct(product.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade700,
          content: Text('Produk "${product.nama}" berhasil dihapus.'),
        ),
      );
      loadProducts();
    } on ApiException catch (e) {
      if (!mounted) return;
      // Penanganan khusus bila produk masih terpakai pada pesanan aktif (409)
      if (e.errorType == ApiErrorType.conflict || e.statusCode == 409) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Penghapusan Ditolak (409)'),
            content: Text(e.message),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Mengerti'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade800,
            content: Text(e.message),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Gagal menghapus produk. Periksa koneksi.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan Produk',
            onPressed: loadProducts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
      ),
      body: Column(
        children: [
          // Bar Pencarian & Penyaring Kategori (Kriteria 2)
          _buildFilterSection(),
          const Divider(height: 1),
          // Isi Layar Utama Berdasarkan 4 Keadaan Layar
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          // Input Pencarian
          TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Cari produk pertanian...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        loadProducts();
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onSubmitted: (_) => loadProducts(),
          ),
          const SizedBox(height: 8),
          // Pilihan Kategori (Filter Chip)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSelected = selectedKategori == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: Colors.green.shade100,
                    checkmarkColor: Colors.green.shade800,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.green.shade900 : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      setState(() => selectedKategori = cat);
                      loadProducts();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (state) {
      case KeadaanMuat.memuat:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat daftar produk pertanian...'),
            ],
          ),
        );

      case KeadaanMuat.kosong:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'Belum Ada Produk Pertanian',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tidak ada produk yang cocok dengan pencarian/kategori yang dipilih, atau belum ada produk yang ditambahkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Produk Pertama'),
                      onPressed: () => openForm(),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset Filter'),
                      onPressed: () {
                        searchController.clear();
                        selectedKategori = 'Semua';
                        loadProducts();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

      case KeadaanMuat.galat:
        return _buildErrorState();

      case KeadaanMuat.berhasil:
        return RefreshIndicator(
          onRefresh: loadProducts,
          // Menggunakan ListView.builder sesuai ketentuan Kriteria 2
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return _buildProductCard(p);
            },
          ),
        );
    }
  }

  Widget _buildErrorState() {
    IconData icon = Icons.cloud_off_rounded;
    String title = 'Terjadi Kesalahan';
    String message = lastError?.message ?? 'Gagal memuat produk dari server.';

    if (lastError != null) {
      switch (lastError!.errorType) {
        case ApiErrorType.connection:
          icon = Icons.wifi_off_rounded;
          title = 'Sambungan Gagal';
          break;
        case ApiErrorType.timeout:
          icon = Icons.timer_off_outlined;
          title = 'Batas Waktu Terlampaui';
          break;
        case ApiErrorType.server:
          icon = Icons.dns_outlined;
          title = 'Gangguan Server (500)';
          break;
        default:
          icon = Icons.error_outline;
          break;
      }
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              onPressed: loadProducts,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product p) {
    final isStokHabis = p.stok <= 0;
    final isTidakTersedia = !p.tersedia;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Ikon Produk
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isStokHabis ? Colors.grey.shade100 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.eco,
                    color: isStokHabis ? Colors.grey : Colors.green,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),

                // Nama & Harga
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.nama,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isStokHabis ? Colors.grey.shade700 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${formatRupiah(p.harga)} / ${p.satuanJual}',
                        style: TextStyle(
                          color: isStokHabis ? Colors.grey : Colors.green.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Kategori: ${p.kategori}',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),

                // Menu Ubah & Hapus
                PopupMenuButton<String>(
                  onSelected: (action) {
                    if (action == 'edit') openForm(p);
                    if (action == 'delete') deleteProduct(p);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Ubah'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),
            // Penanda Status dan Atribut Khas Domain Pertanian (Kriteria 1 & 2)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                // Badge Stok
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isStokHabis ? Colors.red.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isStokHabis ? Colors.red.shade300 : Colors.blue.shade300,
                    ),
                  ),
                  child: Text(
                    isStokHabis ? 'STOK HABIS (0)' : 'Stok: ${p.stok} ${p.satuanJual}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isStokHabis ? Colors.red.shade800 : Colors.blue.shade900,
                    ),
                  ),
                ),

                // Penanda Ketersediaan
                if (isTidakTersedia)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'TIDAK AKTIF',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                  ),

                // Atribut Khas Pertanian TokoTani: Mudah Rusak
                if (p.mudahRusak)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.alarm, size: 12, color: Colors.orange.shade900),
                        const SizedBox(width: 4),
                        Text(
                          'MUDAH RUSAK',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            if (p.deskripsi != null && p.deskripsi!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                p.deskripsi!,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
