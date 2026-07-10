import 'position.dart';

enum PowerUpType { speed, shield, magnet, multiplier }

extension PowerUpDuration on PowerUpType {
  int get durationTicks {
    switch (this) {
      case PowerUpType.speed:
        return 40;
      case PowerUpType.shield:
        return 0; // consumed on collision, not time-based
      case PowerUpType.magnet:
        return 30;
      case PowerUpType.multiplier:
        return 50;
    }
  }
}

class PowerUp {
  final PowerUpType type;
  final Position position;

  const PowerUp(this.type, this.position);
}

/// Tracks remaining duration (in ticks) of each active timed effect.
/// Shield is tracked as a boolean flag (`hasShield`) since it is consumed
/// on collision rather than expiring after a fixed time.
class ActiveEffects {
  final int speedTicks;
  final int magnetTicks;
  final int multiplierTicks;
  final bool hasShield;

  const ActiveEffects({
    this.speedTicks = 0,
    this.magnetTicks = 0,
    this.multiplierTicks = 0,
    this.hasShield = false,
  });

  bool get isSpeedActive => speedTicks > 0;
  bool get isMagnetActive => magnetTicks > 0;
  bool get isMultiplierActive => multiplierTicks > 0;

  ActiveEffects tick() => ActiveEffects(
    speedTicks: speedTicks > 0 ? speedTicks - 1 : 0,
    magnetTicks: magnetTicks > 0 ? magnetTicks - 1 : 0,
    multiplierTicks: multiplierTicks > 0 ? multiplierTicks - 1 : 0,
    hasShield: hasShield,
  );

  ActiveEffects apply(PowerUpType type) {
    switch (type) {
      case PowerUpType.speed:
        return copyWith(speedTicks: PowerUpType.speed.durationTicks);
      case PowerUpType.shield:
        return copyWith(hasShield: true);
      case PowerUpType.magnet:
        return copyWith(magnetTicks: PowerUpType.magnet.durationTicks);
      case PowerUpType.multiplier:
        return copyWith(multiplierTicks: PowerUpType.multiplier.durationTicks);
    }
  }

  ActiveEffects consumeShield() => copyWith(hasShield: false);

  ActiveEffects copyWith({
    int? speedTicks,
    int? magnetTicks,
    int? multiplierTicks,
    bool? hasShield,
  }) => ActiveEffects(
    speedTicks: speedTicks ?? this.speedTicks,
    magnetTicks: magnetTicks ?? this.magnetTicks,
    multiplierTicks: multiplierTicks ?? this.multiplierTicks,
    hasShield: hasShield ?? this.hasShield,
  );
}
