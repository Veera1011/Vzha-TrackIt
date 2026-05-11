import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/tenant/presentation/screens/tenant_selection_screen.dart';
import '../../features/tenant/presentation/screens/tenant_create_screen.dart';
import '../../features/transactions/presentation/screens/add_transaction_screen.dart';
import '../../features/master_data/presentation/screens/master_data_screen.dart';
import '../../features/investments/presentation/screens/sip_calculator_screen.dart';
import '../../features/investments/presentation/screens/emi_calculator_screen.dart';
import '../../features/low_code/presentation/screens/low_code_forms_screen.dart';
import '../../features/low_code/presentation/screens/dynamic_form_render_screen.dart';
import '../../features/low_code/data/models/form_definition_model.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/low_code/presentation/screens/module_builder_screen.dart';
import '../../features/auth/presentation/screens/biometric_lock_screen.dart';
import '../../features/transactions/presentation/screens/export_screen.dart';
import '../../features/common/presentation/screens/file_preview_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggingIn = state.matchedLocation == '/login';

      if (session == null && !isLoggingIn && state.matchedLocation != '/') {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/tenant-selection',
        builder: (context, state) => const TenantSelectionScreen(),
      ),
      GoRoute(
        path: '/tenant-create',
        builder: (context, state) => const TenantCreateScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/add-transaction',
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/sip-calculator',
        builder: (context, state) => const SIPCalculatorScreen(),
      ),
      GoRoute(
        path: '/emi-calculator',
        builder: (context, state) => const EMICalculatorScreen(),
      ),
      GoRoute(
        path: '/low-code-forms',
        builder: (context, state) => const LowCodeFormsScreen(),
      ),
      GoRoute(
        path: '/dynamic-form/:id',
        builder: (context, state) {
          final formDef = state.extra as FormDefinitionModel;
          return DynamicFormRenderScreen(formDef: formDef);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/module-builder',
        builder: (context, state) => const ModuleBuilderScreen(),
      ),
      GoRoute(
        path: '/biometric-lock',
        builder: (context, state) => const BiometricLockScreen(),
      ),
      GoRoute(
        path: '/export',
        builder: (context, state) => const ExportScreen(),
      ),
      GoRoute(
        path: '/preview',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>;
          return FilePreviewScreen(
            filePath: extra['path']!,
            fileName: extra['name']!,
          );
        },
      ),
    ],
  );
});
