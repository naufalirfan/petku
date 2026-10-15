import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
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
  List<_Food> foods = [];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (timeLeft <= 0) { t.cancel(); _finish(); return; }
      setState(() => timeLeft--);
    });
    _spawn();
    _tick();
  }

  void _spawn() {
    Future.delayed(Duration(milliseconds: 350 + rnd.nextInt(350)), () {
      if (!mounted || timeLeft <= 0) return;
      setState(() => foods.add(_Food(
        id: rnd.nextInt(1 << 30),
        x: rnd.nextDouble() * 0.8 + 0.1,
        y: 0,
      )));
      _spawn();
    });
  }

  void _tick() {
    Future.delayed(const Duration(milliseconds: 32), () {
      if (!mounted || timeLeft <= 0) return;
      setState(() {
        for (final f in foods) { f.y += 0.015 + rnd.nextDouble() * 0.01; }
        foods.removeWhere((f) => f.y > 1.1);
      });
      _tick();
    });
  }

  void _finish() {
    final s = score;
    game.onMiniGameComplete(MiniGameType.catchGame, s);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selesai! +\u0024s koin (${s >= 60 ? 'PERFECT' : 'OK'})')));
  }

  void _tapFood(_Food f) {
    setState(() { foods.remove(f); score += 2; });
  }

  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2D3436),
      child: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Text("Skor: $score", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text("$timeLeft dtk", style: const TextStyle(color: Colors.white70)),
              const SizedBox(width: 12),
              ElevatedButton(onPressed: _finish, child: const Text('Selesai')),
            ]),
          ),
          Expanded(
            child: LayoutBuilder(builder: (c, box) {
              return Stack(children: [
                Container(color: const Color(0xFF353B48)),
                for (final f in foods)
                  Positioned(
                    left: f.x * box.maxWidth - 18,
                    top: f.y * box.maxHeight,
                    child: GestureDetector(
                      onTap: () => _tapFood(f),
                      child: const Text('\u{1F34E}', style: TextStyle(fontSize: 28)),
                    ),
                  ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: foods.isEmpty
                          ? const Text('Tap buah yang jatuh!', style: TextStyle(color: Colors.white54))
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
              ]);
            }),
          ),
          Container(
            width: double.infinity,
            color: const Color(0xFF2D3436),
            padding: const EdgeInsets.all(12),
            child: Text('Tap buah +2 koin • Selesai hitung perfect jika \u226560', style: TextStyle(color: Colors.white54, fontSize: 11)),
          ),
        ]),
      ),
    );
  }
}

class _Food {
  final int id;
  final double x;
  double y;
  _Food({required this.id, required this.x, required this.y});
}
