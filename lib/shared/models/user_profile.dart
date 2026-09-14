/// Dados principais da pessoa cadastrada no aplicativo.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String displayName;
  final int age;
  final double heightCm;
  final double weightKg;
  final DateTime createdAt;

  /// Converte a resposta da API local em um perfil tipado.
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'].toString(),
    email: json['email'].toString(),
    displayName: json['display_name'].toString(),
    age: (json['age'] as num).toInt(),
    heightCm: (json['height_cm'] as num).toDouble(),
    weightKg: (json['weight_kg'] as num).toDouble(),
    createdAt: DateTime.parse(json['created_at'].toString()),
  );
}
