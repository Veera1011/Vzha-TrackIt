import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/security/biometric_service.dart';

class BiometricLockScreen extends StatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> {
  final _service = BiometricService();
  bool _isAuthenticating = false;
  String _message = 'Your session is locked.';

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _message = 'Waiting for biometric...';
    });

    final available = await _service.isAvailable();
    if (!available) {
      if (mounted) context.go('/tenant-selection');
      return;
    }

    final success = await _service.authenticate();
    if (mounted) {
      if (success) {
        context.go('/tenant-selection');
      } else {
        setState(() {
          _isAuthenticating = false;
          _message = 'Authentication failed. Try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/App_log.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 32),
            const Icon(Icons.lock, size: 64),
            const SizedBox(height: 16),
            Text(_message, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            if (!_isAuthenticating)
              ElevatedButton.icon(
                onPressed: _authenticate,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Retry Authentication'),
              ),
            if (_isAuthenticating) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
