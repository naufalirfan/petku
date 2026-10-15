import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
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
      if (timeLeft <= 0) { t.cancel(); _finish(); return; }
      setState(() => timeLeft--);
    });
    _next();
  }

  void _next() {
    Future.delayed(Duration(milliseconds: 450 + rnd.nextInt(350)), () {
      if (!mounted || timeLeft <= 0) return;
      setState(() => activeMole = rnd.nextInt(9));
      Future.delayed(const Duration(milliseconds: 650), () {
        if (mounted) setState(() => activeMole = -1);
      });
      _next();
    });
  }

  void _finish() {
    final s = score;
    game.onMiniGameComplete(MiniGameType.whackGame, s);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selesai! +\u0024s koin (${s >= 60 ? 'PERFECT' : 'OK'})')));
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
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: 9,
              itemBuilder: (c, i) => GestureDetector(
                onTap: () { if (i == activeMole) setState(() { score += 5; activeMole = -1; }); },
                child: Container(
                  decoration: BoxDecoration(color: i == activeMole ? const Color(0xFFFFD93D) : const Color(0xFF636E72), borderRadius: BorderRadius.circular(16)),
                  child: Center(child: Text(i == activeMole ? '\u{1F98A}' : '\u{1F573}', style: const TextStyle(fontSize: 32))),
                ),
              ),
            ),
          ),
          Container(width: double.infinity, color: const Color(0xFF2D3436), padding: const EdgeInsets.all(12), child: Text('Pukul monster +5 • Selesai hitung perfect jika \u226560', style: TextStyle(color: Colors.white54, fontSize: 11))),
        ]),
      ),
    );
  }
}
