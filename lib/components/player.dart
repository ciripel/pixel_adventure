import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/chicken.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/heart.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/helpers/custom_hitbox.dart';
import 'package:pixel_adventure/helpers/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum Character {
  maskDude('Mask Dude'),
  ninjaFrog(),
  pinkMan('Pink Man'),
  virtualGuy('Virtual Guy');

  final String filename;
  const Character([this.filename = 'Ninja Frog']);
}

enum PlayerState {
  idle(),
  running('Run'),
  jumping('Jump'),
  falling('Fall');

  final String filename;
  const PlayerState([this.filename = 'Idle']);
}

class Player extends SpriteAnimationGroupComponent<PlayerState>
    with HasGameReference<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  Character character;

  Player({
    super.position,
    super.anchor = Anchor.topCenter,
    this.character = Character.ninjaFrog,
  });

  final _stepTime = 0.05;

  final _gravity = 9.8;
  final _jumpForce = 270.0;
  final _terminalVelocity = 300.0;
  double horizontalMovement = 0;
  final _moveSpeed = 100.0;
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  int health = 3;
  int previousScore = 0;
  int totalScore = 0;

  bool startAnimationFinished = false;

  final fixedDeltaTime = 1 / 60; // 60 FPS
  double accumulatedTime = 0;

  void init() {
    gotHit = false;
    velocity = Vector2.zero();
    horizontalMovement = 0;
    scale.x = 1;
    startAnimationFinished = false;
    collisionBlocks = [];
  }

  void resetScore() {
    totalScore = 0;
    previousScore = 0;
  }

  List<CollisionBlock> collisionBlocks = [];
  final CustomHitbox hitbox = const CustomHitbox.rectangle(offsetX: 10, offsetY: 7, width: 14, height: 24);

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    // debugMode = true;

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
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (!game.level.started) _enterPlayer();

      if (!game.level.complete && startAnimationFinished) {
        _updatePlayerState();
        _updatePlayerMovement(fixedDeltaTime);
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollisions();
        _checkFall();

        if (health <= 0) {
          game.level.stopwatch.stop();
          removeFromParent();
        }
      }

      accumulatedTime -= fixedDeltaTime;
    }

    game.level.totalPoints = game.level.fruitsPoints + game.level.enemiesPoints + game.level.completeTimePoints;
    game.player.totalScore = game.player.previousScore + game.level.totalPoints;
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.keyA) || keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight);
    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Fruit) other.collidedWithPlayer();
    if (other is Heart) other.collidedWithPlayer();
    if (other is Saw && !gotHit) _gotHit();
    if (other is Checkpoint && game.level.checkpointActive && game.level.complete == false) _finishedLevel();
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Chicken && !gotHit) other.collidedWithPlayer();
    super.onCollision(intersectionPoints, other);
  }

  void _loadAllAnimations() {
    animations = {
      PlayerState.falling: _spriteAnimation(PlayerState.falling, 1)..loop = false,
      PlayerState.idle: _spriteAnimation(PlayerState.idle, 11),
      PlayerState.jumping: _spriteAnimation(PlayerState.jumping, 1)..loop = false,
      PlayerState.running: _spriteAnimation(PlayerState.running, 12),
    };
  }

  SpriteAnimation _spriteAnimation(PlayerState state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/${character.filename}/${state.filename} (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: _stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  void _enterPlayer() {
    current = PlayerState.running;
    game.level.started = true;
    add(
      MoveEffect.to(
        game.level.startPosition,
        EffectController(duration: 1),
      )..onComplete = () {
          startAnimationFinished = true;
          game.level.stopwatch.start();
        },
    );
  }

  void _updatePlayerState() {
    var playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    }
    if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (velocity.x != 0) playerState = PlayerState.running;
    if (velocity.y < 0) playerState = PlayerState.jumping;
    if (velocity.y > 0) playerState = PlayerState.falling;

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    if (isOnGround && hasJumped) _playerJump(dt);

    // if (_velocity.y > _gravity) isOnGround = false; // optional if u do not want to jump while falling

    velocity.x = horizontalMovement * _moveSpeed;
    position.x += velocity.x * dt;
    game.level.background.parallax!.baseVelocity.x = velocity.x / 10;
  }

  void _playerJump(double dt) {
    if (game.playSoundEffects) FlameAudio.play('jump.wav');
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - size.x + hitbox.offsetX + hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + size.x - hitbox.offsetX - hitbox.width;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity
      ..y += _gravity
      ..y = velocity.y.clamp(-_jumpForce, _terminalVelocity);

    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
            break;
          }
        }
      }
    }
  }

  void _gotHit() {
    if (!gotHit) health--;
    if (game.playSoundEffects) FlameAudio.play('hit_hurt.wav');
    if (health <= 0) return;

    gotHit = true;
    add(
      OpacityEffect.fadeOut(
        EffectController(alternate: true, duration: 0.1, repeatCount: 5),
      )..onComplete = () => gotHit = false,
    );
  }

  void _checkFall() {
    final fallen = position.y > game.level.levelName.levelHeight + size.y && !gotHit;

    if (!fallen) return;
    if (game.playSoundEffects) FlameAudio.play('hit_hurt.wav');
    health--;
    if (health <= 0) return;

    gotHit = true;
    scale.x = 1;
    add(
      SequenceEffect([
        MoveEffect.to(
          game.level.startPosition,
          EffectController(duration: 0),
        ),
        OpacityEffect.fadeOut(
          EffectController(alternate: true, duration: 0.1, repeatCount: 5),
        ),
      ])
        ..onComplete = () => gotHit = false,
    );
  }

  void _finishedLevel() {
    if (game.playSoundEffects) FlameAudio.play('end_level.wav');
    current = PlayerState.running;
    game.level.complete = true;
    game.level.stopwatch.stop();
    game.level.completeTimePoints +=
        (health / 3 * (game.level.levelName.maxPointsCoefficient - game.level.stopwatch.elapsedMilliseconds) / 1000)
            .floor();
    add(
      MoveEffect.to(
        game.level.endPosition,
        EffectController(duration: 1),
      )..onComplete = () => game.overlays.add('LevelComplete'),
    );
  }

  void collidedWithEnemy() {
    _gotHit();
  }
}
