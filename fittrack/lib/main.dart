import 'package:fittrack/data/repositories/setting_repositories.dart';
import 'package:flutter/material.dart';
import 'ui/start_screen.dart';
import 'ui/pages/authentication/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ WEB COMPATIBLE: Use async methods
  final settingsRepository = SettingsRepository();
  final isLoggedIn = await settingsRepository.isLoggedIn();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const Home() : const Login(),
    ),
  );
}