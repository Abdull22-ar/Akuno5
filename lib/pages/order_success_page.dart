import 'package:flutter/material.dart';
import '../widgets/agrimart_logo.dart';
import 'main_shell_page.dart';

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Lanskap perbukitan dan sawah di bagian bawah
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: size.height * 0.22,
            child: CustomPaint(
              painter: FarmLandscapePainter(
                hillColor1: const Color(0xFFC8E6C9),
                hillColor2: const Color(0xFFA5D6A7),
                hillColor3: const Color(0xFF4CAF50),
              ),
            ),
          ),

          // Rumah kebun kecil di sudut kanan bawah
          Positioned(
            bottom: size.height * 0.12,
            right: 28,
            child: const Icon(
              Icons.cottage,
              size: 44,
              color: Color(0xFF2E7D32),
            ),
          ),

          // Konten Utama di Tengah Sesuai Desain
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ikon Centang Hijau Besar dengan Partikel
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Partikel / percikan dekoratif di sekeliling centang
                        ...List.generate(6, (index) {
                          final angles = [0.0, 1.0, 2.1, 3.14, 4.2, 5.2];
                          return Transform.rotate(
                            angle: angles[index],
                            child: Transform.translate(
                              offset: const Offset(0, -64),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: index % 2 == 0 ? const Color(0xFF4CAF50) : Colors.orangeAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          );
                        }),

                        // Lingkaran Hijau Utama dengan Centang Putih
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2E7D32).withValues(alpha: 0.35),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Teks Judul
                    const Text(
                      'Pesanan Berhasil!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Teks Subjudul
                    const Text(
                      'Terima kasih telah berbelanja\ndi AgriMart',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Tombol 1: "Lihat Pesanan" (Hijau Solid)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Navigasi ke MainShellPage pada tab Pesanan / Kelola Produk
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const MainShellPage(initialIndex: 3),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Lihat Pesanan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tombol 2: "Kembali ke Beranda" (Outlined)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Navigasi ke MainShellPage pada tab Beranda
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const MainShellPage(initialIndex: 0),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Kembali ke Beranda',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

