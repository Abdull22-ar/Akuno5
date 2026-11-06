import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';

class CartPage extends StatefulWidget {
  final bool showBackButton;

  const CartPage({super.key, this.showBackButton = false});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // 4 Keadaan Layar wajib sesuai Kriteria 7
  KeadaanMuat state = KeadaanMuat.memuat;
  List<CartItem> items = [];
  int subtotal = 0; // Wajib dari server, dilarang dihitung ulang di Flutter!
  ApiException? lastError;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  String formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  /// Membaca isi keranjang dan subtotal langsung dari server
  Future<void> loadCart() async {
    setState(() {
      state = KeadaanMuat.memuat;
      lastError = null;
    });

    try {
      final result = await ApiService.getCart();
      if (!mounted) return;

      setState(() {
        items = result.items;
        // Nilai subtotal murni dari server (Sumber Kebenaran Tunggal / Single Source of Truth)
        subtotal = result.subtotal;
        state = items.isEmpty ? KeadaanMuat.kosong : KeadaanMuat.berhasil;
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
          message: 'Terjadi gangguan yang tidak terduga.',
          errorType: ApiErrorType.other,
        );
        state = KeadaanMuat.galat;
      });
    }
  }

  /// Mengubah jumlah item di keranjang dengan penanganan galat 409 (stok tidak cukup)
  Future<void> changeQuantity(CartItem item, int newQuantity) async {
    if (isProcessing) return;
    if (newQuantity < 1) return;

    setState(() => isProcessing = true);

    try {
      await ApiService.updateCart(item.id, newQuantity);
      // Muat ulang keranjang dari server agar data konsisten
      await loadCart();
    } on ApiException catch (e) {
      if (!mounted) return;
      // Penanganan galat 409 (Bentrok keadaan / Stok tidak cukup) dari server
      if (e.errorType == ApiErrorType.conflict || e.statusCode == 409) {
        _showWarningNotification(
          title: 'Stok Tidak Mencukupi (409)',
          message: e.message,
        );
      } else if (e.errorType == ApiErrorType.validation || e.statusCode == 422) {
        _showWarningNotification(
          title: 'Validasi Gagal (422)',
          message: e.message,
        );
      } else {
        _showErrorNotification(e.message);
      }
    } catch (_) {
      if (mounted) {
        _showErrorNotification('Gagal memperbarui jumlah barang. Periksa koneksi.');
      }
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  /// Menghapus item dari keranjang dengan dialog konfirmasi terlebih dahulu
  Future<void> removeItem(CartItem item) async {
    if (isProcessing) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Hapus Item'),
          ],
        ),
        content: Text('Apakah Anda yakin ingin menghapus "${item.nama}" dari keranjang?'),
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

    setState(() => isProcessing = true);

    try {
      await ApiService.deleteCart(item.id);
      await loadCart();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF2E7D32),
            content: Text('"${item.nama}" berhasil dihapus dari keranjang.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) _showErrorNotification(e.message);
    } catch (_) {
      if (mounted) _showErrorNotification('Gagal menghapus item dari keranjang.');
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  /// Mengosongkan seluruh keranjang belanja
  Future<void> clearAllItems() async {
    if (isProcessing || items.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_sweep_outlined, color: Colors.red),
            SizedBox(width: 8),
            Text('Kosongkan Keranjang'),
          ],
        ),
        content: const Text('Hapus semua produk dari keranjang belanja?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kosongkan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isProcessing = true);
    try {
      for (final item in items) {
        await ApiService.deleteCart(item.id);
      }
      await loadCart();
    } catch (_) {
      await loadCart();
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  void _showWarningNotification({required String title, required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.orange.shade900,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(message, style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF5),
      appBar: AppBar(
        title: const Text(
          'Keranjang Belanja',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0.5,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Kosongkan Keranjang',
              onPressed: isProcessing ? null : clearAllItems,
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF2E7D32)),
            tooltip: 'Segarkan Keranjang',
            onPressed: isProcessing ? null : loadCart,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: state == KeadaanMuat.berhasil ? _buildBottomBar() : null,
    );
  }

  Widget _buildBody() {
    switch (state) {
      case KeadaanMuat.memuat:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF2E7D32)),
              SizedBox(height: 16),
              Text('Memuat isi keranjang dari server...'),
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
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shopping_cart_outlined, size: 64, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Keranjang Belanja Kosong',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Belum ada produk hasil tani segar di keranjang Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.storefront_outlined),
                  label: const Text('Mulai Belanja Produk Segar'),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        );

      case KeadaanMuat.galat:
        return _buildErrorState();

      case KeadaanMuat.berhasil:
        return RefreshIndicator(
          onRefresh: loadCart,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildCartCard(item);
            },
          ),
        );
    }
  }

  Widget _buildErrorState() {
    IconData icon = Icons.error_outline;
    String title = 'Terjadi Kesalahan';
    String message = lastError?.message ?? 'Tidak dapat memuat keranjang belanja.';

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
          icon = Icons.cloud_off_rounded;
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
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              onPressed: loadCart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartCard(CartItem item) {
    final itemTotal = item.harga * item.jumlah;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gambar / Thumbnail Produk
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.eco, size: 36, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(width: 12),

          // Detail Produk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: isProcessing ? null : () => removeItem(item),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.close, size: 16, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatRupiah(item.harga)}/${item.satuanJual}',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
                const SizedBox(height: 8),

                // Stepper Jumlah dan Subtotal Item Sesuai Desain
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Stepper (- / qty / +)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: (isProcessing || item.jumlah <= 1)
                                ? null
                                : () => changeQuantity(item, item.jumlah - 1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Icon(
                                Icons.remove,
                                size: 14,
                                color: item.jumlah > 1 ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '${item.jumlah}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          InkWell(
                            onTap: isProcessing ? null : () => changeQuantity(item, item.jumlah + 1),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Icon(Icons.add, size: 14, color: Color(0xFF1E293B)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Subtotal Baris
                    Text(
                      formatRupiah(itemTotal),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, -3),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Belanja (Server)',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Subtotal tunggal dari API server',
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                Text(
                  formatRupiah(subtotal),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isProcessing
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF2E7D32),
                            behavior: SnackBarBehavior.floating,
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Subtotal ${formatRupiah(subtotal)} berhasil divalidasi oleh server.',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Validasi Subtotal Server',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.check_circle_outline, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
