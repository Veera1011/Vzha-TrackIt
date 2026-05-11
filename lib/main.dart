import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_provider.dart';

// Supabase Configuration
const supabaseUrl = 'https://kklywrqdlziofikdzegy.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtrbHl3cnFkbHppb2Zpa2R6ZWd5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg0Mzc1MDgsImV4cCI6MjA5NDAxMzUwOH0.HJ8xWko2Tv0Cdimuorvriu9MBwX5bTn1Y_0iEae5MdM';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const ProviderScope(child: FinanceApp()));
}

class FinanceApp extends ConsumerWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Vzha TrackIt',
      theme: themeState.toThemeData(),
      themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(themeState.textScaleFactor),
          ),
          child: child!,
        );
      },
    );
  }
}
