import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/components/utils.dart';
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
  int fruitsCollected = 0;
  bool startAnimationFinished = false;

  final fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  void init() {
    gotHit = false;
    velocity = Vector2.zero();
    horizontalMovement = 0;
    scale.x = 1;
    startAnimationFinished = false;
    collisionBlocks = [];
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

        if (health <= 0) removeFromParent();
      }

      accumulatedTime -= fixedDeltaTime;
    }

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
    if (other is Saw && !gotHit) _gotHit();
    if (other is Checkpoint && game.level.checkpointActive && game.level.complete == false) _finishedLevel();
    super.onCollisionStart(intersectionPoints, other);
  }

  void _loadAllAnimations() {
    final idleAnimation = _spriteAnimation(PlayerState.idle, 11);
    final runningAnimation = _spriteAnimation(PlayerState.running, 12);
    final jumpingAnimation = _spriteAnimation(PlayerState.jumping, 1);
    final fallingAnimation = _spriteAnimation(PlayerState.falling, 1);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
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
      )..onComplete = () => startAnimationFinished = true,
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
  }

  void _playerJump(double dt) {
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
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
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
    if (health <= 0) return;

    gotHit = true;
    add(
      OpacityEffect.fadeOut(
        EffectController(alternate: true, duration: 0.1, repeatCount: 5),
      )..onComplete = () => gotHit = false,
    );
  }

  void _checkFall() {
    final fallen = position.y > game.size.y + size.y && !gotHit;

    if (!fallen) return;
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
    current = PlayerState.running;
    game.level.complete = true;
    add(
      MoveEffect.to(
        game.level.endPosition,
        EffectController(duration: 1),
      )..onComplete = () => game.loadNextLevel(),
    );
  }
}
