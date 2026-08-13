import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'src/core/router/app_router.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('🔥 Firebase successfully initialized with project: nagardrishti-facec');
  } catch (e) {
    debugPrint('Firebase initialization note: $e (App running with mock auth fallback)');
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
