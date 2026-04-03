// lib/features/onboarding_login/domain/auth_repository.dart

/// Contrato que define O QUE a funcionalidade de autenticação deve fazer,
/// mas não se importa com COMO (Firebase, API própria, etc) será feito.
abstract class AuthRepository {
  /// Salva o nome do usuário de forma anônima ou na conta.
  Future<void> saveUserName(String name);
  Future<bool> signInWithGoogle();
}