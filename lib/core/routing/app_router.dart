import 'package:educaeasy_app/features/onboarding/presentation/pages/login_methods_page.dart';
import 'package:educaeasy_app/features/onboarding/presentation/pages/name_input_page.dart';
import 'package:educaeasy_app/features/onboarding/presentation/pages/welcome_page.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/welcome', // Começa no Onboarding
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/name_input',
        builder: (context, state) => const NameInputPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/login_methods',
        builder: (context, state) => const LoginMethodsPage(),
      ),
    ],
  );
}