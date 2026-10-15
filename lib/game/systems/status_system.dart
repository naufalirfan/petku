import 'package:flame/components.dart';
import '../pet_game.dart';
import '../../config/balance.dart';
import 'dart:math' as math;

class StatusSystem extends Component {
  final PetGame game;
  double _accum = 0;
  StatusSystem(this.game);

  @override
  void update(double dt) {
    super.update(dt);
    _accum += dt;
    if (_accum < 1.0) return;
    _accum = 0;
    // decay per second derived from per-minute
    final c = BalanceConfig.values;
    _decay('hunger', (c['hunger_decay_per_min'] as double) / 60);
    _decay('happy', (c['happy_decay_per_min'] as double) / 60);
    _decay('clean', (c['clean_decay_per_min'] as double) / 60);
    _decay('energy', (c['energy_decay_per_min'] as double) / 60);
  }

  void _decay(String stat, double amount) {
    final s = game.petState;
    switch (stat) {
      case 'hunger': s.hunger = math.max(0, (s.hunger - amount).round()); break;
      case 'happy': s.happy = math.max(0, (s.happy - amount).round()); break;
      case 'clean': s.clean = math.max(0, (s.clean - amount).round()); break;
      case 'energy': s.energy = math.max(0, (s.energy - amount).round()); break;
    }
  }

  void applyBackgroundDecay(double minutesAway) {
    final c = BalanceConfig.values;
    final s = game.petState;
    s.hunger = math.max(0, (s.hunger - (c['hunger_decay_per_min'] as double) * minutesAway).round());
    s.happy = math.max(0, (s.happy - (c['happy_decay_per_min'] as double) * minutesAway).round());
    s.clean = math.max(0, (s.clean - (c['clean_decay_per_min'] as double) * minutesAway).round());
    s.energy = math.max(0, (s.energy - (c['energy_decay_per_min'] as double) * minutesAway).round());
  }

  void modifyHunger(int v) { game.petState.hunger = (game.petState.hunger + v).clamp(0, 100); }
  void modifyHappy(int v) { game.petState.happy = (game.petState.happy + v).clamp(0, 100); }
  void modifyClean(int v) { game.petState.clean = (game.petState.clean + v).clamp(0, 100); }
  void modifyEnergy(int v) { game.petState.energy = (game.petState.energy + v).clamp(0, 100); }
  void reviveAll() {
    game.petState.hunger = 50;
    game.petState.happy = 50;
    game.petState.clean = 50;
    game.petState.energy = 50;
  }
}
