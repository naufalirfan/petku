import 'package:hive/hive.dart';
import 'pet_state.dart';

// Manual adapters - drop-in replacement untuk .g.dart
// Supaya langsung jalan tanpa build_runner

class PetStateAdapter extends TypeAdapter<PetState> {
  @override
  final int typeId = 0;

  @override
  PetState read(BinaryReader reader) {
    final hunger = reader.readInt();
    final happy = reader.readInt();
    final clean = reader.readInt();
    final energy = reader.readInt();
    final coins = reader.readInt();
    final ownedItems = (reader.read() as List).cast<String>();
    final equippedOutfit = reader.readString();
    final lastActiveEpochMs = reader.readInt();
    final dailyLoginStreak = reader.readInt();
    final lastLoginDate = reader.readInt();
    // migrasi: save lama belum punya adsRemoved -> default false
    bool adsRemoved = false;
    try { adsRemoved = reader.readBool(); } catch (_) { adsRemoved = false; }
    bool onboardingDone = false;
    int dailyRewardClaimedDate = 0;
    try { onboardingDone = reader.readBool(); } catch (_) {}
    try { dailyRewardClaimedDate = reader.readInt(); } catch (_) {}
    return PetState.full(
      hunger: hunger,
      happy: happy,
      clean: clean,
      energy: energy,
      coins: coins,
      ownedItems: ownedItems,
      equippedOutfit: equippedOutfit,
      lastActiveEpochMs: lastActiveEpochMs,
      dailyLoginStreak: dailyLoginStreak,
      lastLoginDate: lastLoginDate,
      adsRemoved: adsRemoved,
      onboardingDone: onboardingDone,
      dailyRewardClaimedDate: dailyRewardClaimedDate,
    );
  }

  @override
  void write(BinaryWriter writer, PetState obj) {
    writer.writeInt(obj.hunger);
    writer.writeInt(obj.happy);
    writer.writeInt(obj.clean);
    writer.writeInt(obj.energy);
    writer.writeInt(obj.coins);
    writer.write(obj.ownedItems);
    writer.writeString(obj.equippedOutfit);
    writer.writeInt(obj.lastActiveEpochMs);
    writer.writeInt(obj.dailyLoginStreak);
    writer.writeInt(obj.lastLoginDate);
    writer.writeBool(obj.adsRemoved);
    writer.writeBool(obj.onboardingDone);
    writer.writeInt(obj.dailyRewardClaimedDate);
  }
}

class ShopItemTypeAdapter extends TypeAdapter<ShopItemType> {
  @override
  final int typeId = 1;

  @override
  ShopItemType read(BinaryReader reader) {
    return ShopItemType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, ShopItemType obj) {
    writer.writeByte(obj.index);
  }
}

class ShopItemAdapter extends TypeAdapter<ShopItem> {
  @override
  final int typeId = 2;

  @override
  ShopItem read(BinaryReader reader) {
    return ShopItem(
      id: reader.readString(),
      name: reader.readString(),
      type: ShopItemType.values[reader.readByte()],
      price: reader.readInt(),
      spritePath: reader.readString(),
      effectValue: reader.readInt(),
      description: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, ShopItem obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeByte(obj.type.index);
    writer.writeInt(obj.price);
    writer.writeString(obj.spritePath);
    writer.writeInt(obj.effectValue);
    writer.writeString(obj.description);
  }
}
