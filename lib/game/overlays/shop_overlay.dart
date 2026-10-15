import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../pet_game.dart';
import '../../data/models/pet_state.dart';

class ShopOverlay extends StatefulWidget {
  final PetGame game;
  final ShopItemType? initialFilter;
  const ShopOverlay({super.key, required this.game, this.initialFilter});
  @override
  State<ShopOverlay> createState() => _ShopOverlayState();
}

class _ShopOverlayState extends State<ShopOverlay> {
  ShopItemType? _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  void _close() {
    widget.game.overlays.remove('ShopOverlay');
    widget.game.overlays.remove('ClosetOverlay');
  }

  @override
  Widget build(BuildContext context) {
    final items = _filter == null
        ? widget.game.saveSystem.allShopItems
        : widget.game.saveSystem.getShopItems(_filter);
    final s = widget.game.petState;

    return Material(
      color: Colors.black.withValues(alpha: 0.65),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          constraints: const BoxConstraints(maxHeight: 600, maxWidth: 460),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.storefront, color: Colors.white, size: 26),
                    const SizedBox(width: 8),
                    Text(
                      _filter == ShopItemType.outfit ? 'Lemari Pakaian \u{1F455}' : 'Toko Petku \u{1F6D2}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        children: [
                          const Text('\u{1FA99}', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 5),
                          Text(
                            "${s.coins}",
                            style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFFFEAA7), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      onPressed: _close,
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Filter Tabs
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _tab(null, 'Semua \u2728'),
                      const SizedBox(width: 8),
                      _tab(ShopItemType.outfit, 'Baju \u{1F455}'),
                      const SizedBox(width: 8),
                      _tab(ShopItemType.food, 'Makanan \u{1F35A}'),
                      const SizedBox(width: 8),
                      _tab(ShopItemType.furniture, 'Perabot \u{1F6CB}'),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),

              // Item Grid
              Flexible(
                child: items.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: Text('Belum ada item di kategori ini', style: TextStyle(color: Colors.black45)),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.88,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: items.length,
                        itemBuilder: (c, i) {
                          final it = items[i];
                          final owned = s.ownedItems.contains(it.id);
                          final isEquipped = it.type == ShopItemType.outfit && s.equippedOutfit == it.id;
                          final canBuy = s.coins >= it.price && !owned;

                          return Container(
                            decoration: BoxDecoration(
                              color: isEquipped
                                  ? const Color(0xFFE8F8F5)
                                  : owned
                                      ? Colors.grey.shade50
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isEquipped
                                    ? const Color(0xFF00B894)
                                    : owned
                                        ? Colors.green.shade200
                                        : Colors.grey.shade200,
                                width: isEquipped ? 2 : 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                // Item Image / Icon
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      it.spritePath,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.contain,
                                      errorBuilder: (c, e, s) => Text(
                                        it.type == ShopItemType.outfit
                                            ? '\u{1F455}'
                                            : it.type == ShopItemType.food
                                                ? '\u{1F35A}'
                                                : '\u{1F9FC}',
                                        style: const TextStyle(fontSize: 32),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  it.name,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF2D3436)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  it.description,
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('\u{1FA99}', style: TextStyle(fontSize: 11)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${it.price} koin',
                                      style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF6C5CE7), fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  height: 32,
                                  child: ElevatedButton(
                                    onPressed: owned
                                        ? (it.type == ShopItemType.outfit
                                            ? () {
                                                HapticFeedback.selectionClick();
                                                widget.game.equipOutfit(it.id);
                                                setState(() {});
                                              }
                                            : null)
                                        : canBuy
                                            ? () {
                                                HapticFeedback.mediumImpact();
                                                final ok = widget.game.buyItem(it.id);
                                                if (ok) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Berhasil membeli ${it.name}!'),
                                                      behavior: SnackBarBehavior.floating,
                                                      duration: const Duration(seconds: 1),
                                                    ),
                                                  );
                                                  setState(() {});
                                                }
                                              }
                                            : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isEquipped
                                          ? const Color(0xFF00B894)
                                          : owned
                                              ? const Color(0xFF6C5CE7)
                                              : canBuy
                                                  ? const Color(0xFFFF7675)
                                                  : Colors.grey.shade300,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      isEquipped
                                          ? 'Dipakai ✓'
                                          : owned
                                              ? (it.type == ShopItemType.outfit ? 'Pakai' : 'Dimiliki')
                                              : (canBuy ? 'Beli' : 'Kurang'),
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

  Widget _tab(ShopItemType? t, String label) {
    final selected = _filter == t;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = t),
      selectedColor: const Color(0xFF6C5CE7),
      backgroundColor: Colors.grey.shade100,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: selected ? FontWeight.bold : FontWeight.w600,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      side: BorderSide(color: selected ? const Color(0xFF6C5CE7) : Colors.transparent),
      showCheckmark: false,
    );
  }
}
