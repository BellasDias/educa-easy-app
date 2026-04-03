import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import 'package:educaeasy_app/features/onboarding/presentation/pages/login_methods_page.dart';
import 'package:educaeasy_app/features/onboarding/presentation/pages/name_input_page.dart';
import 'package:educaeasy_app/features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/home/home_page.dart';

class AppRouter {
  static final router = GoRouter(
    // Sempre tentará iniciar na home
    initialLocation: '/home', 
    
    // Decide o fluxo antes da tela abrir
    redirect: (context, state) {
      // Pega o usuário atual do Firebase (pode ser Google, Email ou Anônimo)
      final user = FirebaseAuth.instance.currentUser;
      final isAuthenticated = user != null;

      // Se o app está tentando abrir a /home inicial...
      if (state.matchedLocation == '/home') {
        if (isAuthenticated) {
          // Tem conta conectada -> Vai para Níveis
          return '/levels'; 
        } else {
          // Não tem conta -> Vai para o fluxo inicial de Welcome
          return '/welcome'; 
        }
      }
      
      // Retornar null significa: "Pode seguir a navegação normalmente"
      return null; 
    },

    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/name_input',
        builder: (context, state) => const NameInputPage(),
      ),
      GoRoute(
        path: '/login_methods',
        builder: (context, state) => const LoginMethodsPage(),
      ),

      // ==========================================
      // ROTAS FUTURAS (PLACEHOLDERS)
      // ==========================================
      
      GoRoute(
        path: '/age_input',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Tela de Idade (Em construção)')),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Tela de Login/Senha (Em construção)')),
        ),
      ),
      GoRoute(
        path: '/levels',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Níveis')),
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                // Botão provisório só para podermos deslogar e testar o fluxo de "sem conta"
                await FirebaseAuth.instance.signOut();
                if (context.mounted) context.go('/home');
              },
              child: const Text('Deslogar (Teste)'),
            ),
          ),
        ),
      ),
    ],
  );
}