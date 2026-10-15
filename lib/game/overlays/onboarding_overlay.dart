import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../pet_game.dart';

class OnboardingOverlay extends StatefulWidget {
  final PetGame game;
  const OnboardingOverlay({super.key, required this.game});
  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay> {
  final _pc = PageController();
  int _i = 0;
  final _pages = const [
    _OnbData(emoji: '\u{1F35A}', title: 'Kasi Makan', desc: 'Pet lapar tiap menit.\nTap Makan di bawah, pilih Nasi/Buah/Snack.'),
    _OnbData(emoji: '\u2728', title: 'Mandi & Tidur', desc: 'Tap Mandi biar bersih.\nTap Tidur biar energi pulih.'),
    _OnbData(emoji: '\u{1F3AE}', title: 'Main Biar Kaya', desc: 'Main Tangkap & Pukul Monster\ntiap skor = koin buat belanja.'),
  ];

  void _next() {
    HapticFeedback.selectionClick();
    if (_i < 2) {
      _pc.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
    } else {
      widget.game.completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.72),
      child: SafeArea(
        child: Column(children: [
          const SizedBox(height: 48),
          Expanded(
            child: PageView.builder(
              controller: _pc,
              onPageChanged: (v) => setState(() => _i = v),
              itemCount: _pages.length,
              itemBuilder: (_, idx) {
                final p = _pages[idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(p.emoji, style: const TextStyle(fontSize: 88)),
                    const SizedBox(height: 20),
                    Text(p.title, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Text(p.desc, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.4)),
                  ]),
                );
              },
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (j) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _i == j ? 22 : 8, height: 8,
            decoration: BoxDecoration(color: _i == j ? Colors.white : Colors.white38, borderRadius: BorderRadius.circular(4)),
          ))),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(width: double.infinity, child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              onPressed: _next,
              child: Text(_i == 2 ? 'Mulai Main' : 'Lanjut', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            )),
          ),
          const SizedBox(height: 16),
          if (_i < 2)
            TextButton(onPressed: () => widget.game.completeOnboarding(), child: const Text('Lewati', style: TextStyle(color: Colors.white54))),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }
}

class _OnbData {
  final String emoji;
  final String title;
  final String desc;
  const _OnbData({required this.emoji, required this.title, required this.desc});
}
