import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educaeasy_app/features/onboarding/domain/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/auth_repository.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  // Instância do Cloud Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Voltamos ao código original da Isa/Bella: O GoogleSignIn agora é um singleton!
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  FirebaseAuthRepositoryImpl(this._firebaseAuth);

  @override
  Future<void> saveUserName(String name) async {
    try {
      UserCredential credential = await _firebaseAuth.signInAnonymously();
      await credential.user?.updateDisplayName(name);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);

      print("Nome salvo no SharedPreferences com sucesso: $name");
    } catch (e) {
      throw Exception('Erro ao salvar o nome: $e');
    }
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
      await _googleSignIn.initialize(
        serverClientId:
            '657815140282-ka3f6oip7vpi6idftqaqnl0ksmfo697s.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();

      if (googleUser == null) {
        print("Login cancelado pelo usuário.");
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

  // NOVA FUNÇÃO: Serve para ENTRAR em uma conta que já existe
  @override
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await syncProfileToCloud();
    } catch (e) {
      throw Exception('Erro ao fazer login com e-mail: $e');
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

      final name =
          prefs.getString('user_name') ?? user.displayName ?? 'Jogador';
      final age = prefs.getInt('user_age') ?? 0;

      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'age': age,
        'email': user.email ?? '',
        'isAnonymous': user.isAnonymous,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("Perfil de $name sincronizado com o Firestore (UID: ${user.uid})");
    } catch (e) {
      throw Exception('Erro ao sincronizar com a nuvem: $e');
    }
  }

  @override
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      final docSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        // CORREÇÃO: Adicionado o 'documentId' que a sua colega definiu no modelo!
        return UserModel.fromMap(
          docSnapshot.data()!,
          documentId: docSnapshot.id,
        );
      }
      return null;
    } catch (e) {
      print('Erro ao carregar os dados do perfil: $e');
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Erro ao sair da conta: $e');
    }
  }
}
