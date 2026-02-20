import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/guardian_service.dart';

class GuardianModeScreen extends StatefulWidget {
  const GuardianModeScreen({super.key});

  @override
  State<GuardianModeScreen> createState() => _GuardianModeScreenState();
}

class _GuardianModeScreenState extends State<GuardianModeScreen> {
  final GuardianService _guardianService = GuardianService();
  bool _isScanning = false;
  bool _isConnected = false;
  bool _isBluetoothOn = true;
  String _statusText = 'Tap to scan for nearby devices';
  List<BluetoothDevice> _devices = [];

  @override
  void initState() {
    super.initState();
    _initGuardian();
  }

  Future<void> _initGuardian() async {
    _guardianService.onDevicesFound = (devices) {
      if (mounted) {
        setState(() => _devices = devices);
      }
    };

    _guardianService.onConnected = () {
      if (mounted) {
        setState(() {
          _isConnected = true;
          _isScanning = false;
          _statusText = 'Connected to trusted device';
        });
      }
    };

    _guardianService.onDisconnected = () {
      if (mounted) {
        setState(() {
          _isConnected = false;
          _statusText = 'Tap to scan for nearby devices';
        });
      }
    };

    _guardianService.onError = (error) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _statusText = error;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    };

    final isOn = await _guardianService.isBluetoothOn();
    setState(() => _isBluetoothOn = isOn);

    await _guardianService.checkSavedConnection();
    if (_guardianService.isConnected) {
      setState(() {
        _isConnected = true;
        _statusText = 'Connected to trusted device';
      });
    }
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _statusText = 'Scanning for nearby devices...';
      _devices = [];
    });

    await _guardianService.startScan();

    if (mounted) {
      setState(() {
        _isScanning = false;
        if (_devices.isEmpty) {
          _statusText = 'No devices found. Try again.';
        } else {
          _statusText = '${_devices.length} device(s) found';
        }
      });
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() => _statusText = 'Connecting...');

    final success = await _guardianService.connectToDevice(device);
    if (!success && mounted) {
      setState(() => _statusText = 'Connection failed');
    }
  }

  Future<void> _disconnect() async {
    await _guardianService.disconnect();
    setState(() {
      _isConnected = false;
      _statusText = 'Tap to scan for nearby devices';
    });
  }

  Future<void> _enableBluetooth() async {
    try {
      await FlutterBluePlus.turnOn();
      final isOn = await _guardianService.isBluetoothOn();
      setState(() => _isBluetoothOn = isOn);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable Bluetooth in settings')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Guardian Mode'),
        backgroundColor: AppColors.primary,
      ),
      body: !_isBluetoothOn
          ? _buildBluetoothOff()
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isConnected
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.secondary,
                      border: Border.all(
                        color: _isConnected ? AppColors.success : AppColors.divider,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_searching,
                      size: 64,
                      color: _isConnected ? AppColors.success : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _statusText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isConnected
                        ? 'Your trusted device is monitoring your safety'
                        : 'Connect with a trusted device nearby to share your safety status',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_devices.isNotEmpty && !_isConnected) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Available Devices',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _devices.length,
                        itemBuilder: (context, index) {
                          final device = _devices[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.divider),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.bluetooth, color: AppColors.accent),
                              title: Text(device.platformName.isNotEmpty
                                  ? device.platformName
                                  : 'Unknown Device'),
                              subtitle: Text(device.remoteId.str),
                              trailing: _isScanning
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : TextButton(
                                      onPressed: () => _connectToDevice(device),
                                      child: const Text('Connect'),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (!_isConnected)
                    ElevatedButton(
                      onPressed: _isScanning ? null : _startScan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: Text(_isScanning ? 'Scanning...' : 'Scan for Devices'),
                    )
                  else
                    ElevatedButton(
                      onPressed: _disconnect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: const Text('Disconnect'),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildBluetoothOff() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.bluetooth_disabled,
                size: 64,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bluetooth is Off',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enable Bluetooth to connect with your guardian device',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _enableBluetooth,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text('Enable Bluetooth'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _guardianService.dispose();
    super.dispose();
  }
}
