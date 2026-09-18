import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/splash/splash_screen.dart';

/// Global navigator key so non-widget code (e.g. the API client) can drive
/// navigation — used to force the user to login when their session expires.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: TaskFlowApp(),
    ),
  );
}

class TaskFlowApp extends ConsumerStatefulWidget {
  const TaskFlowApp({super.key});

  @override
  ConsumerState<TaskFlowApp> createState() => _TaskFlowAppState();
}

class _TaskFlowAppState extends ConsumerState<TaskFlowApp> {
  @override
  void initState() {
    super.initState();
    // When the backend reports an expired/invalid token on a protected route,
    // clear the session and route the user back to login exactly once.
    ApiClient.onSessionExpired = () async {
      await ref.read(authProvider.notifier).sessionExpired();
      final nav = rootNavigatorKey.currentState;
      if (nav != null) {
        nav.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen(sessionExpired: true)),
          (route) => false,
        );
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      navigatorKey: rootNavigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
