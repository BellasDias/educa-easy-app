class UserModel {
  final String id;
  final String name;
  final int age;
  final String email;

  factory UserModel.fromMap(
    Map<String, dynamic> map, {
    required String documentId,
  }) {
    return UserModel(
      id: documentId, // ou o nome que você deu à variável de ID
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
    );
  }
  UserModel({
    required this.id,
    required this.name,
    required this.age,
    this.email = '',
  });

  // Converte para Map para enviar ao Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'email': email,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
