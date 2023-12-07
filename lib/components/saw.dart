import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/level.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Saw extends SpriteAnimationComponent with HasGameReference<PixelAdventure> {
  final bool isVertical;
  final double offNeg;
  final double offPos;
  final double speedMultiplier;
  Saw({
    super.position,
    super.size,
    super.priority = -3,
    this.isVertical = false,
    this.offNeg = 0,
    this.offPos = 0,
    this.speedMultiplier = 1,
  });

  final _sawSpeed = 0.04;
  double _moveSpeed = 75;
  final double _minSpeed = 0;
  final double _maxSpeed = 300;
  double _speedDirection = 1;
  double moveDirection = 1;
  double rangeNeg = 0;
  double rangePos = 0;
  final _velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    if (isVertical) {
      rangeNeg = position.y - offNeg * Level.tileSize;
      rangePos = position.y + offPos * Level.tileSize;
    } else {
      rangeNeg = position.x - offNeg * Level.tileSize;
      rangePos = position.x + offPos * Level.tileSize;
    }

    animation = _spriteAnimation(8);
    add(CircleHitbox());
    return super.onLoad();
  }

  SpriteAnimation _spriteAnimation(int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Saw/On (38x38).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: _sawSpeed,
        textureSize: Vector2.all(38),
      ),
    );
  }

  @override
  void update(double dt) {
    _updateSpeed();
    _moveVertically(dt);
    _moveHorizontally(dt);

    super.update(dt);
  }

  void _updateSpeed() {
    _moveSpeed += _speedDirection * speedMultiplier;
    if (_moveSpeed <= _minSpeed) _speedDirection = 1;
    if (_moveSpeed >= _maxSpeed) _speedDirection = -1;
  }

  void _moveVertically(double dt) {
    if (isVertical) {
      _velocity.y = moveDirection * _moveSpeed;
      position.y += _velocity.y * dt;
      if (position.y <= rangeNeg) moveDirection = 1;
      if (position.y >= rangePos) moveDirection = -1;
    }
  }

  void _moveHorizontally(double dt) {
    if (!isVertical) {
      _velocity.x = moveDirection * _moveSpeed;
      position.x += _velocity.x * dt;
      if (position.x <= rangeNeg) moveDirection = 1;
      if (position.x >= rangePos) moveDirection = -1;
    }
  }
}
