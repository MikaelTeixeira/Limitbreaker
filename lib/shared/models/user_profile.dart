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
}
