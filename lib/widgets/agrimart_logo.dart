import 'package:flutter/material.dart';

/// Logo resmi AgriMart sesuai design: Keranjang belanja dengan aksen daun hijau segar
class AgriMartLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showTagline;
  final Color? color;
  final Color textColor;

  const AgriMartLogo({
    super.key,
    this.size = 64,
    this.showText = true,
    this.showTagline = false,
    this.color,
    this.textColor = const Color(0xFF1B5E20),
  });

  @override
  Widget build(BuildContext context) {
    final primary = color ?? const Color(0xFF2E7D32);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ikon logo keranjang dengan daun
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Keranjang belanja
              Icon(
                Icons.shopping_cart_rounded,
                size: size * 0.54,
                color: primary,
              ),
              // Daun di atas kanan keranjang
              Positioned(
                top: size * 0.15,
                right: size * 0.18,
                child: Transform.rotate(
                  angle: 0.45,
                  child: Icon(
                    Icons.eco,
                    size: size * 0.38,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (showText) ...[
          SizedBox(height: size * 0.18),
          Text(
            'AgriMart',
            style: TextStyle(
              fontSize: size * 0.42,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
        ],

        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            'Belanja Cerdas,\nDukung Pertanian',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size * 0.22,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.85),
              height: 1.25,
            ),
          ),
        ],
      ],
    );
  }
}

/// Lukisan latar bukit bergelombang dan pemandangan sawah hijau khas AgriMart
class FarmLandscapePainter extends CustomPainter {
  final Color hillColor1;
  final Color hillColor2;
  final Color hillColor3;

  FarmLandscapePainter({
    this.hillColor1 = const Color(0xFF81C784),
    this.hillColor2 = const Color(0xFF4CAF50),
    this.hillColor3 = const Color(0xFF2E7D32),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Lapisan bukit 1 (jauh/paling terang)
    final path1 = Path();
    path1.moveTo(0, h * 0.45);
    path1.quadraticBezierTo(w * 0.25, h * 0.30, w * 0.55, h * 0.40);
    path1.quadraticBezierTo(w * 0.80, h * 0.48, w, h * 0.35);
    path1.lineTo(w, h);
    path1.lineTo(0, h);
    path1.close();
    canvas.drawPath(path1, Paint()..color = hillColor1.withValues(alpha: 0.45));

    // Lapisan bukit 2 (tengah)
    final path2 = Path();
    path2.moveTo(0, h * 0.58);
    path2.quadraticBezierTo(w * 0.35, h * 0.46, w * 0.65, h * 0.54);
    path2.quadraticBezierTo(w * 0.85, h * 0.60, w, h * 0.50);
    path2.lineTo(w, h);
    path2.lineTo(0, h);
    path2.close();
    canvas.drawPath(path2, Paint()..color = hillColor2.withValues(alpha: 0.70));

    // Lapisan bukit 3 (depan/hijau pekat)
    final path3 = Path();
    path3.moveTo(0, h * 0.72);
    path3.quadraticBezierTo(w * 0.30, h * 0.65, w * 0.60, h * 0.76);
    path3.quadraticBezierTo(w * 0.85, h * 0.84, w, h * 0.70);
    path3.lineTo(w, h);
    path3.lineTo(0, h);
    path3.close();
    canvas.drawPath(path3, Paint()..color = hillColor3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

