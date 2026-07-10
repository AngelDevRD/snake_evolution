import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around audioplayers. No audio asset files are bundled with
/// this portfolio build (see README); every play call is wrapped so a
/// missing asset just logs via debugPrint and never crashes the app.
class AudioService {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  Future<void> playSfx(String assetName) async {
    try {
      await _sfxPlayer.play(AssetSource('audio/$assetName'));
    } catch (e) {
      debugPrint('AudioService: no se pudo reproducir $assetName ($e)');
    }
  }

  Future<void> playMusic(String assetName) async {
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(AssetSource('audio/$assetName'));
    } catch (e) {
      debugPrint('AudioService: no se pudo reproducir música $assetName ($e)');
    }
  }

  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (e) {
      debugPrint('AudioService: error al detener música ($e)');
    }
  }

  Future<void> dispose() async {
    await _sfxPlayer.dispose();
    await _musicPlayer.dispose();
  }
}
