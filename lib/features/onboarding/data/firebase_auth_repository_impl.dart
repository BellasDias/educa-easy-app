// lib/features/onboarding/data/firebase_auth_repository_impl.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/auth_repository.dart';
import '../domain/models/user_model.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  // Singleton do Google SignIn
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Instância do Cloud Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseAuthRepositoryImpl(this._firebaseAuth);

  @override
  Future<void> saveUserName(String name) async {
    try {
      UserCredential credential = await _firebaseAuth.signInAnonymously();
      await credential.user?.updateDisplayName(name);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);

      print("Nome salvo com sucesso: ${credential.user?.displayName}");
    } catch (e) {
      throw Exception('Erro ao salvar o nome: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      // Busca o documento do usuário no Firestore pelo UID
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, documentId: user.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar dados do perfil: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> saveUserAge(int age) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_age', age);
      print("Idade salva localmente: $age");
    } catch (e) {
      throw Exception('Erro ao salvar a idade: $e');
    }
  }

  @override
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();

      if (googleUser == null) {
        print("Login cancelado ou bloqueado.");
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final currentUser = _firebaseAuth.currentUser;

      if (currentUser != null && currentUser.isAnonymous) {
        await currentUser.linkWithCredential(credential);
      } else {
        await _firebaseAuth.signInWithCredential(credential);
      }

      await syncProfileToCloud();

      return true;
    } catch (e) {
      print('Erro no Google Sign-In: $e');
      return false;
    }
  }

  @override
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await syncProfileToCloud();
    } catch (e) {
      throw Exception('Erro ao criar conta com e-mail: $e');
    }
  }

  @override
  Future<void> syncProfileToCloud() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return;

      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name') ?? user.displayName ?? '';
      final age = prefs.getInt('user_age') ?? 0;

      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'age': age,
        'email': user.email ?? '',
        'isAnonymous': user.isAnonymous,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("Perfil sincronizado com a nuvem para o UID: ${user.uid}");
    } catch (e) {
      throw Exception('Erro ao sincronizar com a nuvem: $e');
    }
  }
}
