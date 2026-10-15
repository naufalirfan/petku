import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../pet_game.dart';

class MiniGameWhackOverlay extends StatefulWidget {
  final PetGame game;
  const MiniGameWhackOverlay({super.key, required this.game});
  @override
  State<MiniGameWhackOverlay> createState() => _MiniGameWhackOverlayState();
}

class _MiniGameWhackOverlayState extends State<MiniGameWhackOverlay> {
  PetGame get game => widget.game;
  int score = 0;
  int timeLeft = 15;
  int activeMole = -1;
  Timer? timer;
  final rnd = Random();

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
    _next();
  }

  void _next() {
    Future.delayed(Duration(milliseconds: 400 + rnd.nextInt(320)), () {
      if (!mounted || timeLeft <= 0) return;
      setState(() => activeMole = rnd.nextInt(9));
      Future.delayed(const Duration(milliseconds: 620), () {
        if (mounted) setState(() => activeMole = -1);
      });
      _next();
    });
  }

  void _finish() {
    final s = score;
    game.onMiniGameComplete(MiniGameType.whackGame, s);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selesai! Skor: $s (Bonus +${s >= 60 ? '60 Perfect' : '30'} koin)'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _hitMole(int index) {
    if (index == activeMole) {
      HapticFeedback.mediumImpact();
      game.audioManager.playSfx('button');
      setState(() {
        score += 5;
        activeMole = -1;
      });
    }
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
            colors: [Color(0xFF55EFC4), Color(0xFF00B894)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // HUD Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  children: [
                    // Score Capsule
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
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
                    // Timer Capsule
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: timeLeft <= 5 ? Colors.redAccent.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.55),
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

              // 3x3 Mole Grid
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(22),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: 9,
                      itemBuilder: (c, i) {
                        final isActive = i == activeMole;
                        return GestureDetector(
                          onTapDown: (_) => _hitMole(i),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8D6E63), Color(0xFF5D4037)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Inner Hole
                                Container(
                                  width: 58,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3E2723),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                // Animated Monster
                                AnimatedScale(
                                  scale: isActive ? 1.15 : 0.0,
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.elasticOut,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Text('\u{1F98A}', style: TextStyle(fontSize: 38)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Bottom Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: Colors.black.withValues(alpha: 0.35),
                child: const Text(
                  'Ketuk monster saat muncul dari sarang! Tiap pukulan = +5 Koin',
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
