import 'package:fittrack/data/repositories/setting_repositories.dart';
import 'package:fittrack/data/datasources/database_helper.dart';
import 'package:fittrack/ui/pages/authentication/login_screen.dart';
import 'package:fittrack/ui/pages/home/home_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite database
  final db = DatabaseHelper();
  await db.database; // This triggers database creation and seeding
  print('✅ Database initialized');

  // Check login status
  final settingsRepository = SettingsRepository();
  final isLoggedIn = await settingsRepository.isLoggedIn();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const HomeScreen() : const Login(),
    ),
  );
}
