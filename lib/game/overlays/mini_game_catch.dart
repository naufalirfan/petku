import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../pet_game.dart';

class MiniGameCatchOverlay extends StatefulWidget {
  final PetGame game;
  const MiniGameCatchOverlay({super.key, required this.game});
  @override
  State<MiniGameCatchOverlay> createState() => _MiniGameCatchOverlayState();
}

class _MiniGameCatchOverlayState extends State<MiniGameCatchOverlay> {
  PetGame get game => widget.game;
  int score = 0;
  int timeLeft = 15;
  Timer? timer;
  final rnd = Random();
  List<_FallingFood> foods = [];

  final List<String> foodEmojis = ['\u{1F34E}', '\u{1F353}', '\u{1F36A}', '\u{1F35A}', '\u{1F34C}'];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (timeLeft <= 0) {
        t.cancel();
        _finish();
        return;
      }
      setState(() => timeLeft--);
    });
    _spawn();
    _tick();
  }

  void _spawn() {
    Future.delayed(Duration(milliseconds: 320 + rnd.nextInt(300)), () {
      if (!mounted || timeLeft <= 0) return;
      setState(() {
        foods.add(_FallingFood(
          id: rnd.nextInt(1 << 30),
          emoji: foodEmojis[rnd.nextInt(foodEmojis.length)],
          x: rnd.nextDouble() * 0.78 + 0.11,
          y: 0,
          speed: 0.016 + rnd.nextDouble() * 0.012,
        ));
      });
      _spawn();
    });
  }

  void _tick() {
    Future.delayed(const Duration(milliseconds: 32), () {
      if (!mounted || timeLeft <= 0) return;
      setState(() {
        for (final f in foods) {
          f.y += f.speed;
        }
        foods.removeWhere((f) => f.y > 1.05);
      });
      _tick();
    });
  }

  void _finish() {
    final s = score;
    game.onMiniGameComplete(MiniGameType.catchGame, s);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selesai! Skor: $s (Bonus +${s >= 60 ? '60 Perfect' : '30'} koin)'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _tapFood(_FallingFood f) {
    HapticFeedback.lightImpact();
    game.audioManager.playSfx('button');
    setState(() {
      foods.remove(f);
      score += 2;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF74B9FF), Color(0xFFA29BFE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Score & Timer HUD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  children: [
                    // Score Capsule
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFD700)),
                      ),
                      child: Row(
                        children: [
                          const Text('\u{1FA99}', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            "Skor: $score",
                            style: const TextStyle(color: Color(0xFFFFEAA7), fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Time Capsule
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: timeLeft <= 5 ? Colors.redAccent.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            "$timeLeft dtk",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: _finish,
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Game Field
              Expanded(
                child: LayoutBuilder(
                  builder: (c, box) {
                    return Stack(
                      children: [
                        // Decorative clouds
                        Positioned(
                          top: 20,
                          left: 30,
                          child: Icon(Icons.cloud, size: 64, color: Colors.white.withValues(alpha: 0.25)),
                        ),
                        Positioned(
                          top: 90,
                          right: 40,
                          child: Icon(Icons.cloud, size: 48, color: Colors.white.withValues(alpha: 0.2)),
                        ),

                        // Falling Treats
                        for (final f in foods)
                          Positioned(
                            left: f.x * box.maxWidth - 20,
                            top: f.y * box.maxHeight,
                            child: GestureDetector(
                              onTapDown: (_) => _tapFood(f),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(f.emoji, style: const TextStyle(fontSize: 34)),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),

              // Bottom instruction
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: Colors.black.withValues(alpha: 0.35),
                child: const Text(
                  'Sentuh makanan yang jatuh! Tiap tangkapan = +2 Koin',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FallingFood {
  final int id;
  final String emoji;
  final double x;
  double y;
  final double speed;
  _FallingFood({
    required this.id,
    required this.emoji,
    required this.x,
    required this.y,
    required this.speed,
  });
}
