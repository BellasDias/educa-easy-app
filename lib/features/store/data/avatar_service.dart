import 'package:flutter/material.dart';
// 1. CORREÇÃO DO IMPORT: O caminho correto é este abaixo
import 'package:shared_preferences/shared_preferences.dart'; 

class AvatarService {
  static final AvatarService _instance = AvatarService._internal();
  factory AvatarService() => _instance;
  AvatarService._internal();

  static const String _storageKey = 'selected_avatar_svg';

  final ValueNotifier<String?> selectedAvatarNotifier = ValueNotifier<String?>(null);

  // Inicializa o serviço carregando o avatar salvo anteriormente
  Future<void> init() async {
    // 2. CORREÇÃO DA INSTÂNCIA: Chamamos o getInstance() aqui dentro de forma assíncrona
    final prefs = await SharedPreferences.getInstance();
    selectedAvatarNotifier.value = prefs.getString(_storageKey);
  }

  // Define o novo avatar e persiste o dado
  Future<void> selectAvatar(String svgData) async {
    selectedAvatarNotifier.value = svgData;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, svgData);
  }
}