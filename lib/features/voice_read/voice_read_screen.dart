import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/constants/app_colors.dart';

class VoiceReadScreen extends StatefulWidget {
  const VoiceReadScreen({super.key});

  @override
  State<VoiceReadScreen> createState() => _VoiceReadScreenState();
}

class _VoiceReadScreenState extends State<VoiceReadScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  String _selectedLanguage = 'en-US';

  final Map<String, String> _languages = {
    'en-US': 'English',
    'hi-IN': 'Hindi',
    'ta-IN': 'Tamil',
    'te-IN': 'Telugu',
    'bn-IN': 'Bengali',
    'mr-IN': 'Marathi',
  };

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage(_selectedLanguage);
    await _flutterTts.setSpeechRate(0.5);
    
    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });
  }

  Future<void> _speak(String message) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      await _flutterTts.speak(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Voice Read-Aloud'),
        backgroundColor: AppColors.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  _isSpeaking ? Icons.volume_up : Icons.record_voice_over,
                  size: 64,
                  color: _isSpeaking ? AppColors.success : AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  _isSpeaking ? 'Speaking...' : 'Test Voice',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Select Language',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ..._languages.entries.map((entry) => RadioListTile<String>(
            title: Text(entry.value),
            value: entry.key,
            groupValue: _selectedLanguage,
            onChanged: (value) async {
              if (value != null) {
                setState(() => _selectedLanguage = value);
                await _flutterTts.setLanguage(value);
              }
            },
          )),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _speak('Emergency alert sent. Help is on the way.'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              minimumSize: const Size(double.infinity, 56),
            ),
            child: Text(_isSpeaking ? 'Stop' : 'Test Speak'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
