import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'game/pet_game.dart';
import 'game/overlays/hud.dart';
import 'game/overlays/shop_overlay.dart';
import 'game/overlays/mini_game_catch.dart';
import 'game/overlays/mini_game_whack.dart';
import 'game/overlays/settings_overlay.dart';
import 'game/overlays/game_over.dart';
import 'game/overlays/onboarding_overlay.dart';
import 'game/overlays/daily_reward_overlay.dart';
import 'utils/notifications.dart';
import 'data/models/pet_state.dart';
import 'data/models/pet_state_adapter.dart';
import 'data/repository/local_repo.dart';
import 'config/balance.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!Hive.isBoxOpen('pet_data') && !Hive.isBoxOpen('shop_items')) {
    try { await Hive.initFlutter(); } catch (_) {}
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(PetStateAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(ShopItemAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ShopItemTypeAdapter());
    if (!Hive.isBoxOpen('pet_data')) await Hive.openBox<PetState>('pet_data');
    if (!Hive.isBoxOpen('shop_items')) await Hive.openBox<ShopItem>('shop_items');
  }
  final repo = LocalRepo();
  await repo.init();
  BalanceConfig.loadDefaults();
  await NotifHelper.init();
  runApp(ChangeNotifierProvider.value(value: repo, child: const PetGameApp()));
}

class PetGameApp extends StatelessWidget {
  const PetGameApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF6C5CE7)),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late final PetGame _game;
  bool _bootShown = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _game = PetGame();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootFlow());
  }

  Future<void> _bootFlow() async {
    if (_bootShown) return;
    _bootShown = true;
    // tunggu game load: poll petState via saveSystem ready
    for (int i = 0; i < 50; i++) {
      try {
        // ignore: unused_local_variable
        final s = _game.petState;
        break;
      } catch (_) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    if (!mounted) return;
    if (_game.needsOnboarding) {
      _game.overlays.add('Onboarding');
      // tunggu onboarding selesai sebelum daily
      for (int i = 0; i < 600; i++) {
        if (!_game.needsOnboarding) break;
        await Future.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;
      }
    }
    if (!mounted) return;
    if (_game.hasPendingDailyReward) {
      await DailyRewardOverlay.showIfPending(context, _game);
    }
    await _game.scheduleNotifications();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _game.disposeGame();
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _game.onAppPaused();
    if (state == AppLifecycleState.resumed) _game.onAppResumed();
  }
  @override
  Widget build(BuildContext context) {
    return GameWidget.controlled(
      gameFactory: () => _game,
      overlayBuilderMap: {
        'HUD': (c, g) => HUDOverlay(game: g as PetGame),
        'ShopOverlay': (c, g) => ShopOverlay(game: g as PetGame),
        'MiniGameCatch': (c, g) => MiniGameCatchOverlay(game: g as PetGame),
        'MiniGameWhack': (c, g) => MiniGameWhackOverlay(game: g as PetGame),
        'SettingsOverlay': (c, g) => SettingsOverlay(game: g as PetGame),
        'GameOverOverlay': (c, g) => GameOverOverlay(game: g as PetGame),
        'Onboarding': (c, g) => OnboardingOverlay(game: g as PetGame),
      },
      initialActiveOverlays: const ['HUD'],
    );
  }
}
