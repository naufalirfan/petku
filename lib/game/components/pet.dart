import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../pet_game.dart';

enum PetMood { idle, eat, bath, sleep, happy, sad }

class PetComponent extends PositionComponent {
  final PetGame game;
  PetMood mood = PetMood.idle;
  double _moodTimer = 0;
  double _bobT = 0;
  double _blinkTimer = 2.5;
  bool _blink = false;
  double _squash = 0;
  String outfitId = 'none';

  List<Sprite> _frames = [];
  Sprite? _current;
  bool _sheetLoaded = false;

  PetComponent({required this.game});

  @override
  Future<void> onLoad() async {
    size = Vector2(140, 140);
    anchor = Anchor.center;
    try {
      final image = await game.images.load('pet_sheet.png');
      _frames = [];
      for (int i = 0; i < 6; i++) {
        _frames.add(Sprite(image, srcPosition: Vector2(i * 128.0, 0), srcSize: Vector2(128, 128)));
      }
      _current = _frames[0];
      _sheetLoaded = true;
    } catch (_) {
      _sheetLoaded = false;
    }
  }

  void playEatAnimation() { mood = PetMood.eat; _moodTimer = 1.2; _squash = 0.6; _current = _frames.length > 1 ? _frames[1] : _current; }
  void playBathAnimation() { mood = PetMood.bath; _moodTimer = 1.5; _squash = 0.5; _current = _frames.length > 2 ? _frames[2] : _current; }
  void playSleepAnimation() { mood = PetMood.sleep; _moodTimer = 1.5; _squash = 0.4; _current = _frames.length > 3 ? _frames[3] : _current; }
  void playHappyAnimation() { mood = PetMood.happy; _moodTimer = 1.0; _squash = 0.7; _current = _frames.length > 4 ? _frames[4] : _current; }
  void playSadAnimation() { mood = PetMood.sad; _moodTimer = 1.0; _squash = -0.3; _current = _frames.length > 5 ? _frames[5] : _current; }
  void updateOutfit(String id) { outfitId = id; _squash = 0.5; }

  @override
  void update(double dt) {
    super.update(dt);
    _bobT += dt;
    if (_moodTimer > 0) {
      _moodTimer -= dt;
      if (_moodTimer <= 0) { mood = PetMood.idle; _current = _frames.isNotEmpty ? _frames[0] : _current; _squash = 0.3; }
    }
    _blinkTimer -= dt;
    if (_blinkTimer <= 0) {
      _blink = true;
      Future.delayed(const Duration(milliseconds: 120), () { _blink = false; });
      _blinkTimer = 2 + math.Random().nextDouble() * 2;
    }
    _squash = (_squash * (1 - 6 * dt)).clamp(-1, 1).toDouble();
    final s = game.petState;
    if (s.hunger < 20 && s.happy < 20 && mood == PetMood.idle && _bobT % 1.2 < 0.05) _squash = -0.2;
  }

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2, cy = size.y / 2;
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.15);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 58), width: 80, height: 16), shadowPaint);
    final bob = math.sin(_bobT * 2.2) * 4;
    final sx = 1 + _squash * 0.18;
    final sy = 1 - _squash * 0.18;
    canvas.save();
    canvas.translate(cx, cy + bob);
    canvas.scale(sx, sy);
    canvas.translate(-cx, -cy);
    if (_sheetLoaded && _current != null) {
      final sp = _current;
      if (sp != null) sp.render(canvas, position: Vector2(cx - 55, cy - 55), size: Vector2(110, 110));
      if (outfitId != 'none') {
        final c = outfitId == 'shirt_basic' ? const Color(0xFF74B9FF) : const Color(0xFFFFD93D);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + 18), width: 72, height: 28), const Radius.circular(10)), Paint()..color = c);
      }
    } else {
      _renderVector(canvas, Offset(cx, cy));
    }
    canvas.restore();
  }

  void _renderVector(Canvas canvas, Offset center) {
    final paint = Paint()..color = _moodColor();
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: 110, height: 110), const Radius.circular(36)), paint);
    final eyePaint = Paint()..color = Colors.white;
    final pupil = Paint()..color = Colors.black;
    if (_blink) {
      canvas.drawLine(Offset(center.dx - 22, center.dy - 10), Offset(center.dx - 8, center.dy - 10), Paint()..color = Colors.black..strokeWidth = 3..strokeCap = StrokeCap.round);
      canvas.drawLine(Offset(center.dx + 8, center.dy - 10), Offset(center.dx + 22, center.dy - 10), Paint()..color = Colors.black..strokeWidth = 3..strokeCap = StrokeCap.round);
    } else {
      canvas.drawCircle(Offset(center.dx - 22, center.dy - 12), 14, eyePaint);
      canvas.drawCircle(Offset(center.dx + 22, center.dy - 12), 14, eyePaint);
      canvas.drawCircle(Offset(center.dx - 22, center.dy - 10), 6, pupil);
      canvas.drawCircle(Offset(center.dx + 22, center.dy - 10), 6, pupil);
    }
    final mouthPaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round;
    final mouth = switch (mood) {
      PetMood.happy || PetMood.eat => Path()..moveTo(center.dx - 14, center.dy + 18)..quadraticBezierTo(center.dx, center.dy + 30, center.dx + 14, center.dy + 18),
      PetMood.sad => Path()..moveTo(center.dx - 12, center.dy + 26)..quadraticBezierTo(center.dx, center.dy + 18, center.dx + 12, center.dy + 26),
      _ => Path()..moveTo(center.dx - 10, center.dy + 22)..lineTo(center.dx + 10, center.dy + 22),
    };
    canvas.drawPath(mouth, mouthPaint);
    if (outfitId != 'none') { final c = outfitId == 'shirt_basic' ? const Color(0xFF74B9FF) : const Color(0xFFFFD93D); canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(center.dx, center.dy + 18), width: 72, height: 28), const Radius.circular(10)), Paint()..color = c); }
  }

  Color _moodColor() => switch (mood) {
    PetMood.eat => const Color(0xFFFFB26B),
    PetMood.bath => const Color(0xFF7ED6DF),
    PetMood.sleep => const Color(0xFF9B59B6),
    PetMood.happy => const Color(0xFFF1C40F),
    PetMood.sad => const Color(0xFF95A5A6),
    _ => const Color(0xFF6C5CE7),
  };
}
