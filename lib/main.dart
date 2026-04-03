import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:educaeasy_app/design_system/theme/app_theme.dart';
import 'package:educaeasy_app/core/routing/app_router.dart';

void main() async {
  // Inicializar serviços como o Firebase antes do app rodar
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EducaEasy',
      debugShowCheckedModeBanner: false,
      
      // Integração com o Design System
      theme: AppTheme.light, 
      
      // Conexão com o GoRouter
      routerConfig: AppRouter.router, 
    );
  }
}