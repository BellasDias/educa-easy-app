import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapProgressNotifier extends StateNotifier<int> {
  // Começa no Nível 1 por padrão, mas já manda buscar na nuvem!
  MapProgressNotifier() : super(1) {
    _loadProgressFromCloud();
  }

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // 1. Busca o nível salvo no Firebase quando o app abre
  Future<void> _loadProgressFromCloud() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        // Se a criança já tiver passado de fase antes, atualiza para o nível salvo
        state = data['currentLevel'] ?? 1;
      }
    } catch (e) {
      print("Erro ao carregar o progresso do mapa: $e");
    }
  }

  // 2. Atualiza a tela E salva no Firebase ao mesmo tempo
  Future<void> updateProgress(int newLevel) async {
    // Garante que a criança não vai voltar de fase
    if (newLevel <= state) return;

    state = newLevel; // Atualiza o mapa visualmente na hora!

    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Salva na nuvem com merge para não apagar as moedas e avatares
        await _firestore.collection('users').doc(user.uid).set({
          'currentLevel': newLevel,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print("Erro ao salvar o progresso: $e");
    }
  }
}

// O Provider atualizado que o resto do app vai usar
final mapProgressProvider = StateNotifierProvider<MapProgressNotifier, int>((
  ref,
) {
  return MapProgressNotifier();
});
