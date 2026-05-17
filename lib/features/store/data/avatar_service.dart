import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarService {
  static final AvatarService _instance = AvatarService._internal();
  factory AvatarService() => _instance;
  AvatarService._internal();

  static const String _avatarKey = 'selected_avatar_svg';
  static const String _coinsKey = 'user_coins_balance';
  static const String _ownedAvatarsKey = 'owned_avatars_list';

  // Notificadores reativos para a UI escutar de forma independente
  final ValueNotifier<String?> selectedAvatarNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(420); // Valor inicial padrão
  final ValueNotifier<List<String>> ownedAvatarsNotifier = ValueNotifier<List<String>>([]);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Carrega o avatar equipado
    selectedAvatarNotifier.value = prefs.getString(_avatarKey);
    
    // Carrega o saldo de moedas (se for a primeira vez, define como 420)
    if (!prefs.containsKey(_coinsKey)) {
      await prefs.setInt(_coinsKey, 420);
    }
    coinsNotifier.value = prefs.getInt(_coinsKey) ?? 420;

    // Carrega os avatares comprados (sempre garante que o 'Prof. Coruja' venha liberado)
    List<String>? owned = prefs.getStringList(_ownedAvatarsKey);
    if (owned == null) {
      owned = ['Prof. Coruja'];
      await prefs.setStringList(_ownedAvatarsKey, owned);
    }
    ownedAvatarsNotifier.value = owned;
  }

  // Altera o avatar atual
  Future<void> selectAvatar(String svgData) async {
    selectedAvatarNotifier.value = svgData;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarKey, svgData);
  }

  // Realiza a compra se houver saldo
  Future<bool> purchaseAvatar(String avatarName, int price) async {
    if (coinsNotifier.value >= price && !ownedAvatarsNotifier.value.contains(avatarName)) {
      final prefs = await SharedPreferences.getInstance();
      
      // Deduz moedas
      final int newBalance = coinsNotifier.value - price;
      await prefs.setInt(_coinsKey, newBalance);
      coinsNotifier.value = newBalance;

      // Adiciona à lista de adquiridos
      final List<String> updatedList = List.from(ownedAvatarsNotifier.value)..add(avatarName);
      await prefs.setStringList(_ownedAvatarsKey, updatedList);
      ownedAvatarsNotifier.value = updatedList;

      return true; // Compra bem sucedida
    }
    return false; // Saldo insuficiente ou já possui
  }
}