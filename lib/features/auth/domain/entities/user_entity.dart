import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id, email, displayName, photoUrl];

  // Méthode pour créer une copie avec des valeurs mises à jour
  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  // Convertir l'entité en Map pour la persistance
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  // Créer une entité à partir d'un Map
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }
}
