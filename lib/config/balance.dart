class BalanceConfig {
  static const Map<String, dynamic> _defaults = {
    // Decay per menit (real-time, background pakai last_active)
    'hunger_decay_per_min': 1.2,
    'happy_decay_per_min': 0.8,
    'clean_decay_per_min': 0.5,
    'energy_decay_per_min': 0.3,

    // Recovery per aksi
    'feed_recover': 25,
    'bath_recover': 30,
    'sleep_recover': 40,
    'play_recover_happy': 15,
    'play_recover_energy': -10,

    // Harga toko (koin)
    'food_rice': 50,
    'food_fruit': 80,
    'food_snack': 120,
    'soap': 100,
    'shirt_basic': 500,
    'bed_basic': 800,

    // Reward
    'minigame_win_coin': 30,
    'minigame_perfect_coin': 60,
    'daily_login_day1': 50,
    'daily_login_day7': 500,

    // Ads
    'rewarded_coin_multiplier': 2,
    'interstitial_cooldown_sec': 180,
  };
  
  static Map<String, dynamic> values = {..._defaults};
  
  static void loadDefaults() {
    values = {..._defaults};
  }
  
  static void update(String key, dynamic value) {
    values[key] = value;
  }
  
  static T get<T>(String key) => values[key] as T;
}
