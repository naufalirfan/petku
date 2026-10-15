import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_game/config/balance.dart';
import 'package:pet_game/data/models/pet_state.dart';

void main() {
  test('balance defaults load', () {
    BalanceConfig.loadDefaults();
    expect(BalanceConfig.get<int>('food_rice'), 50);
    expect(BalanceConfig.get<int>('food_fruit'), 80);
    expect(BalanceConfig.get<double>('hunger_decay_per_min'), closeTo(1.2, 0.01));
  });

  test('pet state defaults', () {
    final s = PetState();
    expect(s.hunger, 100);
    expect(s.coins, 100);
    expect(s.ownedItems, isEmpty);
  });

  test('shop item model', () {
    final it = ShopItem(
      id: 'food_rice',
      name: 'Nasi',
      type: ShopItemType.food,
      price: 50,
      spritePath: 'assets/images/food_rice.png',
      effectValue: 25,
      description: '+25 Lapar',
    );
    expect(it.price, 50);
    expect(it.type, ShopItemType.food);
  });

  testWidgets('material app builds', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Pet Game'))),
    );
    expect(find.text('Pet Game'), findsOneWidget);
  });
}
