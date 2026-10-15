import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class PetState extends HiveObject {
  @HiveField(0)
  int hunger = 100;
  @HiveField(1)
  int happy = 100;
  @HiveField(2)
  int clean = 100;
  @HiveField(3)
  int energy = 100;
  @HiveField(4)
  int coins = 100;
  @HiveField(5)
  List<String> ownedItems = [];
  @HiveField(6)
  String equippedOutfit = 'none';
  @HiveField(7)
  int lastActiveEpochMs = 0;
  @HiveField(8)
  int dailyLoginStreak = 0;
  @HiveField(9)
  int lastLoginDate = 0;
  @HiveField(10)
  bool adsRemoved = false;
  @HiveField(11)
  bool onboardingDone = false;
  @HiveField(12)
  int dailyRewardClaimedDate = 0;
  
  PetState();
  
  PetState.full({
    required this.hunger,
    required this.happy,
    required this.clean,
    required this.energy,
    required this.coins,
    required this.ownedItems,
    required this.equippedOutfit,
    required this.lastActiveEpochMs,
    required this.dailyLoginStreak,
    required this.lastLoginDate,
    required this.adsRemoved,
    required this.onboardingDone,
    required this.dailyRewardClaimedDate,
  });
}

@HiveType(typeId: 1)
enum ShopItemType {
  @HiveField(0)
  food,
  @HiveField(1)
  consumable,
  @HiveField(2)
  outfit,
  @HiveField(3)
  furniture,
}

@HiveType(typeId: 2)
class ShopItem extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final ShopItemType type;
  @HiveField(3)
  final int price;
  @HiveField(4)
  final String spritePath;
  @HiveField(5)
  final int effectValue;
  @HiveField(6)
  final String description;
  
  ShopItem({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.spritePath,
    required this.effectValue,
    required this.description,
  });
}
