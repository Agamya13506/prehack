import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _ringtonePlayer = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> playRingtone() async {
    if (_isPlaying) return;
    
    try {
      await _ringtonePlayer.setReleaseMode(ReleaseMode.loop);
      await _ringtonePlayer.play(AssetSource('audio/ringtone.mp3'));
      _isPlaying = true;
    } catch (e) {
      print('Error playing ringtone: $e');
    }
  }

  Future<void> stopRingtone() async {
    if (!_isPlaying) return;
    
    try {
      await _ringtonePlayer.stop();
      _isPlaying = false;
    } catch (e) {
      print('Error stopping ringtone: $e');
    }
  }

  void dispose() {
    _ringtonePlayer.dispose();
  }
}
