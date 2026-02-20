import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FakeBatteryOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const FakeBatteryOverlay({super.key, required this.onClose});

  @override
  State<FakeBatteryOverlay> createState() => _FakeBatteryOverlayState();
}

class _FakeBatteryOverlayState extends State<FakeBatteryOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _batteryLevel = 15;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _controller.forward();
    
    _animateBattery();
  }

  void _animateBattery() async {
    for (int i = 15; i >= 0; i--) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() => _batteryLevel = i);
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onLongPress: widget.onClose,
        child: Container(
          color: Colors.black,
          child: Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Opacity(
                  opacity: _animation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.battery_full,
                        size: 64,
                        color: Colors.white54,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '$_batteryLevel%',
                        style: const TextStyle(
                          fontSize: 48,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Shutting down...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 48),
                      const Text(
                        'Triple press power to exit',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
