// lib/features/onboarding_login/data/firebase_auth_repository_impl.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../domain/auth_repository.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  // 1. MUDANÇA (V7+): O GoogleSignIn agora exige o uso do .instance
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Injeção de dependência: recebemos a instância do Firebase de fora
  FirebaseAuthRepositoryImpl(this._firebaseAuth);

  @override
  Future<void> saveUserName(String name) async {
    try {
      UserCredential credential = await _firebaseAuth.signInAnonymously();
      await credential.user?.updateDisplayName(name);
      print("Nome salvo com sucesso: ${credential.user?.displayName}");
    } catch (e) {
      throw Exception('Erro ao salvar o nome: $e');
    }
  }
  
  @override
  Future<bool> signInWithGoogle() async {
    try {
      // 2. MUDANÇA (V7+): É obrigatório inicializar o pacote antes de chamar a janela
      await _googleSignIn.initialize();

      // 3. MUDANÇA (V7+): O método mudou de signIn() para authenticate()
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      
      if (googleUser == null) {
        print("Login cancelado ou bloqueado.");
        return false; 
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Enviamos apenas o idToken, que é o suficiente para o Firebase na nova versão
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final currentUser = _firebaseAuth.currentUser;
      
      // Promove a conta anônima para uma conta Google
      if (currentUser != null && currentUser.isAnonymous) {
        await currentUser.linkWithCredential(credential);
      } else {
        await _firebaseAuth.signInWithCredential(credential);
      }
      
      return true; 
      
    } catch (e) {
      print('Erro no Google Sign-In: $e');
      return false; 
    }
  }
}