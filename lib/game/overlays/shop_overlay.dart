import 'package:flutter/material.dart';
import '../pet_game.dart';
import '../../data/models/pet_state.dart';

class ShopOverlay extends StatelessWidget {
  final PetGame game;
  const ShopOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final items = game.saveSystem.allShopItems;
    final s = game.petState;
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 560),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                const Text('Toko', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('\u{1FA99} ${s.coins}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6C5CE7))),
                IconButton(
                  onPressed: () => game.overlays.remove('ShopOverlay'),
                  icon: const Icon(Icons.close),
                ),
              ]),
              const Divider(),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.92, crossAxisSpacing: 12, mainAxisSpacing: 12),
                  itemCount: items.length,
                  itemBuilder: (c, i) {
                    final it = items[i];
                    final owned = s.ownedItems.contains(it.id);
                    final canBuy = s.coins >= it.price && !owned;
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: owned ? Colors.green : Colors.grey.shade300, width: owned ? 2 : 1),
                        borderRadius: BorderRadius.circular(12),
                        color: owned ? Colors.green.withValues(alpha: 0.06) : Colors.white,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(children: [
                        // sprite atau fallback emoji
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            it.spritePath,
                            width: 56, height: 56, fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => Text(
                              it.type == ShopItemType.outfit ? '\u{1F455}' : it.type == ShopItemType.food ? '\u{1F35A}' : '\u{1F9FC}',
                              style: const TextStyle(fontSize: 36),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(it.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(it.description, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), textAlign: TextAlign.center),
                        const Spacer(),
                        Text('${it.price} koin', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6C5CE7), fontSize: 12)),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          height: 34,
                          child: ElevatedButton(
                            onPressed: owned
                                ? (it.type == ShopItemType.outfit ? () { game.equipOutfit(it.id); (context as Element).markNeedsBuild(); } : null)
                                : canBuy
                                    ? () {
                                        final ok = game.buyItem(it.id);
                                        if (ok) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Beli ${it.name}!'), duration: const Duration(seconds: 1)));
                                          (context as Element).markNeedsBuild();
                                        }
                                      }
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: owned ? (it.type == ShopItemType.outfit && s.equippedOutfit == it.id ? Colors.green : Colors.grey.shade400) : const Color(0xFF6C5CE7),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            child: Text(owned ? (it.type == ShopItemType.outfit ? (s.equippedOutfit == it.id ? 'Dipakai' : 'Pakai') : 'Dimiliki') : 'Beli'),
                          ),
                        ),
                      ]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
