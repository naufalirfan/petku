import 'package:flutter/foundation.dart';
import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  bool bgmOn = true;
  bool sfxOn = true;
  bool _inited = false;

  Future<void> init() async {
    if (_inited) return;
    try {
      await FlameAudio.bgm.initialize();
      await FlameAudio.audioCache.loadAll(['eat.wav','splash.wav','sleep.wav','coin.wav','button.wav','sad.wav','bgm.wav']);
      _inited = true;
      if (bgmOn) FlameAudio.bgm.play('bgm.wav');
      if (kDebugMode) debugPrint('[Audio] real ok');
    } catch (e) {
      if (kDebugMode) debugPrint('[Audio] init fail: $e');
    }
  }

  void playSfx(String name) {
    if (!sfxOn) return;
    try { FlameAudio.play('$name.wav'); } catch (e) {
      if (kDebugMode) debugPrint('[SFX fail] $name: $e');
    }
  }

  void playBgm(String file) {
    if (!bgmOn) return;
    try { FlameAudio.bgm.play(file); } catch (_) {}
  }

  void pauseBgm() { try { FlameAudio.bgm.pause(); } catch (_) {} }
  void resumeBgm() { if (bgmOn) try { FlameAudio.bgm.resume(); } catch (_) {} }
  void stopBgm() { try { FlameAudio.bgm.stop(); } catch (_) {} }
  void toggleBgm() {
    bgmOn = !bgmOn;
    if (!bgmOn) { pauseBgm(); } else { resumeBgm(); }
  }
  void toggleSfx() { sfxOn = !sfxOn; }
  void dispose() { try { FlameAudio.bgm.dispose(); } catch (_) {} }
}
