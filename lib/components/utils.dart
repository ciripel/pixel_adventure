import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/player.dart';

bool checkCollision(Player player, CollisionBlock block) {
  final hitbox = player.hitbox;
  final playerX = player.position.x + hitbox.offsetX;
  final playerY = player.position.y + hitbox.offsetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final fixedX = player.scale.x < 0
      ? playerX - (hitbox.offsetX * 2) - playerWidth + player.size.x / 2
      : playerX - player.size.x / 2;
  final fixedY = block.isPlatform ? playerY + playerHeight : playerY;

  return (fixedY < block.y + block.height &&
      playerY + playerHeight > block.y &&
      fixedX < block.x + block.width &&
      fixedX + playerWidth > block.x);
}

String format(Duration d) => d.toString().substring(2, 11);
