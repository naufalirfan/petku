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
      SnackBar(content: Text(m), duration: const Duration(seconds: 2)),
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
    FoodType.rice => 'Nasi',
    FoodType.fruit => 'Buah',
    FoodType.snack => 'Snack',
    FoodType.drink => 'Minuman',
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
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text('Kasi Makan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            for (final f in FoodType.values)
              ListTile(
                leading: Text(_foodEmoji(f), style: const TextStyle(fontSize: 28)),
                title: Text(_foodName(f)),
                subtitle: Text('${_foodPrice(f)} koin \u2022 ${_foodDesc(f)}'),
                trailing: s.coins < _foodPrice(f)
                    ? const Text('Kurang', style: TextStyle(color: Colors.red))
                    : const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(c);
                  if (game.petState.coins < _foodPrice(f)) {
                    _msg('Koin kurang! Main mini-game dulu.');
                    return;
                  }
                  if (game.petState.hunger >= 100) {
                    _msg('Pet masih kenyang.');
                    return;
                  }
                  game.feed(f);
                  _sync();
                  _msg('Nyam! ${_foodDesc(f)}');
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _onBath() {
    HapticFeedback.mediumImpact();
    final price = BalanceConfig.get<int>('soap');
    if (game.petState.coins < price) {
      _msg('Koin kurang! Main mini-game dulu.');
      return;
    }
    if (game.petState.clean >= 100) {
      _msg('Pet sudah bersih.');
      return;
    }
    game.bathe();
    _sync();
    _msg('+Bersih!');
  }

  void _onSleep() {
    HapticFeedback.lightImpact();
    if (game.petState.energy >= 100) {
      _msg('Pet masih segar.');
      return;
    }
    game.sleep();
    _sync();
    _msg('+Energi!');
  }

  void _onPlay() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text('Pilih Mini-Game', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Text('\u{1F370}', style: TextStyle(fontSize: 28)),
              title: const Text('Tangkap Makanan'),
              subtitle: const Text('Tap secepatnya, tiap tap +2 koin'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(c);
                game.playMiniGame(MiniGameType.catchGame);
              },
            ),
            ListTile(
              leading: const Text('\u{1F98A}', style: TextStyle(fontSize: 28)),
              title: const Text('Pukul Monster'),
              subtitle: const Text('Tap monster yang muncul, +5 koin'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(c);
                game.playMiniGame(MiniGameType.whackGame);
              },
            ),
            const SizedBox(height: 12),
          ],
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF2D3436), borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  const Text('\u{1FA99}'),
                  const SizedBox(width: 6),
                  Text("${s.coins}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ]),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => game.overlays.add('SettingsOverlay'),
                icon: const Icon(Icons.settings, color: Colors.white),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              _bar('\u{1F35A}', s.hunger, const Color(0xFFFF8A65)),
              const SizedBox(width: 6),
              _bar('\u{1F60A}', s.happy, const Color(0xFFFFD54F)),
              const SizedBox(width: 6),
              _bar('\u2728', s.clean, const Color(0xFF4FC3F7)),
              const SizedBox(width: 6),
              _bar('\u26A1', s.energy, const Color(0xFF81C784)),
            ]),
          ),
          const Spacer(),
          // ponytail: banner AdMob dikosongkan — balikin _bannerSlot() saat ada App ID
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _action(Icons.restaurant, 'Makan', _onEat),
                _action(Icons.bathtub, 'Mandi', _onBath),
                _action(Icons.checkroom, 'Closet', _onCloset),
                _action(Icons.lightbulb_outline, 'Lamp', _onSleep),
                _action(Icons.videogame_asset, 'Main', _onPlay),
                _action(Icons.store, 'Toko', _onShop),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(String emoji, int val, Color c) => Expanded(
    child: Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 14)),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(value: val / 100, minHeight: 10, backgroundColor: Colors.white24, valueColor: AlwaysStoppedAnimation(c)),
      ),
      Text("$val%", style: const TextStyle(color: Colors.white, fontSize: 10)),
    ]),
  );

  Widget _action(IconData icon, String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      CircleAvatar(radius: 28, backgroundColor: const Color(0xFF6C5CE7), child: Icon(icon, color: Colors.white)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    ]),
  );
}
