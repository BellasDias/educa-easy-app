import 'package:educaeasy_app/features/levels_map/presentation/pages/levels_page.dart';
import 'package:educaeasy_app/features/onboarding/presentation/pages/age_input_page.dart';
import 'package:educaeasy_app/features/onboarding/presentation/pages/create_account_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import 'package:educaeasy_app/features/onboarding/presentation/pages/login_methods_page.dart';
import 'package:educaeasy_app/features/onboarding/presentation/pages/name_input_page.dart';
import 'package:educaeasy_app/features/onboarding/presentation/pages/welcome_page.dart';
import 'package:educaeasy_app/features/onboarding/presentation/pages/email_signup_page.dart';
import '../../features/home/home_page.dart';
import 'package:educaeasy_app/features/profile/presentation/pages/profile_page.dart';

import 'package:educaeasy_app/features/levels/presentation/pages/lesson_one_page.dart';
import 'package:educaeasy_app/features/levels/presentation/pages/lesson_two_page.dart';
import '../../features/levels/presentation/pages/lesson_three_page.dart';
import '../../features/levels/presentation/pages/lesson_four_page.dart';
import '../../features/levels/presentation/pages/lesson_five_page.dart';
import '../../features/levels/presentation/pages/lesson_six_page.dart';
import '../../features/levels/presentation/pages/lesson_seven_page.dart';

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
      if (state.matchedLocation == '/home' && isAuthenticated) {
        if (isAuthenticated) {
          // Tem conta conectada -> Vai para Níveis
          return '/levels';
        }
        final isProtectedPath = state.matchedLocation == '/levels';
        if (isProtectedPath && !isAuthenticated) {
          return '/welcome';
        }
      }
      // Retornar null significa: "Pode seguir a navegação normalmente"
      // Se não estiver logado e acessar '/home', ele vai cair aqui e a tela será renderizada.
      return null;
    },

    routes: [
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
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
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/age_input',
        builder: (context, state) => const AgeInputPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Tela de Login/Senha (Em construção)')),
        ),
      ),
      GoRoute(path: '/levels', builder: (context, state) => const LevelsPage()),
      GoRoute(
        path: '/email_signup',
        builder: (context, state) => const EmailSignupPage(),
      ),
      GoRoute(
        path: '/create_account',
        builder: (context, state) => const CreateAccountPage(),
      ),
      GoRoute(
        path: '/lesson-one',
        builder: (context, state) => const LessonOnePage(),
      ),
      GoRoute(
        path: '/lesson-two',
        builder: (context, state) => const LessonTwoPage(),
      ),
      GoRoute(
        path: '/lesson-three',
        builder: (context, state) => const LessonThreePage(),
      ),
      GoRoute(
        path: '/lesson-four',
        builder: (context, state) => const LessonFourPage(),
      ),
      GoRoute(
        path: '/lesson-five',
        builder: (context, state) => const LessonFivePage(),
      ),
      GoRoute(
        path: '/lesson-six',
        builder: (context, state) => const LessonSixPage(),
      ),
      GoRoute(
        path: '/lesson-seven',
        builder: (context, state) => const LessonSevenPage(),
      ),
    ],
  );
}
