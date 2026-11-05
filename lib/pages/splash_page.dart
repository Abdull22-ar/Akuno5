import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/agrimart_logo.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();

    // Otomatis berpindah ke halaman Login setelah 2.4 detik
    _timer = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, anim1, anim2) => const LoginPage(),
            transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Latar gradien hijau segar seperti pada desain
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE8F5E9),
                  Color(0xFFC8E6C9),
                  Color(0xFFA5D6A7),
                  Color(0xFF66BB6A),
                ],
                stops: [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),

          // Lapisan lukisan lanskap sawah dan bukit hijau bergelombang
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: size.height * 0.48,
            child: CustomPaint(
              painter: FarmLandscapePainter(
                hillColor1: const Color(0xFF81C784),
                hillColor2: const Color(0xFF4CAF50),
                hillColor3: const Color(0xFF2E7D32),
              ),
            ),
          ),

          // Siluet traktor di kejauhan (khas desain AgriMart)
          Positioned(
            bottom: size.height * 0.28,
            right: 48,
            child: Opacity(
              opacity: 0.65,
              child: Transform.scale(
                scaleX: -1,
                child: const Icon(
                  Icons.agriculture,
                  size: 40,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ),
          ),

          // Konten Utama di Tengah
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo Keranjang Belanja + Daun
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_cart_rounded,
                            size: 48,
                            color: Color(0xFF2E7D32),
                          ),
                          Positioned(
                            top: 14,
                            right: 16,
                            child: Transform.rotate(
                              angle: 0.45,
                              child: const Icon(
                                Icons.eco,
                                size: 30,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Teks AgriMart
                    const Text(
                      'AgriMart',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Tagline Sesuai Desain
                    const Text(
                      'Belanja Cerdas,\nDukung Pertanian',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Indikator Garis Kapsul di Bagian Bawah Layar
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 72,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
