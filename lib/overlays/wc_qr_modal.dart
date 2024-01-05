import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:qr_flutter_wc/qr_flutter_wc.dart';

class WcQrModal extends StatelessWidget {
  final PixelAdventure game;
  const WcQrModal({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            height: 400,
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    border: Border.all(
                      color: Colors.white,
                      width: 5.0,
                    ),
                  ),
                  child: QrImageView(
                    data: '${game.wcUri}',
                    // size: MediaQuery.of(context).size.width - 60.0,
                    errorCorrectionLevel: QrErrorCorrectLevel.Q,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.circle,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.circle,
                      color: Colors.black,
                    ),
                    embeddedImage: const AssetImage('assets/images/WalletConnect/logo_wc.png'),
                    embeddedImageStyle: const QrEmbeddedImageStyle(
                      size: Size(60.0, 60.0),
                    ),
                    embeddedImageEmitsError: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
