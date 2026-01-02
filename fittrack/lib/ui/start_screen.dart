import 'package:flutter/material.dart';
import '../data/models/user.dart';
import '../data/repositories/setting_repositories.dart';
import '../data/repositories/user_repositories.dart';
import 'pages/authentication/login_screen.dart';
import 'pages/home/home_screen.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getLoggedInUsername(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Login();
        }

        final username = snapshot.data!;
        final userRepository = UserRepository();
        return FutureBuilder<User?>(
          future: userRepository.getUserByUsername(username),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (userSnapshot.hasError || userSnapshot.data == null) {
              return const Login();
            }

            return HomeScreen(user: userSnapshot.data!);
          },
        );
      },
    );
  }

  Future<String?> _getLoggedInUsername() async {
    final settingsRepository = SettingsRepository();
    return await settingsRepository.getCurrentUsername();
  }
}
