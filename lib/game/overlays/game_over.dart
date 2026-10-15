import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2D3436),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white12),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 24, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Crying emoji with soft glowing halo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Text('\u{1F97A}', style: TextStyle(fontSize: 44))),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pet Kamu Kelelahan!',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Semua status kebutuhan pet telah habis.\nYuk berikan pertolongan pertama!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 14),
              // Coin Balance Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('\u{1FA99}', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      '$coins Koin',
                      style: const TextStyle(color: Color(0xFFFFEAA7), fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Revive with Coins Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: canPay
                      ? () {
                          HapticFeedback.mediumImpact();
                          game.reviveWithCoins(reviveCost);
                        }
                      : null,
                  icon: const Icon(Icons.favorite, size: 20),
                  label: Text(canPay ? 'Bangkitkan — $reviveCost Koin' : 'Koin Kurang (Butuh $reviveCost)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white12,
                    disabledForegroundColor: Colors.white38,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Free Revive Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    game.onRewardedAdComplete(RewardType.revive);
                  },
                  icon: const Icon(Icons.volunteer_activism, size: 18),
                  label: const Text('Bangkitkan Gratis (Bonus Darurat)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Reset Pet
              TextButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  game.resetPet();
                },
                child: const Text('Mulai Ulang dari Awal', style: TextStyle(color: Colors.white38, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
