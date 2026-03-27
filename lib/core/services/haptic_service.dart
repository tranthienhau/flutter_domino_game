import 'package:vibration/vibration.dart';

class HapticService {
  static Future<void> tilePlaced() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      Vibration.vibrate(duration: 50, amplitude: 128);
    }
  }

  static Future<void> passTurn() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      Vibration.vibrate(duration: 30, amplitude: 64);
    }
  }

  static Future<void> win() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      Vibration.vibrate(
        pattern: [0, 100, 50, 100, 50, 200],
        intensities: [0, 255, 0, 255, 0, 255],
      );
    }
  }

  static Future<void> invalidMove() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      Vibration.vibrate(duration: 20, amplitude: 32);
    }
  }

  static Future<void> yourTurn() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      Vibration.vibrate(duration: 80, amplitude: 200);
    }
  }
}
