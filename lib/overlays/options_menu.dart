import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class OptionsMenu extends StatefulWidget {
  // Reference to parent game.
  final PixelAdventure game;
  const OptionsMenu({super.key, required this.game});

  @override
  State<OptionsMenu> createState() => _OptionsMenuState();
}

class _OptionsMenuState extends State<OptionsMenu> {
  @override
  Widget build(BuildContext context) {
    const blackTextColor = Color.fromRGBO(0, 0, 0, 0.6);
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 0.9);
    final session = widget.game.wcSession;
    late String firstAccount;
    if (session.namespaces['eip155'] == null) firstAccount = 'not available on EIP155';
    firstAccount = session.namespaces['eip155']!.accounts[0];
    final address = firstAccount.split(':')[2];
    final shownAddress = '${address.substring(0, 7)}..${address.substring(address.length - 5, address.length)}';

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: 350,
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
                'Options',
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                shownAddress,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: whiteTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Music:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: whiteTextColor,
                      fontSize: 14,
                    ),
                  ),
                  Checkbox(
                    value: widget.game.playMusic,
                    onChanged: (_) {
                      setState(() => widget.game.playMusic = !widget.game.playMusic);

                      if (!widget.game.playMusic) {
                        widget.game.musicPlayer.pause();
                        return;
                      }
                      widget.game.musicPlayer.resume();
                    },
                  ),
                  SizedBox(
                    width: 165,
                    child: Slider(
                      value: widget.game.musicVolume,
                      onChanged: (volume) {
                        setState(() => widget.game.musicVolume = volume);
                        if (!widget.game.playMusic && volume >= 0) {
                          widget.game.playMusic = true;
                          widget.game.musicPlayer.resume();
                        }

                        if (volume == 0) {
                          widget.game.playMusic = false;
                        }

                        widget.game.musicPlayer.setVolume(volume);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'SFX:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: whiteTextColor,
                      fontSize: 16,
                    ),
                  ),
                  Checkbox(
                    value: widget.game.playSoundEffects,
                    onChanged: (_) {
                      setState(() => widget.game.playSoundEffects = !widget.game.playSoundEffects);
                    },
                  ),
                  SizedBox(
                    width: 165,
                    child: Slider(
                      value: widget.game.soundEffectsVolume,
                      onChanged: (volume) {
                        setState(() => widget.game.soundEffectsVolume = volume);
                        if (!widget.game.playSoundEffects && volume >= 0) widget.game.playSoundEffects = true;

                        if (volume == 0) widget.game.playSoundEffects = false;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              if (widget.game.isMobile)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Joystick:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: whiteTextColor,
                        fontSize: 16,
                      ),
                    ),
                    Checkbox(
                      value: widget.game.useJoystick,
                      onChanged: (_) {
                        setState(() => widget.game.useJoystick = !widget.game.useJoystick);
                        if (widget.game.useJoystick) {
                          widget.game.camera.viewport.removeAll([widget.game.leftButton, widget.game.rightButton]);
                          widget.game.camera.viewport.add(widget.game.joystick);
                          return;
                        }
                        widget.game.camera.viewport.remove(widget.game.joystick);
                        widget.game.camera.viewport.addAll([widget.game.leftButton, widget.game.rightButton]);
                      },
                    ),
                    const SizedBox(width: 165),
                  ],
                ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 75,
                child: ElevatedButton(
                  onPressed: () {
                    widget.game.overlays.remove('OptionsMenu');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteTextColor,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 28.0,
                      color: blackTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
