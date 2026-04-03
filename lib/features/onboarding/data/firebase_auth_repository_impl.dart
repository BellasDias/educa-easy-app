// lib/features/onboarding/data/firebase_auth_repository_impl.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../domain/auth_repository.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  // 1. NOVO PACOTE (v7+): Exige o '.instance' (Singleton)
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

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
      // 2. NOVO PACOTE (v7+): O método correto agora é o authenticate()
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      
      if (googleUser == null) {
        print("Login cancelado ou bloqueado.");
        return false; 
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // 3. NOVO PACOTE (v7+): O Firebase SÓ precisa do idToken! 
      // O accessToken foi removido dessa classe na versão nova.
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final currentUser = _firebaseAuth.currentUser;
      
      // Vincula a conta do Google na conta invisível (anônima) atual
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