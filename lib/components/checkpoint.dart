import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/helpers/custom_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum CheckpointState {
  idle('Flag Idle'),
  none('No Flag'),
  out('Flag Out');

  final String filename;
  const CheckpointState(this.filename);
}

class Checkpoint extends SpriteAnimationGroupComponent<CheckpointState> with HasGameReference<PixelAdventure> {
  Checkpoint({
    super.position,
    super.size,
    super.priority = -5,
  });

  final _stepTime = 0.05;

  final hitbox = const CustomHitbox.rectangle(offsetX: 20, offsetY: 60, width: 8, height: 4);

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;

    animations = {
      CheckpointState.idle: _spriteAnimation(CheckpointState.idle, 10),
      CheckpointState.none: _spriteAnimation(CheckpointState.none, 1)..loop = false,
      CheckpointState.out: _spriteAnimation(CheckpointState.out, 26)..loop = false,
    };
    current = CheckpointState.none;

    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.passive,
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) async {
    if (game.level.fruits.isEmpty && game.level.checkpointActive == false) {
      current = CheckpointState.out;
      game.level.checkpointActive = true;

      await animationTicker?.completed;
      current = CheckpointState.idle;
    }
    super.update(dt);
  }

  SpriteAnimation _spriteAnimation(CheckpointState state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Checkpoints/Checkpoint/Checkpoint (${state.filename}) (64x64).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: amount == 1 ? 1 : _stepTime,
        textureSize: Vector2.all(64),
      ),
    );
  }
}
