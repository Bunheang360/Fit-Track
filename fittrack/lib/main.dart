import 'package:flutter/material.dart';
import 'ui/start_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FitTrackApp());
}

/// Main App Widget
class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitTrack',
      home: StartScreen(),
    );
  }
}
