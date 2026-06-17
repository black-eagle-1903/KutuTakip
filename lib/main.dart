import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kututakip/core/constants/app_constants.dart';
import 'package:kututakip/core/theme/app_theme.dart';
import 'package:kututakip/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:kututakip/providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: KutuTakipApp(),
    ),
  );
}

class KutuTakipApp extends ConsumerWidget {
  const KutuTakipApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize database and load default destinations on first run
    ref.watch(appDatabaseProvider).initializeDefaultDestinations();

    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const DashboardScreen(),
    );
  }
}
