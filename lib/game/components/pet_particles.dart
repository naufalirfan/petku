// ignore_for_file: prefer_initializing_formals
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum BurstType { bubbles, confetti }

class BurstEffect extends Component {
  BurstEffect({required Vector2 at, required BurstType type}) {
    _at = at;
    _type = type;
  }
  late Vector2 _at;
  late BurstType _type;
  final _rand = math.Random();

  @override
  Future<void> onLoad() async {
    if (_type == BurstType.bubbles) {
      for (int i = 0; i < 12; i++) {
        final a = _rand.nextDouble() * math.pi * 2;
        final r = 8 + _rand.nextDouble() * 36;
        final p = _at + Vector2(math.cos(a) * r * 0.5, math.sin(a) * r * 0.3);
        add(_Bubble(
          position: p,
          radius: 4 + _rand.nextDouble() * 7,
          vel: Vector2((_rand.nextDouble() - 0.5) * 60, -70 - _rand.nextDouble() * 90),
          life: 0.7 + _rand.nextDouble() * 0.6,
        ));
      }
    } else {
      final colors = [
        const Color(0xFFF1C40F),
        const Color(0xFF6C5CE7),
        const Color(0xFFE84393),
        const Color(0xFF00CEC9),
        const Color(0xFFFF7675),
      ];
      for (int i = 0; i < 14; i++) {
        final ang = _rand.nextDouble() * math.pi * 2;
        final spd = 80 + _rand.nextDouble() * 160;
        add(_Confetti(
          position: _at.clone(),
          velocity: Vector2(math.cos(ang) * spd, math.sin(ang) * spd - 40),
          color: colors[_rand.nextInt(colors.length)],
          life: 0.6 + _rand.nextDouble() * 0.5,
          cSize: 5 + _rand.nextDouble() * 6,
          isCircle: _rand.nextBool(),
        ));
      }
    }
    // auto remove burst container after longest life
    add(TimerComponent(
      period: 1.4,
      onTick: () => removeFromParent(),
    ));
  }
}

class _Bubble extends PositionComponent {
  _Bubble({required Vector2 position, required double radius, required this.vel, required double life}) : life = life, maxLife = life {
    this.position = position;
    _r = radius;
    anchor = Anchor.center;
    size = Vector2.all(radius * 2);
  }
  late Vector2 vel;
  late double life;
  late double maxLife;
  late double _r;
  double _wobble = 0;

  @override
  void update(double dt) {
    super.update(dt);
    life -= dt;
    if (life <= 0) { removeFromParent(); return; }
    _wobble += dt * 6;
    position += vel * dt;
    vel.y -= 10 * dt; // slight float up
    position.x += math.sin(_wobble) * 0.6;
    vel.x *= 0.98;
    final scale = (life / maxLife).clamp(0.0, 1.0);
    size = Vector2.all(_r * 2 * (0.7 + scale * 0.3));
  }

  @override
  void render(Canvas canvas) {
    final o = (life / maxLife).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85 * o)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = const Color(0xFF74B9FF).withValues(alpha: 0.6 * o)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, stroke);
    // highlight
    canvas.drawCircle(
      Offset(size.x * 0.3, size.y * 0.3),
      size.x * 0.18,
      Paint()..color = Colors.white.withValues(alpha: 0.95 * o),
    );
  }
}

class _Confetti extends PositionComponent {
  _Confetti({
    required Vector2 position,
    required this.velocity,
    required this.color,
    required double life,
    required double cSize,
    required this.isCircle,
  })  : life = life,
        maxLife = life {
    this.position = position;
    anchor = Anchor.center;
    size = Vector2.all(cSize);
    _rotSpeed = (math.Random().nextDouble() - 0.5) * 10;
  }
  late Vector2 velocity;
  late Color color;
  late double life;
  late double maxLife;
  late bool isCircle;
  late double _rotSpeed;
  double _rot = 0;

  @override
  void update(double dt) {
    super.update(dt);
    life -= dt;
    if (life <= 0) { removeFromParent(); return; }
    velocity.y += 380 * dt; // gravity
    velocity.x *= 0.99;
    position += velocity * dt;
    _rot += _rotSpeed * dt;
    // fade handled in render via alpha
  }

  @override
  void render(Canvas canvas) {
    final o = (life / maxLife).clamp(0.0, 1.0);
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(_rot);
    canvas.translate(-size.x / 2, -size.y / 2);
    final paint = Paint()..color = color.withValues(alpha: o);
    if (isCircle) {
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.x, size.y), Radius.circular(2)),
        paint,
      );
    }
    canvas.restore();
  }
}
