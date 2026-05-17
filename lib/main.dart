import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:educaeasy_app/design_system/theme/app_theme.dart';
import 'package:educaeasy_app/core/routing/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:educaeasy_app/features/store/data/avatar_service.dart';

void main() async {
  // Inicializar serviços como o Firebase antes do app rodar
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AvatarService().init();

  // Aqui está a nossa "caixa mestre" do Riverpod envolvendo o app
  runApp(const ProviderScope(child: MyApp()));
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
