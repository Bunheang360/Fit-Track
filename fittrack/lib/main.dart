import 'package:flutter/material.dart';
import 'services/local_storage.dart';
import 'ui/screens/start_screen.dart';
 
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

