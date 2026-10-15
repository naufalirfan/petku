import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/pet_state.dart';
import '../../config/balance.dart';
import 'package:intl/intl.dart';

class LocalRepo extends ChangeNotifier {
  late Box<PetState> _petBox;
  late Box<ShopItem> _shopBox;
  PetState? _state;
  
  PetState get state => _state ?? PetState();
  
  Future<void> init() async {
    _petBox = Hive.box<PetState>('pet_data');
    _shopBox = Hive.box<ShopItem>('shop_items');
    
    if (_petBox.isEmpty) {
      _state = PetState()
        ..coins = 100
        ..lastActiveEpochMs = DateTime.now().millisecondsSinceEpoch;
      await _petBox.put('main', _state!);
    } else {
      _state = _petBox.get('main')!;
    }
    
    _seedShopItems();
    _checkDailyLogin();
  }
  
  void _seedShopItems() {
    if (_shopBox.isNotEmpty) return;
    final items = [
      ShopItem(
        id: 'food_rice',
        name: 'Nasi',
        type: ShopItemType.food,
        price: BalanceConfig.get<int>('food_rice'),
        spritePath: 'assets/images/food_rice.png',
        effectValue: 25,
        description: '+25 Lapar',
      ),
      ShopItem(
        id: 'food_fruit',
        name: 'Buah',
        type: ShopItemType.food,
        price: BalanceConfig.get<int>('food_fruit'),
        spritePath: 'assets/images/food_fruit.png',
        effectValue: 35,
        description: '+35 Lapar',
      ),
      ShopItem(
        id: 'food_snack',
        name: 'Snack',
        type: ShopItemType.food,
        price: BalanceConfig.get<int>('food_snack'),
        spritePath: 'assets/images/food_snack.png',
        effectValue: 50,
        description: '+50 Lapar',
      ),
      ShopItem(
        id: 'soap_basic',
        name: 'Sabun',
        type: ShopItemType.consumable,
        price: BalanceConfig.get<int>('soap'),
        spritePath: 'assets/images/soap.png',
        effectValue: 30,
        description: '+30 Bersih',
      ),
      ShopItem(
        id: 'shirt_basic',
        name: 'Baju Biru',
        type: ShopItemType.outfit,
        price: BalanceConfig.get<int>('shirt_basic'),
        spritePath: 'assets/images/shirt_basic.png',
        effectValue: 0,
        description: 'Kosmetik',
      ),
      ShopItem(
        id: 'bed_basic',
        name: 'Kasur Empuk',
        type: ShopItemType.furniture,
        price: BalanceConfig.get<int>('bed_basic'),
        spritePath: 'assets/images/bed_basic.png',
        effectValue: 0,
        description: 'Dekorasi kamar',
      ),
    ];
    for (final item in items) {
      _shopBox.put(item.id, item);
    }
  }
  
  void _checkDailyLogin() {
    final today = int.parse(DateFormat('yyyyMMdd').format(DateTime.now()));
    if (state.lastLoginDate != today) {
      if (state.lastLoginDate == today - 1) {
        state.dailyLoginStreak += 1;
      } else if (state.lastLoginDate != 0) {
        // putus streak jika skip hari, tapi biarkan 1 jika first login
        state.dailyLoginStreak = 1;
      } else {
        state.dailyLoginStreak = 1;
      }
      state.lastLoginDate = today;
      save();
    }
  }

  bool get hasPendingDailyReward {
    final today = int.parse(DateFormat('yyyyMMdd').format(DateTime.now()));
    return state.dailyRewardClaimedDate != today;
  }

  int get pendingDailyReward {
    final s = state.dailyLoginStreak;
    if (s >= 7) return BalanceConfig.get<int>('daily_login_day7');
    return BalanceConfig.get<int>('daily_login_day1') * (s == 0 ? 1 : s);
  }

  int claimDailyReward() {
    final today = int.parse(DateFormat('yyyyMMdd').format(DateTime.now()));
    if (state.dailyRewardClaimedDate == today) return 0;
    final reward = pendingDailyReward;
    state.coins += reward;
    state.dailyRewardClaimedDate = today;
    save();
    return reward;
  }
  
  List<ShopItem> getShopItems([ShopItemType? filter]) {
    final all = _shopBox.values.toList();
    if (filter == null) return all;
    return all.where((e) => e.type == filter).toList();
  }
  
  ShopItem? getItem(String id) => _shopBox.get(id);
  
  Future<void> save() async {
    await _state?.save();
    notifyListeners();
  }
}
