import 'package:flutter/material.dart';
import 'data/datasources/local_storage.dart';
import 'ui/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localStorage = LocalStorageService();
  await localStorage.initialize();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(onStartPressed: () {}),
    ),
  );
}
