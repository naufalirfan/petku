import 'package:flutter/material.dart';
import '../pet_game.dart';

class GameOverOverlay extends StatelessWidget {
  final PetGame game;
  const GameOverOverlay({super.key, required this.game});
  @override
  Widget build(BuildContext context) {
    final coins = game.petState.coins;
    const reviveCost = 50;
    final canPay = coins >= reviveCost;
    return Material(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('\u{1F622}', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            const Text('Pet kamu sedih banget!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('Semua status habis', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text('\u{1FA99} $coins koin', style: const TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canPay ? () { final ok = game.reviveWithCoins(reviveCost); if (!ok) return; } : null,
                icon: const Icon(Icons.favorite),
                label: Text(canPay ? 'Revive — $reviveCost koin' : 'Koin tidak cukup ($reviveCost)'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7), foregroundColor: Colors.white, disabledBackgroundColor: Colors.white24),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => game.onRewardedAdComplete(RewardType.revive),
                icon: const Icon(Icons.play_circle, size: 18),
                label: const Text('Revive gratis (tanpa iklan)'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white70, side: const BorderSide(color: Colors.white24)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: () => game.resetPet(), child: const Text('Reset Pet', style: TextStyle(color: Colors.white54))),
          ]),
        ),
      ),
    );
  }
}
