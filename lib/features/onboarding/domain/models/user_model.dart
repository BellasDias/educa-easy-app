// lib/features/onboarding/domain/models/user_model.dart

class UserModel {
  final String id;
  final String name;
  final int age;
  final String email;

  // NOVOS CAMPOS DA LOJINHA E ECONOMIA
  final int coins;
  final String? selectedAvatar;
  final List<String> unlockedAvatars;

  UserModel({
    required this.id,
    required this.name,
    required this.age,
    this.email = '',
    this.coins = 0, // Começa com 0 moedas
    this.selectedAvatar,
    this.unlockedAvatars = const ['Prof. Coruja'], // Coruja é grátis!
  });

  factory UserModel.fromMap(
    Map<String, dynamic> map, {
    required String documentId,
  }) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
      coins: map['coins'] ?? 0,
      selectedAvatar: map['selectedAvatar'],
      // O List.from garante que o Flutter entenda o formato de lista do Firebase
      unlockedAvatars: List<String>.from(
        map['unlockedAvatars'] ?? ['Prof. Coruja'],
      ),
    );
  }

  // Converte para Map para enviar ao Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'email': email,
      'coins': coins,
      'selectedAvatar': selectedAvatar,
      'unlockedAvatars': unlockedAvatars,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
