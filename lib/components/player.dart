import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/services.dart';
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

  final String fileName;
  const Character([this.fileName = 'Ninja Frog']);
}

enum PlayerState {
  idle(),
  running('Run'),
  jumping('Jump'),
  falling('Fall');

  final String fileName;
  const PlayerState([this.fileName = 'Idle']);
}

class Player extends SpriteAnimationGroupComponent<PlayerState>
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  Character character;

  Player({
    super.position,
    this.character = Character.ninjaFrog,
  });

  final _stepTime = 0.05;

  final _gravity = 9.8;
  final _jumpForce = 260.0;
  final _terminalVelocity = 300.0;
  double horizontalMovement = 0;
  final _moveSpeed = 100.0;
  Vector2 velocity = Vector2.zero();
  Vector2 startingPosition = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  int health = 3;
  int fruitsCollected = 0;
  List<CollisionBlock> collisionBlocks = [];
  final CustomHitbox hitbox = CustomHitbox.rectangle(offsetX: 10, offsetY: 4, width: 14, height: 28);

  @override
  FutureOr<void> onLoad() {
    startingPosition = Vector2(position.x, position.y);
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
    _updatePlayerState();
    _updatePlayerMovement(dt);
    _checkHorizontalCollisions();
    _applyGravity(dt);
    _checkVerticalCollisions();
    _checkFall();

    if (health <= 0) removeFromParent();
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
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Fruit) other.collidedWithPlayer();
    if (other is Saw && !gotHit) _gotHit();

    super.onCollision(intersectionPoints, other);
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

    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(PlayerState state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/${character.fileName}/${state.fileName} (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: _stepTime,
        textureSize: Vector2.all(32),
      ),
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
      )..onComplete = () {
          gotHit = false;
        },
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
          startingPosition,
          EffectController(duration: 0),
        ),
        OpacityEffect.fadeOut(
          EffectController(alternate: true, duration: 0.1, repeatCount: 5),
        ),
      ])
        ..onComplete = () {
          gotHit = false;
        },
    );
  }
}
