import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../pet_game.dart';

/// Bedroom digambar langsung (tanpa asset): kasur + bantal + lampu gaya Pou.
class BedroomComponent extends PositionComponent with HasGameReference<PetGame> {
  BedroomComponent();

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  Vector2 get bedCenter => Vector2(size.x * 0.5, size.y * 0.62);

  @override
  void render(Canvas canvas) {
    final w = size.x, h = size.y;
    // dinding kuning ala screenshot
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.68), Paint()..color = const Color(0xFFF7D774));
    // lantai
    canvas.drawRect(Rect.fromLTWH(0, h * 0.68, w, h * 0.32), Paint()..color = const Color(0xFFE8B96A));
    // baseboard
    canvas.drawRect(Rect.fromLTWH(0, h * 0.68 - 6, w, 6), Paint()..color = const Color(0xFFC9973F));
    // kasur (bingkai + sprei)
    final bed = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.60), width: w * 0.78, height: h * 0.16),
      const Radius.circular(28),
    );
    canvas.drawRRect(bed, Paint()..color = const Color(0xFFB07B4F)); // rangka
    final sheet = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.585), width: w * 0.74, height: h * 0.13),
      const Radius.circular(24),
    );
    canvas.drawRRect(sheet, Paint()..color = const Color(0xFFFFF6E0)); // sprei
    // bantal putih besar (pet duduk di sini)
    final pillow = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.545), width: w * 0.42, height: h * 0.085),
      const Radius.circular(30),
    );
    canvas.drawRRect(pillow, Paint()..color = Colors.white);
    canvas.drawRRect(pillow, Paint()
      ..color = const Color(0xFFE9E4D8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
    // gantungan baju di dinding (kiri) — biar terasa closet
    final hook = Paint()..color = const Color(0xFFC9973F)..strokeWidth = 4;
    canvas.drawLine(Offset(w * 0.10, h * 0.22), Offset(w * 0.10, h * 0.40), hook);
    canvas.drawLine(Offset(w * 0.06, h * 0.22), Offset(w * 0.14, h * 0.22), hook);
    // lampu meja kanan-bawah
    final lampBase = Rect.fromCenter(center: Offset(w * 0.88, h * 0.64), width: w * 0.10, height: h * 0.02);
    canvas.drawOval(lampBase, Paint()..color = const Color(0xFF8D6E63));
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.88, h * 0.59), width: 4, height: h * 0.06), Paint()..color = const Color(0xFF8D6E63));
    final shade = Path()
      ..moveTo(w * 0.83, h * 0.555)
      ..lineTo(w * 0.93, h * 0.555)
      ..lineTo(w * 0.905, h * 0.505)
      ..lineTo(w * 0.855, h * 0.505)
      ..close();
    canvas.drawPath(shade, Paint()..color = const Color(0xFFFFE082));
  }
}
