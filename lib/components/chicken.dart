import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/components/level.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum ChickenState {
  hit('Hit'),
  idle(),
  run('Run');

  final String filename;
  const ChickenState([this.filename = 'Idle']);
}

class Chicken extends SpriteAnimationGroupComponent<ChickenState> with HasGameReference<PixelAdventure> {
  final double offNeg;
  final double offPos;
  Chicken({
    super.position,
    super.size,
    super.priority = -3,
    this.offNeg = 0,
    this.offPos = 0,
  });

  static const _stepTime = 0.05;
  static const _runSpeed = 80;
  // This is extra vertical sight of chicken up and down if needed.
  // 32 match exactly the player jump distance over the chicken
  static const _chickenVerticalRange = 0;
  static const _bounceHeight = 200.0;
  static const killPoints = 100;
  final hitbox = const CustomHitbox.rectangle(offsetX: 4, offsetY: 6, width: 24, height: 26);

  double rangeNeg = 0;
  double rangePos = 0;
  Vector2 velocity = Vector2.zero();
  double moveDirection = 1;
  double targetDirection = -1;
  bool gotStomped = false;

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    _loadAllAnimations();
    _calculateRange();

    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        isSolid: true,
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotStomped) {
      _updateState();
      _movement(dt);
    }

    super.update(dt);
  }

  void _loadAllAnimations() {
    animations = {
      ChickenState.hit: _spriteAnimation(ChickenState.hit, 5)..loop = false,
      ChickenState.idle: _spriteAnimation(ChickenState.idle, 13),
      ChickenState.run: _spriteAnimation(ChickenState.run, 14),
    };

    current = ChickenState.idle;
  }

  SpriteAnimation _spriteAnimation(ChickenState state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Chicken/${state.filename} (32x34).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: _stepTime,
        textureSize: Vector2(32, 34),
      ),
    );
  }

  void _calculateRange() {
    rangeNeg = position.x - offNeg * Level.tileSize;
    rangePos = position.x + offPos * Level.tileSize;
  }

  void _movement(double dt) {
    velocity.x = 0;

    final playerOffset = (game.player.scale.x > 0) ? 0.0 : -game.player.width;
    final chickenOffset = (scale.x > 0) ? 0.0 : -width;

    if (_playerInRange(playerOffset)) {
      targetDirection = (game.player.x + playerOffset < position.x + chickenOffset) ? -1 : 1;
      velocity.x = targetDirection * _runSpeed;
    }

    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;

    position.x += velocity.x * dt;
  }

  bool _playerInRange(double playerOffset) {
    return game.player.x + playerOffset >= rangeNeg &&
        game.player.x + playerOffset <= rangePos &&
        game.player.y + game.player.height + _chickenVerticalRange > position.y &&
        game.player.y < position.y + height + _chickenVerticalRange;
  }

  void _updateState() {
    current = (velocity.x != 0) ? ChickenState.run : ChickenState.idle;
    if ((moveDirection > 0 && scale.x > 0) || (moveDirection < 0 && scale.x < 0)) flipHorizontallyAroundCenter();
  }

  void collidedWithPlayer() async {
    if (game.player.velocity.y > 0 && game.player.y + game.player.height > position.y) {
      if (game.playSoundEffects) FlameAudio.play('stomp.wav');
      gotStomped = true;
      current = ChickenState.hit;
      game.player.enemiesPoints += killPoints;
      game.player.velocity.y = -_bounceHeight;
      await animationTicker?.completed;
      removeFromParent();

      return;
    }
    game.player.collidedWithEnemy();
  }
}
