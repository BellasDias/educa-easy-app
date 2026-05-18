import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AvatarService {
  static final AvatarService _instance = AvatarService._internal();
  factory AvatarService() => _instance;
  AvatarService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Notificadores reativos para a UI escutar (Começando zerados/vazios)
  final ValueNotifier<String?> selectedAvatarNotifier = ValueNotifier<String?>(
    null,
  );
  final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(0);
  final ValueNotifier<List<String>> ownedAvatarsNotifier =
      ValueNotifier<List<String>>(['Prof. Coruja']);

  // Puxa os dados reais da NUVEM (Firebase)
  Future<void> init() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      selectedAvatarNotifier.value = data['selectedAvatar'] as String?;
      coinsNotifier.value = data['coins'] ?? 0;

      // Converte a lista do banco para o formato do Flutter
      if (data['unlockedAvatars'] != null) {
        ownedAvatarsNotifier.value = List<String>.from(data['unlockedAvatars']);
      }
    }
  }

  // Altera o avatar atual e SALVA NO FIREBASE
  Future<void> selectAvatar(String svgData) async {
    final user = _auth.currentUser;
    if (user == null) return;

    selectedAvatarNotifier.value = svgData;

    // 💡 CORRIGIDO: Trocado .update por .set com merge: true
    await _firestore.collection('users').doc(user.uid).set({
      'selectedAvatar': svgData,
    }, SetOptions(merge: true));
  }

  // Realiza a compra e DESCONTA NO FIREBASE
  Future<bool> purchaseAvatar(String avatarName, int price) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    if (coinsNotifier.value >= price &&
        !ownedAvatarsNotifier.value.contains(avatarName)) {
      final int newBalance = coinsNotifier.value - price;
      final List<String> updatedList = List.from(ownedAvatarsNotifier.value)
        ..add(avatarName);

      // Atualiza a tela imediatamente para não travar o visual
      coinsNotifier.value = newBalance;
      ownedAvatarsNotifier.value = updatedList;

      // 💡 CORRIGIDO: Trocado .update por .set com merge: true
      // Salva a compra definitiva no banco de dados com segurança máxima
      await _firestore.collection('users').doc(user.uid).set({
        'coins': newBalance,
        'unlockedAvatars': updatedList,
      }, SetOptions(merge: true));

      return true; // Compra bem sucedida
    }
    return false; // Saldo insuficiente ou já possui
  }
}
