import 'package:flutter/material.dart';
import 'singlepage_app.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SinglePageApp(),
      theme: ThemeData(primaryColor: Colors.amber, primarySwatch: Colors.orange),
      darkTheme: ThemeData.dark(),
    );
  }
}