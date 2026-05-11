import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

// Supported currencies with their symbols
const Map<String, String> kCurrencySymbols = {
  'USD': '\$',
  'EUR': '€',
  'INR': '₹',
  'GBP': '£',
  'JPY': '¥',
  'AUD': 'A\$',
  'CAD': 'C\$',
};

class ThemeState {
  final bool isDarkMode;
  final Color primaryColor;
  final String fontFamily;
  final double textScaleFactor;
  final String currency; // e.g. 'USD', 'INR'

  ThemeState({
    required this.isDarkMode,
    required this.primaryColor,
    required this.fontFamily,
    required this.textScaleFactor,
    required this.currency,
  });

  String get currencySymbol => kCurrencySymbols[currency] ?? '\$';

  ThemeState copyWith({
    bool? isDarkMode,
    Color? primaryColor,
    String? fontFamily,
    double? textScaleFactor,
    String? currency,
  }) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      primaryColor: primaryColor ?? this.primaryColor,
      fontFamily: fontFamily ?? this.fontFamily,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      currency: currency ?? this.currency,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(ThemeState(
    isDarkMode: false,
    primaryColor: Colors.teal,
    fontFamily: 'Inter',
    textScaleFactor: 1.0,
    currency: 'USD',
  )) {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = ThemeState(
      isDarkMode: prefs.getBool('isDarkMode') ?? false,
      primaryColor: Color(prefs.getInt('primaryColor') ?? Colors.teal.value),
      fontFamily: prefs.getString('fontFamily') ?? 'Inter',
      textScaleFactor: prefs.getDouble('textScaleFactor') ?? 1.0,
      currency: prefs.getString('currency') ?? 'USD',
    );
  }

  Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    state = state.copyWith(isDarkMode: isDark);
  }

  Future<void> setPrimaryColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', color.value);
    state = state.copyWith(primaryColor: color);
  }

  Future<void> setFontFamily(String font) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontFamily', font);
    state = state.copyWith(fontFamily: font);
  }

  Future<void> setTextScaleFactor(double scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textScaleFactor', scale);
    state = state.copyWith(textScaleFactor: scale);
  }

  Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
    state = state.copyWith(currency: currency);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

extension ThemeStateExt on ThemeState {
  ThemeData toThemeData() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
    );
    final textTheme = GoogleFonts.getTextTheme(fontFamily);
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      textTheme: textTheme,
    );
  }
}
