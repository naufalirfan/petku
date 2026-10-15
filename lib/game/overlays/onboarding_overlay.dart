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
    _OnbData(
      emoji: '\u{1F35A}',
      title: 'Beri Makan & Rawat',
      desc: 'Pet imutmu butuh perhatian tiap hari!\nBeri makan makanan lezat agar selalu sehat dan kenyang.',
      colors: [Color(0xFFFF7675), Color(0xFFFF9F43)],
    ),
    _OnbData(
      emoji: '\u2728',
      title: 'Mandi & Tidur Nyenyak',
      desc: 'Mandikan pet dengan busa wangi dan matikan lampu saat malam agar energi pulih maksimal.',
      colors: [Color(0xFF00CEC9), Color(0xFF0984E3)],
    ),
    _OnbData(
      emoji: '\u{1F3AE}',
      title: 'Main Mini-Game & Belanja',
      desc: 'Kumpulkan ribuan koin dari mini-game arcade seru dan belikan baju keren di toko!',
      colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
    ),
  ];

  void _next() {
    HapticFeedback.selectionClick();
    if (_i < 2) {
      _pc.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOut);
    } else {
      widget.game.completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.8),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Header Logo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('\u{1F43E} ', style: TextStyle(fontSize: 16)),
                  Text(
                    'Selamat Datang di Petku!',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pc,
                onPageChanged: (v) => setState(() => _i = v),
                itemCount: _pages.length,
                itemBuilder: (_, idx) {
                  final p = _pages[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Giant Glowing Emoji Card
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: p.colors,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: p.colors.first.withValues(alpha: 0.4),
                                blurRadius: 28,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(p.emoji, style: const TextStyle(fontSize: 72)),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          p.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p.desc,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (j) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _i == j ? 26 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _i == j ? const Color(0xFFFFD700) : Colors.white30,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0x666C5CE7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _next,
                  child: Text(
                    _i == 2 ? 'Mulai Rawat Pet \u2728' : 'Lanjut',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_i < 2)
              TextButton(
                onPressed: () => widget.game.completeOnboarding(),
                child: const Text('Lewati Tutorial', style: TextStyle(color: Colors.white54, fontSize: 13)),
              )
            else
              const SizedBox(height: 36),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _OnbData {
  final String emoji;
  final String title;
  final String desc;
  final List<Color> colors;
  const _OnbData({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.colors,
  });
}
