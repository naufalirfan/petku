import 'package:hive/hive.dart';
import '../pet_game.dart';
import '../../data/models/pet_state.dart';

class SaveSystem {
  final PetGame game;
  late PetState petState;
  late Box<PetState> petBox;
  late Box<ShopItem> shopBox;

  SaveSystem(this.game);

  Future<void> load() async {
    if (!Hive.isBoxOpen('pet_data')) await Hive.openBox<PetState>('pet_data');
    if (!Hive.isBoxOpen('shop_items')) await Hive.openBox<ShopItem>('shop_items');
    petBox = Hive.box<PetState>('pet_data');
    shopBox = Hive.box<ShopItem>('shop_items');
    petState = petBox.get('main') ?? PetState();
    if (!petBox.containsKey('main')) {
      petState.coins = 100;
      await petBox.put('main', petState);
    }
  }

  Future<void> save() async {
    petState.lastActiveEpochMs = DateTime.now().millisecondsSinceEpoch;
    await petState.save();
  }

  ShopItem? getShopItem(String id) => shopBox.get(id);
  List<ShopItem> get allShopItems => shopBox.values.toList();
  List<ShopItem> getShopItems([ShopItemType? filter]) => filter == null
      ? allShopItems
      : shopBox.values.where((e) => e.type == filter).toList();
}
