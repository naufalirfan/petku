import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../pet_game.dart';

class DailyRewardOverlay extends StatelessWidget {
  final PetGame game;
  final int streak;
  final int reward;
  const DailyRewardOverlay({super.key, required this.game, required this.streak, required this.reward});

  static Future<void> showIfPending(BuildContext context, PetGame game) async {
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
    final curDay = (streak - 1) % 7 + 1; // 1 to 7

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon & Title
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA502)]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color(0x66FFA502), blurRadius: 16, offset: Offset(0, 4))],
              ),
              child: const Center(child: Text('\u{1F381}', style: TextStyle(fontSize: 34))),
            ),
            const SizedBox(height: 12),
            const Text(
              'Hadiah Harian!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF2D3436)),
            ),
            const SizedBox(height: 4),
            Text(
              'Streak login hari ke-$streak beruntun \u{1F525}',
              style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 18),

            // 7 Days Grid
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (int day = 1; day <= 7; day++)
                  _DayCard(
                    day: day,
                    isToday: day == curDay,
                    isClaimed: day < curDay,
                    rewardAmount: day == 7 ? 500 : 50 * day,
                  ),
              ],
            ),
            const SizedBox(height: 18),

            // Big Reward Banner for today
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFF9E6), Color(0xFFFFF3CD)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('\u{1FA99}', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 8),
                  Text(
                    '+$reward Koin',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFD4AF37)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Claim Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: const Color(0x666C5CE7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  game.claimDailyReward();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selamat! +$reward koin ditambahkan ke kantong.'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Klaim Hadiah \u2728', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isClaimed;
  final int rewardAmount;

  const _DayCard({
    required this.day,
    required this.isToday,
    required this.isClaimed,
    required this.rewardAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: day == 7 ? 96 : 64,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isToday
            ? const Color(0xFF6C5CE7)
            : isClaimed
                ? Colors.green.shade50
                : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday
              ? const Color(0xFFFFD700)
              : isClaimed
                  ? Colors.green.shade300
                  : Colors.transparent,
          width: isToday ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Hari $day',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isToday ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            day == 7 ? '\u{1F381}' : '\u{1FA99}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(
            '+$rewardAmount',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isToday
                  ? Colors.white
                  : isClaimed
                      ? Colors.green.shade700
                      : const Color(0xFF2D3436),
            ),
          ),
          if (isClaimed)
            const Icon(Icons.check_circle, color: Colors.green, size: 12),
        ],
      ),
    );
  }
}
