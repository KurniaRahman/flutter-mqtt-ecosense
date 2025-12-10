import 'package:audioplayers/audioplayers.dart';

class SoundService {
  // Buat instance player (static agar hemat memori)
  static final AudioPlayer _player = AudioPlayer();

  // Fungsi Play berdasarkan Status
  static Future<void> playForStatus(String status) async {
    // Stop suara sebelumnya jika ada (biar gak tumpang tindih)
    await _player.stop();

    String soundFile = 'sounds/happy.mp3'; // Default

    switch (status) {
      case 'THIRSTY':
        soundFile = 'sounds/thirsty.mp3';
        break;
      case 'HOT':
        soundFile = 'sounds/hot.mp3';
        break;
      case 'COLD':
        soundFile = 'sounds/cold.mp3';
        break;
      case 'DARK':
        soundFile = 'sounds/dark.mp3';
        break;
      case 'SICK':
        soundFile = 'sounds/sick.mp3';
        break;
      case 'DEAD':
        soundFile = 'sounds/lowbat.mp3';
        break;
      case 'HAPPY':
      default:
        soundFile = 'sounds/happy.mp3';
        break;
    }

    // Mainkan Suara
    // Pastikan volume 100%
    await _player.setVolume(1.0);
    // Source harus pakai AssetSource
    await _player.play(AssetSource(soundFile));
  }
}