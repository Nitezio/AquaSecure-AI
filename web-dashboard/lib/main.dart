import 'package:flutter/material.dart';

void main() {
  runApp(const AquaSecureDashboardApp());
}

class AquaSecureDashboardApp extends StatelessWidget {
  const AquaSecureDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('AquaSecure Dashboard Workspace')),
      ),
    );
  }
}
