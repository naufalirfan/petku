import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../pet_game.dart';

class SettingsOverlay extends StatefulWidget {
  final PetGame game;
  const SettingsOverlay({super.key, required this.game});
  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay> {
  PetGame get game => widget.game;

  void _toggleAds() {
    HapticFeedback.selectionClick();
    final next = !game.petState.adsRemoved;
    game.setAdsRemoved(next);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(next ? 'Status Premium aktif (Bebas Iklan)' : 'Status Standar aktif'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmReset() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Pet? \u{1F622}', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Semua status akan di-reset ke 50% dan koin kembali ke 100. Yakin ingin memulai ulang?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(c);
              game.resetPet();
              game.overlays.remove('SettingsOverlay');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pet berhasil di-reset ke kondisi awal'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Ya, Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.65),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.settings, color: Color(0xFF6C5CE7), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text('Pengaturan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF2D3436))),
                  const Spacer(),
                  IconButton(
                    onPressed: () => game.overlays.remove('SettingsOverlay'),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 6),

              // Switches
              Container(
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.music_note, color: Color(0xFF6C5CE7)),
                      title: const Text('Musik Latar (BGM)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      value: game.audioManager.bgmOn,
                      activeThumbColor: const Color(0xFF6C5CE7),
                      onChanged: (_) => setState(() => game.audioManager.toggleBgm()),
                    ),
                    const Divider(height: 1, indent: 56),
                    SwitchListTile(
                      secondary: const Icon(Icons.volume_up, color: Color(0xFF00B894)),
                      title: const Text('Efek Suara (SFX)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      value: game.audioManager.sfxOn,
                      activeThumbColor: const Color(0xFF00B894),
                      onChanged: (_) => setState(() => game.audioManager.toggleSfx()),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Account / Premium Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: game.petState.adsRemoved
                        ? [const Color(0xFFFFF9E6), const Color(0xFFFFF3CD)]
                        : [Colors.grey.shade100, Colors.grey.shade50],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: game.petState.adsRemoved ? const Color(0xFFFFD700) : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      game.petState.adsRemoved ? '\u{1F451}' : '\u{1F4E6}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game.petState.adsRemoved ? 'Status: PREMIUM' : 'Status: Standard',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: game.petState.adsRemoved ? const Color(0xFFD4AF37) : const Color(0xFF2D3436),
                            ),
                          ),
                          Text(
                            game.petState.adsRemoved ? 'Bebas iklan banner' : 'Dukung game ini dengan bermain tiap hari',
                            style: const TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Toggle Premium button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6C5CE7),
                    side: const BorderSide(color: Color(0xFF6C5CE7)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _toggleAds,
                  child: Text(
                    game.petState.adsRemoved ? 'Alihkan ke Mode Standard' : 'Buka Fitur Premium',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Reset Pet
              TextButton.icon(
                onPressed: _confirmReset,
                icon: const Icon(Icons.restart_alt, color: Colors.redAccent, size: 18),
                label: const Text('Reset Progres Pet', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
