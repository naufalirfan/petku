import 'package:flutter/material.dart';
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
    final next = !game.petState.adsRemoved;
    game.setAdsRemoved(next);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next ? 'Premium aktif — iklan banner mati' : 'Iklan banner nyala lagi')));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pengaturan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              SwitchListTile(
                title: const Text('Musik'),
                value: game.audioManager.bgmOn,
                onChanged: (_) => setState(() => game.audioManager.toggleBgm()),
              ),
              SwitchListTile(
                title: const Text('SFX'),
                value: game.audioManager.sfxOn,
                onChanged: (_) => setState(() => game.audioManager.toggleSfx()),
              ),
              const SizedBox(height: 8),
              if (game.petState.adsRemoved)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFFFD93D), borderRadius: BorderRadius.circular(20)),
                  child: const Text('PREMIUM — tanpa iklan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                )
              else
                const Text('Banner di bawah HUD pakai test ID Google', style: TextStyle(fontSize: 11, color: Colors.black54)),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => game.overlays.remove('SettingsOverlay'), child: const Text('Tutup'))),
              const SizedBox(height: 8),
              // IAP stub -> toggle premium lokal dulu, ganti ke in_app_purchase saat publish
              TextButton(
                onPressed: _toggleAds,
                child: Text(
                  game.petState.adsRemoved ? 'Kembalikan Iklan (debug)' : 'Hapus Iklan (segera)',
                  style: const TextStyle(color: Color(0xFF6C5CE7)),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(onPressed: () { game.resetPet(); game.overlays.remove('SettingsOverlay'); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pet di-reset ke 50% + 100 koin'))); }, child: const Text('Reset Pet', style: TextStyle(color: Colors.red))),
            ],
          ),
        ),
      ),
    );
  }
}
