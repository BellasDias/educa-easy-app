// lib/features/onboarding_login/domain/auth_repository.dart
import 'models/user_model.dart';

/// Contrato que define O QUE a funcionalidade de autenticação deve fazer,
/// mas não se importa com COMO (Firebase, API própria, etc) será feito.
abstract class AuthRepository {
  Future<void> saveUserName(String name);
  Future<void> saveUserAge(int age);
  Future<bool> signInWithGoogle();
  Future<void> signUpWithEmail(String email, String password);
  Future<void> signInWithEmail(String email, String password);
  Future<void> syncProfileToCloud();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel?> getCurrentUserData();
  Future<void> addCoins(int amount);
  Future<void> signOut();
}
