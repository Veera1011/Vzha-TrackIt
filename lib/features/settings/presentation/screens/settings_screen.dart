import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/security/biometric_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _biometric = BiometricService();
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometric();
  }

  Future<void> _loadBiometric() async {
    final available = await _biometric.isAvailable();
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('biometricEnabled') ?? false;
    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _biometricEnabled = enabled;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final success = await _biometric.authenticate();
      if (!success) return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometricEnabled', value);
    setState(() => _biometricEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ── APPEARANCE ──────────────────────────────────────────────
          _SectionHeader('Appearance'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            value: themeState.isDarkMode,
            onChanged: (val) => themeNotifier.setDarkMode(val),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Theme Color', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: {
                    'Teal': Colors.teal,
                    'Blue': Colors.blue,
                    'Purple': Colors.purple,
                    'Orange': Colors.orange,
                    'Red': Colors.red,
                    'Green': Colors.green,
                  }.entries.map((e) {
                    final selected = themeState.primaryColor.value == e.value.value;
                    return GestureDetector(
                      onTap: () => themeNotifier.setPrimaryColor(e.value),
                      child: Tooltip(
                        message: e.key,
                        child: CircleAvatar(
                          backgroundColor: e.value,
                          radius: 20,
                          child: selected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Font Family', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: themeState.fontFamily,
                  isExpanded: true,
                  items: ['Inter', 'Roboto', 'Outfit', 'Lato', 'Oswald']
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (v) { if (v != null) themeNotifier.setFontFamily(v); },
                ),
                const SizedBox(height: 8),
                const Text('Text Size', style: TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: themeState.textScaleFactor,
                  min: 0.8, max: 1.5, divisions: 7,
                  label: '${(themeState.textScaleFactor * 100).toInt()}%',
                  onChanged: (v) => themeNotifier.setTextScaleFactor(v),
                ),
              ],
            ),
          ),

          // ── CURRENCY ─────────────────────────────────────────────────
          _SectionHeader('Currency'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: themeState.currency,
              isExpanded: true,
              items: kCurrencySymbols.entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text('${e.key}  (${e.value})'),
                      ))
                  .toList(),
              onChanged: (v) { if (v != null) themeNotifier.setCurrency(v); },
            ),
          ),

          // ── SECURITY ─────────────────────────────────────────────────
          _SectionHeader('Security'),
          if (_biometricAvailable)
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: const Text('Biometric Lock'),
              subtitle: const Text('Require fingerprint/face to open app'),
              value: _biometricEnabled,
              onChanged: _toggleBiometric,
            )
          else
            const ListTile(
              leading: Icon(Icons.fingerprint, color: Colors.grey),
              title: Text('Biometric Lock'),
              subtitle: Text('Not available on this device'),
            ),

          // ── DATA ─────────────────────────────────────────────────────
          _SectionHeader('Data'),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Export Transactions'),
            subtitle: const Text('Download PDF or CSV report'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/export'),
          ),

          // ── ACCOUNT ──────────────────────────────────────────────────
          _SectionHeader('Account'),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
