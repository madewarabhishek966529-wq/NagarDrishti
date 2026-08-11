import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'src/core/router/app_router.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try initializing Firebase with standard error catch for local/offline dev
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initial setup note: $e (App running with mock auth fallback)');
  }

  runApp(
    const ProviderScope(
      child: VikasitNagpurApp(),
    ),
  );
}

class VikasitNagpurApp extends ConsumerWidget {
  const VikasitNagpurApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to sleek Nagpur dark slate
      routerConfig: router,
    );
  }
}
