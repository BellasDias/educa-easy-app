import 'package:flutter/material.dart';
import 'package:educaeasy_app/features/home/home_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EducaEasy',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}