import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/views/splash_view.dart';
import 'features/courses/providers/course_provider.dart';
import 'features/store/providers/cart_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, CourseProvider>(
          create: (_) => CourseProvider(),
          update: (_, auth, course) => CourseProvider(
            apiClient: auth.token != null ? null : null, // Uses default Client with secure token storage
          ),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sagar Student App',
      theme: AppTheme.darkTheme,
      home: const SplashView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
