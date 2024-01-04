import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum Songs {
  song1('snatch-octo_sounds.aac'),
  song2('funk-upbeat-sigma_music_art.aac'),
  song3('starlight-qube_sounds.aac'),
  song4('sugar-rush-octo_sounds.aac'),
  song5('cheese-crackers-octo_sounds.aac'),
  song6('getaway-octo_sounds.aac');

  final String filename;
  const Songs(this.filename);
}

class MainMenu extends StatelessWidget {
  // Reference to parent game.
  final PixelAdventure game;
  final String version;

  const MainMenu({super.key, required this.game, required this.version});

  @override
  Widget build(BuildContext context) {
    const blackTextColor = Color.fromRGBO(0, 0, 0, 0.6);
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 0.9);
    final isMobile = defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.android;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: 310,
          width: 300,
          decoration: const BoxDecoration(
            color: blackTextColor,
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Pixel Adventure',
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 75,
                child: ElevatedButton(
                  onPressed: () async {
                    if (game.playMusic) {
                      var index = 0;
                      game.musicPlayer = AudioPlayer()
                        ..play(
                          AssetSource('audio/music/${Songs.values[index].filename}'),
                          volume: game.musicVolume,
                        );
                      index++;

                      game.musicPlayer.onPlayerComplete.listen((_) {
                        game.musicPlayer.play(
                          AssetSource('audio/music/${Songs.values[index].filename}'),
                          volume: game.musicVolume,
                        );
                        index++;
                        if (index == Songs.values.length) index = 0;
                      });
                    }
                    game.overlays.remove('MainMenu');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteTextColor,
                  ),
                  child: const Text(
                    'Play',
                    style: TextStyle(
                      fontSize: 40.0,
                      color: blackTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isMobile
                    ? 'Collect as many fruits as you can and avoid enemies!'
                    : '''Use A,D or Arrow Keys for movement.
Space bar to jump.
Collect as many fruits as you can and avoid enemies!''',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: whiteTextColor,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: isMobile ? 60 : 20),
              Text(
                'version: $version',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
