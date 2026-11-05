import 'package:flutter_test/flutter_test.dart';
import 'package:tokotani/main.dart';

void main() {
  testWidgets('Memverifikasi judul dan splash AgriMart', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TokoTaniApp());

    // Memverifikasi teks judul 'AgriMart' muncul pada Splash
    expect(find.text('AgriMart'), findsWidgets);

    // Selesaikan timer transisi splash
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });

  testWidgets('Memverifikasi judul dan navigasi beranda TokoTani', (WidgetTester tester) async {
    // Build menu tugas evaluator
    await tester.pumpWidget(const TokoTaniApp(home: MenuPage()));

    // Memverifikasi teks judul 'TokoTani' muncul
    expect(find.textContaining('TokoTani'), findsWidgets);

    // Memverifikasi kartu navigasi bagian Anggota 5 muncul
    expect(find.text('Keranjang Belanja'), findsOneWidget);
    expect(find.text('Kelola Produk (CRUD)'), findsOneWidget);
  });
}
