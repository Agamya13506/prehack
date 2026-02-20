import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_colors.dart';
import 'core/services/shake_service.dart';
import 'core/services/power_button_service.dart';
import 'features/calculator_disguise/calculator_screen.dart';
import 'features/home/home_screen.dart';
import 'features/sos/sos_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MedusaApp());
}

class MedusaApp extends StatefulWidget {
  const MedusaApp({super.key});

  @override
  State<MedusaApp> createState() => _MedusaAppState();
}

class _MedusaAppState extends State<MedusaApp> {
  bool _isUnlocked = false;
  late ShakeService _shakeService;
  late PowerButtonService _powerButtonService;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    _shakeService = ShakeService();
    _shakeService.init().then((_) {
      _shakeService.onShakeDetected = _triggerSos;
      _shakeService.startListening();
    });

    _powerButtonService = PowerButtonService();
    _powerButtonService.onTriplePressDetected = _triggerSos;
    final isEnabled = await _powerButtonService.isEnabled();
    if (isEnabled) {
      _powerButtonService.startListening();
    }
  }

  @override
  void dispose() {
    _shakeService.dispose();
    _powerButtonService.dispose();
    super.dispose();
  }

  void _triggerSos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SosScreen()),
    );
  }

  void _onUnlocked() {
    setState(() => _isUnlocked = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medusa',
      debugShowCheckedModeBanner: false,
      theme: AppColors.lightTheme,
      home: _isUnlocked
          ? const HomeScreen()
          : CalculatorDisguiseScreen(onUnlocked: _onUnlocked),
    );
  }
}
