import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'components/pet.dart';
import 'components/pet_particles.dart';
import 'components/bedroom.dart';
import 'systems/status_system.dart';
import 'systems/save_system.dart';
import 'systems/ad_system.dart';
import '../data/models/pet_state.dart';
import '../config/balance.dart';
import '../utils/audio.dart';
import '../utils/notifications.dart';

class PetGame extends FlameGame with HasCollisionDetection {
  late final PetComponent pet;
  late final StatusSystem statusSystem;
  late final SaveSystem saveSystem;
  late final AdSystem adSystem;
  late final AudioManager audioManager;
  PetState get petState => saveSystem.petState;
  bool isGameOver = false;
  BedroomComponent? _bedroom;
  DateTime? lastBackgroundTime;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    saveSystem = SaveSystem(this);
    await saveSystem.load();
    statusSystem = StatusSystem(this);
    adSystem = AdSystem(this);
    audioManager = AudioManager();
    _bedroom = BedroomComponent();
    add(_bedroom!);
    pet = PetComponent(game: this);
    add(pet);
    add(statusSystem);
    await audioManager.init();
    await adSystem.init();
    // center after size known - also in onGameResize

    _applyBackgroundDecay();
    _startAutoSave();
  }

  void _applyBackgroundDecay() {
    final lastActive = petState.lastActiveEpochMs;
    if (lastActive > 0) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final minutesAway = (now - lastActive) / 60000;
      if (minutesAway > 1) statusSystem.applyBackgroundDecay(minutesAway);
    }
    petState.lastActiveEpochMs = DateTime.now().millisecondsSinceEpoch;
  }
  void _startAutoSave() => add(TimerComponent(period: 30, repeat: true, onTick: () => saveSystem.save()));
  void onAppPaused() {
    lastBackgroundTime = DateTime.now();
    NotifHelper.scheduleHungryReminder();
    petState.lastActiveEpochMs = lastBackgroundTime!.millisecondsSinceEpoch;
    saveSystem.save();
    audioManager.pauseBgm();
  }
  void spawnBurst(BurstType type) {
    try { add(BurstEffect(at: pet.position.clone(), type: type)); } catch (_) {}
  }
  void onPetTapped() {
    if (isGameOver) return;
    pet.playHappyAnimation();
    spawnBurst(BurstType.hearts);
    audioManager.playSfx('button');
    statusSystem.modifyHappy(1);
    saveSystem.save();
  }
  void disposeGame() { try { adSystem.dispose(); } catch (_) {} try { audioManager.dispose(); } catch (_) {} }
  void onAppResumed() {
    if (lastBackgroundTime != null) {
      final m = DateTime.now().difference(lastBackgroundTime!).inMinutes.toDouble();
      if (m > 1) statusSystem.applyBackgroundDecay(m);
    }
    petState.lastActiveEpochMs = DateTime.now().millisecondsSinceEpoch;
    audioManager.resumeBgm();
  }
  bool feed(FoodType type) {
    if (isGameOver) return false;
    final price = _foodPrice(type);
    if (petState.coins < price) return false;
    if (petState.hunger >= 100) return false;
    final c = BalanceConfig.values;
    final recover = switch (type) {
      FoodType.rice => c['feed_recover'] as int,
      FoodType.fruit => (c['feed_recover'] as int) + 10,
      FoodType.snack => (c['feed_recover'] as int) + 25,
      FoodType.drink => (c['feed_recover'] as int) + 5,
    };
    statusSystem.modifyHunger(recover);
    petState.coins -= price;
    pet.playEatAnimation();
    audioManager.playSfx('eat');
    saveSystem.save();
    return true;
  }
  bool bathe() {
    if (isGameOver) return false;
    final price = BalanceConfig.values['soap'] as int;
    if (petState.coins < price) return false;
    if (petState.clean >= 100) return false;
    statusSystem.modifyClean(BalanceConfig.values['bath_recover'] as int);
    petState.coins -= price;
    pet.playBathAnimation();
    spawnBurst(BurstType.bubbles);
    audioManager.playSfx('splash');
    saveSystem.save();
    return true;
  }
  bool sleep() {
    if (isGameOver) return false;
    if (petState.energy >= 100) return false;
    statusSystem.modifyEnergy(BalanceConfig.values['sleep_recover'] as int);
    pet.playSleepAnimation();
    audioManager.playSfx('sleep');
    saveSystem.save();
    return true;
  }
  void playMiniGame(MiniGameType type) {
    overlays.add(type == MiniGameType.catchGame ? 'MiniGameCatch' : 'MiniGameWhack');
    audioManager.playSfx('button');
  }
  void onMiniGameComplete(MiniGameType type, int score) {
    overlays.remove(type == MiniGameType.catchGame ? 'MiniGameCatch' : 'MiniGameWhack');
    final c = BalanceConfig.values;
    final perfect = score >= 60;
    final reward = score + (perfect ? c['minigame_perfect_coin'] as int : c['minigame_win_coin'] as int);
    petState.coins += reward;
    statusSystem.modifyHappy(c['play_recover_happy'] as int);
    statusSystem.modifyEnergy(c['play_recover_energy'] as int);
    pet.playHappyAnimation();
    spawnBurst(BurstType.confetti);
    audioManager.playSfx('coin');
    saveSystem.save();
  }
  bool buyItem(String id) {
    final item = saveSystem.getShopItem(id);
    if (item == null || petState.coins < item.price || petState.ownedItems.contains(id)) return false;
    petState.coins -= item.price;
    petState.ownedItems.add(id);
    if (item.type == ShopItemType.outfit) { petState.equippedOutfit = id; pet.updateOutfit(id); }
    audioManager.playSfx('coin');
    saveSystem.save();
    return true;
  }
  bool reviveWithCoins(int cost) {
    if (petState.coins < cost) return false;
    petState.coins -= cost;
    isGameOver = false;
    statusSystem.reviveAll();
    pet.playHappyAnimation();
    spawnBurst(BurstType.confetti);
    try { overlays.remove('GameOverOverlay'); } catch (_) {}
    saveSystem.save();
    return true;
  }

  void resetPet() {
    petState.hunger = 50;
    petState.happy = 50;
    petState.clean = 50;
    petState.energy = 50;
    petState.coins = 100;
    isGameOver = false;
    pet.playHappyAnimation();
    overlays.remove('GameOverOverlay');
    saveSystem.save();
  }
  void equipOutfit(String id) {
    if (!petState.ownedItems.contains(id)) return;
    petState.equippedOutfit = id;
    pet.updateOutfit(id);
    saveSystem.save();
  }
  bool get needsOnboarding => !petState.onboardingDone;

  void completeOnboarding() {
    petState.onboardingDone = true;
    saveSystem.save();
    try { overlays.remove('Onboarding'); } catch (_) {}
  }

  bool get hasPendingDailyReward {
    final now = DateTime.now();
    final today = now.year * 10000 + now.month * 100 + now.day;
    return petState.dailyRewardClaimedDate != today;
  }

  int claimDailyReward() {
    final now = DateTime.now();
    final today = now.year * 10000 + now.month * 100 + now.day;
    if (petState.dailyRewardClaimedDate == today) return 0;
    final streak = petState.dailyLoginStreak == 0 ? 1 : petState.dailyLoginStreak;
    final reward = streak >= 7 ? 500 : 50 * streak;
    petState.coins += reward;
    petState.dailyRewardClaimedDate = today;
    saveSystem.save();
    try { add(BurstEffect(at: pet.position.clone(), type: BurstType.confetti)); } catch (_) {}
    audioManager.playSfx('coin');
    return reward;
  }

  Future<void> scheduleNotifications() async {
    await NotifHelper.requestPermission();
    await NotifHelper.scheduleHungryReminder();
  }

  // stub: AdMob mati — simpan flag saja, banner diurus saat AdMob nyala
  void setAdsRemoved(bool v) {
    petState.adsRemoved = v;
    saveSystem.save();
  }

  void watchRewardedAd(RewardType type) => adSystem.showRewardedAd(type);
  void onRewardedAdComplete(RewardType type) {
    if (type == RewardType.revive) {
      isGameOver = false;
      statusSystem.reviveAll();
      pet.playHappyAnimation();
      spawnBurst(BurstType.confetti);
      overlays.remove('GameOverOverlay');
    }
    saveSystem.save();
  }
  void checkGameOver() {
    if (petState.hunger <= 0 && petState.happy <= 0 && petState.clean <= 0 && petState.energy <= 0) {
      if (!isGameOver) { isGameOver = true; overlays.add('GameOverOverlay'); audioManager.playSfx('sad'); }
    }
  }
  int _foodPrice(FoodType type) {
    final c = BalanceConfig.values;
    return switch (type) {
      FoodType.rice => c['food_rice'] as int,
      FoodType.fruit => c['food_fruit'] as int,
      FoodType.snack => c['food_snack'] as int,
      FoodType.drink => c['food_rice'] as int,
    };
  }
  @override
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _bedroom?.size = size;
    try { pet.position = _bedroom?.bedCenter ?? size / 2; } catch (_) {}
  }
  @override
  void onRemove() { try { adSystem.dispose(); } catch (_) {} try { audioManager.dispose(); } catch (_) {} super.onRemove(); }
  @override
  void update(double dt) { super.update(dt); checkGameOver(); }
}
enum FoodType { rice, fruit, snack, drink }
enum MiniGameType { catchGame, whackGame }
enum RewardType { coinDouble, revive }
