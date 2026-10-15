import 'package:flutter/foundation.dart';
import '../pet_game.dart';

// Stub tanpa AdMob — aktifkan lagi saat sudah punya App ID.
// ponytail: ganti file ini dengan implementasi google_mobile_ads real
// dan uncomment google_mobile_ads di pubspec.yaml + meta-data di Manifest/Info.plist.
class AdSystem {
  final PetGame game;
  AdSystem(this.game);
  Future<void> init() async {
    if (kDebugMode) debugPrint('[Ads] stub — AdMob dimatikan');
  }
  void showRewardedAd(RewardType type) {
    // stub: langsung kasih reward biar flow tidak nge-hang
    if (kDebugMode) debugPrint('[Ads] stub rewarded $type -> langsung reward');
    Future.delayed(const Duration(milliseconds: 300), () => game.onRewardedAdComplete(type));
  }
  bool canShowInterstitial() => false;
  void showInterstitial() {}
  void loadBanner() {}
  void hideBanner() {}
  void dispose() {}
}
