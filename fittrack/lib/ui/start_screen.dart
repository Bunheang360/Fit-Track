import 'package:flutter/material.dart';
import '../data/repositories/setting_repositories.dart';
import 'pages/authentication/login_screen.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  void _logout(BuildContext context) {
    final settingsRepository = SettingsRepository();
    settingsRepository.setLoggedOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => _logout(context),
        child: Center(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: const Image(
              image: AssetImage('assets/images/logo.png'),
              width: 200,
              height: 200,
            ),
          ),
        ),
      ),
    );
  }
}
