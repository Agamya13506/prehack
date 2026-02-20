import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';

class CalculatorDisguiseScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  
  const CalculatorDisguiseScreen({super.key, required this.onUnlocked});

  @override
  State<CalculatorDisguiseScreen> createState() => _CalculatorDisguiseScreenState();
}

class _CalculatorDisguiseScreenState extends State<CalculatorDisguiseScreen> {
  String _display = '';
  String _inputSequence = '';
  static const String _unlockCode = '2580=';
  static const String _pinKey = 'unlock_pin';
  static const String _wrongAttemptsKey = 'wrong_attempts';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initializePin();
  }

  Future<void> _initializePin() async {
    final storedPin = await _secureStorage.read(key: _pinKey);
    if (storedPin == null) {
      await _secureStorage.write(key: _pinKey, value: _unlockCode);
    }
  }

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _display = '';
        _inputSequence = '';
      } else if (value == '=') {
        _inputSequence += value;
        _checkUnlock();
      } else {
        _display += value;
        _inputSequence += value;
      }
    });
  }

  Future<void> _checkUnlock() async {
    final storedPin = await _secureStorage.read(key: _pinKey);
    
    if (_inputSequence == storedPin) {
      widget.onUnlocked();
    } else {
      await _incrementWrongAttempts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wrong PIN'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
    _inputSequence = '';
    _display = '';
  }

  Future<void> _incrementWrongAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = prefs.getInt(_wrongAttemptsKey) ?? 0;
    await prefs.setInt(_wrongAttemptsKey, attempts + 1);
    
    if (attempts >= 2) {
      await _wipeData();
    }
  }

  Future<void> _wipeData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _secureStorage.deleteAll();
    await _initializePin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(24),
                child: Text(
                  _display.isEmpty ? '0' : _display,
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildButtonRow(['C', '(', ')', '/']),
                    _buildButtonRow(['7', '8', '9', '×']),
                    _buildButtonRow(['4', '5', '6', '-']),
                    _buildButtonRow(['1', '2', '3', '+']),
                    _buildButtonRow(['%', '0', '.', '=']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonRow(List<String> buttons) {
    return Expanded(
      child: Row(
        children: buttons.map((btn) => Expanded(child: _buildButton(btn))).toList(),
      ),
    );
  }

  Widget _buildButton(String value) {
    final isOperator = ['+', '-', '×', '/', '='].contains(value);
    final isFunction = ['C', '(', ')', '%'].contains(value);
    
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onButtonPressed(value),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOperator 
                  ? AppColors.accent 
                  : isFunction 
                      ? AppColors.secondary 
                      : AppColors.primary,
              border: Border.all(
                color: AppColors.divider,
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: isOperator || isFunction 
                    ? AppColors.textPrimary 
                    : AppColors.accent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
