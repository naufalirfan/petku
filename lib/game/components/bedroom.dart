import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../pet_game.dart';
import 'pet.dart';

/// Bedroom yang kaya detail estetis: dinding wallpaper bergradien,
/// jendela dengan langit dinamis (siang/malam saat pet tidur),
/// bunting dekoratif, lantai parket kayu, karpet empuk, dan kasur nyaman.
class BedroomComponent extends PositionComponent with HasGameReference<PetGame> {
  BedroomComponent();

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  Vector2 get bedCenter => Vector2(size.x * 0.5, size.y * 0.61);

  @override
  void render(Canvas canvas) {
    final w = size.x, h = size.y;
    final isAsleep = game.pet.mood == PetMood.sleep;

    // 1. DINDING KAMUR (Siang vs Malam / Tidur)
    final wallPaint = Paint();
    if (isAsleep) {
      wallPaint.shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1E272E), Color(0xFF2C3E50)],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.68));
    } else {
      wallPaint.shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFF3D6), Color(0xFFFCE1A8)],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.68));
    }
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.68), wallPaint);

    // Wallpaper stripes halus (khusus siang)
    if (!isAsleep) {
      final stripePaint = Paint()
        ..color = const Color(0xFFF5D695).withValues(alpha: 0.35)
        ..strokeWidth = 2;
      for (double x = 16; x < w; x += 32) {
        canvas.drawLine(Offset(x, 0), Offset(x, h * 0.68), stripePaint);
      }
    }

    // 2. JENDELA LENGKUNG AESTHETIC (Kiri)
    final winRect = Rect.fromCenter(center: Offset(w * 0.22, h * 0.26), width: w * 0.28, height: h * 0.22);
    final winRRect = RRect.fromRectAndCorners(
      winRect,
      topLeft: const Radius.circular(50),
      topRight: const Radius.circular(50),
      bottomLeft: const Radius.circular(10),
      bottomRight: const Radius.circular(10),
    );

    // Isi langit jendela
    final skyPaint = Paint();
    if (isAsleep) {
      skyPaint.shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
      ).createShader(winRect);
      canvas.drawRRect(winRRect, skyPaint);

      // Bulan sabit & bintang di jendela
      final moonPaint = Paint()..color = const Color(0xFFFDE047);
      canvas.drawCircle(Offset(winRect.center.dx + 10, winRect.top + 28), 12, moonPaint);
      canvas.drawCircle(Offset(winRect.center.dx + 14, winRect.top + 25), 10, Paint()..color = const Color(0xFF1E293B));

      // Bintang kecil
      final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
      canvas.drawCircle(Offset(winRect.left + 16, winRect.top + 34), 1.5, starPaint);
      canvas.drawCircle(Offset(winRect.left + 32, winRect.top + 18), 2.0, starPaint);
      canvas.drawCircle(Offset(winRect.right - 24, winRect.top + 48), 1.8, starPaint);
    } else {
      skyPaint.shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF74B9FF), Color(0xFF81ECEC)],
      ).createShader(winRect);
      canvas.drawRRect(winRRect, skyPaint);

      // Awan putih imut
      final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
      final cY = winRect.center.dy - 6;
      final cX = winRect.center.dx - 8;
      canvas.drawCircle(Offset(cX, cY), 12, cloudPaint);
      canvas.drawCircle(Offset(cX + 12, cY + 2), 10, cloudPaint);
      canvas.drawCircle(Offset(cX - 10, cY + 3), 9, cloudPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cX - 14, cY + 2, 38, 10), const Radius.circular(6)), cloudPaint);
    }

    // Kusen kayu jendela
    final framePaint = Paint()
      ..color = const Color(0xFF8D5524)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawRRect(winRRect, framePaint);
    // Palang jendela
    canvas.drawLine(Offset(winRect.center.dx, winRect.top + 12), Offset(winRect.center.dx, winRect.bottom), framePaint..strokeWidth = 3);
    canvas.drawLine(Offset(winRect.left, winRect.center.dy + 8), Offset(winRect.right, winRect.center.dy + 8), framePaint);
    // Sill jendela (ambang bawah)
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(winRect.center.dx, winRect.bottom + 2), width: winRect.width + 12, height: 8), const Radius.circular(4)),
      Paint()..color = const Color(0xFFA06633),
    );

    // 3. WALL DECORATIONS
    // Bunting banner pastel imut di bagian atas dinding
    final buntingColors = [
      const Color(0xFFFF7675),
      const Color(0xFF74B9FF),
      const Color(0xFFFDCB6E),
      const Color(0xFF55EFC4),
      const Color(0xFFA29BFE),
      const Color(0xFFFF9FF3),
    ];
    final bY = h * 0.05;
    final bStep = w / 8;
    for (int i = 0; i < 8; i++) {
      final bx = i * bStep + bStep / 2;
      final path = Path()
        ..moveTo(bx - bStep / 2, bY)
        ..lineTo(bx + bStep / 2, bY)
        ..lineTo(bx, bY + 20)
        ..close();
      canvas.drawPath(path, Paint()..color = buntingColors[i % buntingColors.length].withValues(alpha: isAsleep ? 0.35 : 0.85));
    }
    // Tali bunting
    canvas.drawLine(Offset(0, bY), Offset(w, bY), Paint()..color = const Color(0xFF8D5524).withValues(alpha: 0.5)..strokeWidth = 1.5);

    // Bingkai Foto Lucu (Kanan)
    final frameR = Rect.fromCenter(center: Offset(w * 0.78, h * 0.22), width: 56, height: 64);
    canvas.drawRRect(RRect.fromRectAndRadius(frameR, const Radius.circular(8)), Paint()..color = const Color(0xFF8D5524));
    final frameInner = RRect.fromRectAndRadius(Rect.fromCenter(center: frameR.center, width: 44, height: 52), const Radius.circular(4));
    canvas.drawRRect(frameInner, Paint()..color = const Color(0xFFFFF9E6));
    // Gambar jejak kaki / bintang di dalam foto
    final pawColor = const Color(0xFFFF7675).withValues(alpha: 0.8);
    canvas.drawCircle(Offset(frameR.center.dx, frameR.center.dy + 4), 7, Paint()..color = pawColor);
    canvas.drawCircle(Offset(frameR.center.dx - 8, frameR.center.dy - 6), 3.5, Paint()..color = pawColor);
    canvas.drawCircle(Offset(frameR.center.dx + 8, frameR.center.dy - 6), 3.5, Paint()..color = pawColor);
    canvas.drawCircle(Offset(frameR.center.dx - 1, frameR.center.dy - 9), 3.5, Paint()..color = pawColor);

    // Jam Dinding Bulat (Tengah Atas)
    final clockCenter = Offset(w * 0.50, h * 0.17);
    canvas.drawCircle(clockCenter, 22, Paint()..color = const Color(0xFF8D5524));
    canvas.drawCircle(clockCenter, 19, Paint()..color = Colors.white);
    // Jarum jam
    canvas.drawLine(clockCenter, Offset(clockCenter.dx, clockCenter.dy - 11), Paint()..color = Colors.black87..strokeWidth = 2);
    canvas.drawLine(clockCenter, Offset(clockCenter.dx + 8, clockCenter.dy + 2), Paint()..color = const Color(0xFFFF7675)..strokeWidth = 1.5);
    canvas.drawCircle(clockCenter, 2.5, Paint()..color = Colors.black87);

    // 4. LANTAI PARKET KAYU
    final floorPaint = Paint()..color = isAsleep ? const Color(0xFF5D4037) : const Color(0xFFDE9B52);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.68, w, h * 0.32), floorPaint);

    // Garis sambungan papan kayu parket
    final plankLinePaint = Paint()..color = const Color(0xFFB06F27).withValues(alpha: isAsleep ? 0.3 : 0.6)..strokeWidth = 1.5;
    for (double y = h * 0.68 + 24; y < h; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(w, y), plankLinePaint);
    }
    // Garis baseboard (pembatas dinding & lantai)
    canvas.drawRect(Rect.fromLTWH(0, h * 0.68 - 8, w, 8), Paint()..color = isAsleep ? const Color(0xFF3E2723) : const Color(0xFF8D5524));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.68 - 2, w, 2), Paint()..color = isAsleep ? const Color(0xFF2E1C18) : const Color(0xFF6D3C14));

    // 5. KARPET EMPUK BULAT DI BAWAH KASUR
    final rugRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.64), width: w * 0.88, height: h * 0.19);
    final rugColor = isAsleep ? const Color(0xFF334E68) : const Color(0xFFE0F2FE);
    canvas.drawOval(rugRect, Paint()..color = rugColor);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.64), width: w * 0.84, height: h * 0.17),
      Paint()
        ..color = isAsleep ? const Color(0xFF486581) : const Color(0xFFBAE6FD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // 6. KASUR COZY (Modern & Fluffy)
    // Rangka ranjang kayu
    final bedFrame = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.595), width: w * 0.80, height: h * 0.17),
      const Radius.circular(26),
    );
    canvas.drawRRect(bedFrame, Paint()..color = const Color(0xFF8D5524));

    // Headboard ranjang (sandaran belakang kasur)
    final headboard = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.50), width: w * 0.72, height: h * 0.08),
      const Radius.circular(18),
    );
    canvas.drawRRect(headboard, Paint()..color = const Color(0xFFA06633));

    // Kasur / Matras empuk
    final mattress = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.585), width: w * 0.75, height: h * 0.13),
      const Radius.circular(22),
    );
    canvas.drawRRect(mattress, Paint()..color = isAsleep ? const Color(0xFF203A43) : const Color(0xFFFFFBF0));

    // Selimut lembut bergaris di bagian bawah kasur
    final comforter = RRect.fromRectAndCorners(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.615), width: w * 0.75, height: h * 0.07),
      bottomLeft: const Radius.circular(22),
      bottomRight: const Radius.circular(22),
    );
    canvas.drawRRect(comforter, Paint()..color = isAsleep ? const Color(0xFF2C5364) : const Color(0xFFFFD1DC));

    // Bantal awan empuk (Pet duduk tepat di sini)
    final pillowCenter = Offset(w * 0.5, h * 0.54);
    final pillow = RRect.fromRectAndRadius(
      Rect.fromCenter(center: pillowCenter, width: w * 0.44, height: h * 0.09),
      const Radius.circular(26),
    );
    canvas.drawRRect(pillow, Paint()..color = Colors.white);
    canvas.drawRRect(pillow, Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);

    // 7. MEJA NAKAS & LAMPU TIDUR (Kanan)
    final standCenter = Offset(w * 0.88, h * 0.62);
    // Meja kayu
    canvas.drawOval(Rect.fromCenter(center: standCenter, width: w * 0.15, height: h * 0.03), Paint()..color = const Color(0xFF8D5524));
    canvas.drawRect(Rect.fromLTWH(standCenter.dx - 4, standCenter.dy, 8, h * 0.08), Paint()..color = const Color(0xFFA06633));

    // Tiang lampu
    canvas.drawRect(Rect.fromCenter(center: Offset(standCenter.dx, standCenter.dy - 25), width: 5, height: 40), Paint()..color = const Color(0xFFD4AF37));
    // Kap lampu
    final shade = Path()
      ..moveTo(standCenter.dx - 18, standCenter.dy - 35)
      ..lineTo(standCenter.dx + 18, standCenter.dy - 35)
      ..lineTo(standCenter.dx + 12, standCenter.dy - 60)
      ..lineTo(standCenter.dx - 12, standCenter.dy - 60)
      ..close();
    canvas.drawPath(shade, Paint()..color = isAsleep ? const Color(0xFFFDE047) : const Color(0xFFFFE082));

    // Cahaya hangat lampu
    if (isAsleep) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFDE047).withValues(alpha: 0.35),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(standCenter.dx, standCenter.dy - 40), radius: 65));
      canvas.drawCircle(Offset(standCenter.dx, standCenter.dy - 40), 65, glowPaint);
    }
  }
}
