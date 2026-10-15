import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../pet_game.dart';

class DailyRewardOverlay extends StatelessWidget {
  final PetGame game;
  final int streak;
  final int reward;
  const DailyRewardOverlay({super.key, required this.game, required this.streak, required this.reward});

  static Future<void> showIfPending(BuildContext context, PetGame game) async {
    // repo is SaveSystem — pending logic lives in LocalRepo via same PetState;
    // compute from petState directly to avoid extra dep
    final s = game.petState;
    final now = DateTime.now();
    final today = now.year * 10000 + now.month * 100 + now.day;
    if (s.dailyRewardClaimedDate == today) return;
    final streak = s.dailyLoginStreak == 0 ? 1 : s.dailyLoginStreak;
    final rwd = streak >= 7 ? 500 : 50 * streak;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DailyRewardOverlay(game: game, streak: streak, reward: rwd),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('\u{1F381} Hadiah Harian', textAlign: TextAlign.center),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Hari ke-$streak beruntun!', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(14)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('\u{1FA99}', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Text('+$reward', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          ]),
        ),
        const SizedBox(height: 8),
        const Text('Login 7 hari beruntun = 500 koin', style: TextStyle(color: Colors.black54, fontSize: 12)),
      ]),
      actions: [
        SizedBox(width: double.infinity, child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () {
            HapticFeedback.mediumImpact();
            game.claimDailyReward();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dapat +$reward koin!'), duration: const Duration(seconds: 2)));
          },
          child: const Text('Klaim', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        )),
      ],
    );
  }
}
