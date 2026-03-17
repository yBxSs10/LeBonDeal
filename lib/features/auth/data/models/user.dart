class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.savedDeals = const [],
    this.preferences = const [],
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final List<String> savedDeals;
  final List<String> preferences;
}
