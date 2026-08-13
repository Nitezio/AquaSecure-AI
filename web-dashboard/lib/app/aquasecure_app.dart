import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';

class AquaSecureApp extends StatelessWidget {
  const AquaSecureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AquaSecure AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const DashboardScreen(),
    );
  }
}
