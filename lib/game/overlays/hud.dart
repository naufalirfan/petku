import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../config/balance.dart';
import '../pet_game.dart';

class HUDOverlay extends StatefulWidget {
  final PetGame game;
  const HUDOverlay({super.key, required this.game});
  @override
  State<HUDOverlay> createState() => _HUDOverlayState();
}

class _HUDOverlayState extends State<HUDOverlay> {
  Timer? _ticker;
  PetGame get game => widget.game;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _msg(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m, style: const TextStyle(fontWeight: FontWeight.w600)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _sync() {
    if (mounted) setState(() {});
  }

  String _foodEmoji(FoodType f) => switch (f) {
    FoodType.rice => '\u{1F35A}',
    FoodType.fruit => '\u{1F34E}',
    FoodType.snack => '\u{1F36A}',
    FoodType.drink => '\u{1F964}',
  };

  String _foodName(FoodType f) => switch (f) {
    FoodType.rice => 'Nasi Komplit',
    FoodType.fruit => 'Buah Segar',
    FoodType.snack => 'Kue Manis',
    FoodType.drink => 'Jus Dingin',
  };

  int _foodPrice(FoodType f) => switch (f) {
    FoodType.rice => BalanceConfig.get<int>('food_rice'),
    FoodType.fruit => BalanceConfig.get<int>('food_fruit'),
    FoodType.snack => BalanceConfig.get<int>('food_snack'),
    FoodType.drink => BalanceConfig.get<int>('food_rice'),
  };

  String _foodDesc(FoodType f) => switch (f) {
    FoodType.rice => '+25 Lapar',
    FoodType.fruit => '+35 Lapar',
    FoodType.snack => '+50 Lapar',
    FoodType.drink => '+30 Lapar',
  };

  void _onEat() {
    HapticFeedback.lightImpact();
    final s = game.petState;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (c) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4))],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text('Kantin Petku \u{1F372}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF2D3436))),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFFFF9E6), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFFD700))),
                    child: Row(
                      children: [
                        const Text('\u{1FA99}'),
                        const SizedBox(width: 4),
                        Text("${s.coins}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  for (final f in FoodType.values)
                    _FoodCard(
                      emoji: _foodEmoji(f),
                      name: _foodName(f),
                      desc: _foodDesc(f),
                      price: _foodPrice(f),
                      canAfford: s.coins >= _foodPrice(f),
                      onTap: () {
                        Navigator.pop(c);
                        if (game.petState.coins < _foodPrice(f)) {
                          _msg('Koin tidak cukup! Main mini-game dulu.');
                          return;
                        }
                        if (game.petState.hunger >= 100) {
                          _msg('Pet masih kenyang.');
                          return;
                        }
                        game.feed(f);
                        _sync();
                        _msg('Nyam! ${_foodName(f)} dimakan (${_foodDesc(f)})');
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onBath() {
    HapticFeedback.mediumImpact();
    final price = BalanceConfig.get<int>('soap');
    if (game.petState.coins < price) {
      _msg('Koin tidak cukup untuk sabun! Main mini-game dulu.');
      return;
    }
    if (game.petState.clean >= 100) {
      _msg('Pet sudah wangi dan bersih.');
      return;
    }
    game.bathe();
    _sync();
    _msg('Busa melimpah! Pet wangi kembali ✨');
  }

  void _onSleep() {
    HapticFeedback.lightImpact();
    if (game.petState.energy >= 100) {
      _msg('Pet masih segar dan belum mengantuk.');
      return;
    }
    game.sleep();
    _sync();
    _msg('Lampu dimatikan... Pet istirahat nyenyak 💤');
  }

  void _onPlay() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (c) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4))],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 14),
              const Text('Arena Mini-Game \u{1F3AE}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF2D3436))),
              const Text('Kumpulkan skor tinggi untuk memborong koin!', style: TextStyle(color: Colors.black54, fontSize: 13)),
              const SizedBox(height: 16),
              _ArcadeCard(
                emoji: '\u{1F34E}',
                title: 'Tangkap Makanan',
                subtitle: 'Tap makanan yang jatuh secepat kilat',
                reward: '+2 koin/tap • Bonus Menang 30-60',
                colors: const [Color(0xFFFF7675), Color(0xFFFF9F43)],
                onTap: () {
                  Navigator.pop(c);
                  game.playMiniGame(MiniGameType.catchGame);
                },
              ),
              const SizedBox(height: 12),
              _ArcadeCard(
                emoji: '\u{1F98A}',
                title: 'Pukul Monster',
                subtitle: 'Ketuk monster yang muncul sebelum kabur',
                reward: '+5 koin/hit • Bonus Menang 30-60',
                colors: const [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                onTap: () {
                  Navigator.pop(c);
                  game.playMiniGame(MiniGameType.whackGame);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onShop() => game.overlays.add('ShopOverlay');
  void _onCloset() => game.overlays.add('ClosetOverlay');

  @override
  Widget build(BuildContext context) {
    final s = game.petState;
    return SafeArea(
      child: Column(
        children: [
          // 1. TOP BAR (Coins & Status Streak & Settings)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Coin Pill
                GestureDetector(
                  onTap: _onShop,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.8), width: 1.5),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('\u{1FA99}', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(
                          "${s.coins}",
                          style: const TextStyle(color: Color(0xFFFFEAA7), fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.5),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.add_circle, color: Color(0xFFFFD700), size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Streak Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      const Text('\u{1F525}', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        'Hari ke-${s.dailyLoginStreak > 0 ? s.dailyLoginStreak : 1}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Settings button
                GestureDetector(
                  onTap: () => game.overlays.add('SettingsOverlay'),
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30),
                    ),
                    child: const Icon(Icons.settings, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // 2. STATUS BARS (Modern Animated Capsules)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _StatusBar(
                  emoji: '\u{1F35A}',
                  label: 'Lapar',
                  value: s.hunger,
                  colors: const [Color(0xFFFF7675), Color(0xFFFF9F43)],
                ),
                const SizedBox(width: 8),
                _StatusBar(
                  emoji: '\u{1F60A}',
                  label: 'Senang',
                  value: s.happy,
                  colors: const [Color(0xFFFECA57), Color(0xFFFF9F1A)],
                ),
                const SizedBox(width: 8),
                _StatusBar(
                  emoji: '\u2728',
                  label: 'Bersih',
                  value: s.clean,
                  colors: const [Color(0xFF48DBFB), Color(0xFF0ABDE3)],
                ),
                const SizedBox(width: 8),
                _StatusBar(
                  emoji: '\u26A1',
                  label: 'Energi',
                  value: s.energy,
                  colors: const [Color(0xFF1DD1A1), Color(0xFF10AC84)],
                ),
              ],
            ),
          ),

          const Spacer(),

          // 3. BOTTOM FLOATING ACTION DOCK
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.62),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1.2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 6)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.restaurant,
                    label: 'Makan',
                    gradient: const [Color(0xFFFF7675), Color(0xFFE84393)],
                    onTap: _onEat,
                  ),
                  _ActionButton(
                    icon: Icons.bathtub,
                    label: 'Mandi',
                    gradient: const [Color(0xFF00CEC9), Color(0xFF0984E3)],
                    onTap: _onBath,
                  ),
                  _ActionButton(
                    icon: Icons.checkroom,
                    label: 'Closet',
                    gradient: const [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                    onTap: _onCloset,
                  ),
                  _ActionButton(
                    icon: Icons.lightbulb_outline,
                    label: 'Lampu',
                    gradient: const [Color(0xFFFDCB6E), Color(0xFFE17055)],
                    onTap: _onSleep,
                  ),
                  _ActionButton(
                    icon: Icons.videogame_asset,
                    label: 'Main',
                    gradient: const [Color(0xFF00B894), Color(0xFF55EFC4)],
                    onTap: _onPlay,
                  ),
                  _ActionButton(
                    icon: Icons.storefront,
                    label: 'Toko',
                    gradient: const [Color(0xFFFD79A8), Color(0xFFE84393)],
                    onTap: _onShop,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final String emoji;
  final String label;
  final int value;
  final List<Color> colors;

  const _StatusBar({
    required this.emoji,
    required this.label,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (value / 100).clamp(0.0, 1.0);
    final isCritical = value <= 20;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCritical ? Colors.redAccent.withValues(alpha: 0.8) : Colors.white12,
            width: isCritical ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 3),
                Text(
                  "$value%",
                  style: TextStyle(
                    color: isCritical ? const Color(0xFFFF7675) : Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  Container(height: 8, color: Colors.white12),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: pct),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    builder: (context, val, _) => FractionallySizedBox(
                      widthFactor: val,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: colors),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradient),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: gradient.first.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1))],
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String desc;
  final int price;
  final bool canAfford;
  final VoidCallback onTap;

  const _FoodCard({
    required this.emoji,
    required this.name,
    required this.desc,
    required this.price,
    required this.canAfford,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: canAfford ? const Color(0xFFF8F9FA) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: canAfford ? const Color(0xFFFFEAA7) : Colors.grey.shade300, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 26)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7675).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(desc, style: const TextStyle(color: Color(0xFFD63031), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Spacer(),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2D3436))),
            const SizedBox(height: 2),
            Row(
              children: [
                const Text('\u{1FA99}', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  "$price koin",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: canAfford ? const Color(0xFF6C5CE7) : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcadeCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String reward;
  final List<Color> colors;
  final VoidCallback onTap;

  const _ArcadeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.reward,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: colors.first.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), shape: BoxShape.circle),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
                    child: Text(reward, style: const TextStyle(color: Color(0xFFFFEAA7), fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}
