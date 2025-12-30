import 'package:flutter/material.dart';
import '../../../data/datasources/local_storage.dart';
import '../authentication/login_screen.dart';

class Home extends StatelessWidget {
  Home({super.key, required Null Function() onStartPressed});

  final _boxLogin = LocalStorageService().openBox("login");

  void _logout(BuildContext context) {
    _boxLogin.clear();
    _boxLogin.put("loginStatus", false);
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
