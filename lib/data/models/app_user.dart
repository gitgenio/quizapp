import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'enums/user_role.dart';

/// Representa un usuario de la aplicación.
class AppUser extends Equatable {
  /// Identificador único del usuario.
  final String id;

  /// Nombre que se mostrará en la aplicación.
  final String name;

  /// Correo electrónico del usuario.
  final String email;

  /// Rol del usuario.
  final UserRole role;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  /// Crea una copia del objeto reemplazando únicamente
  /// las propiedades indicadas.
  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }

  /// Convierte el objeto en un Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
    };
  }

  /// Crea un AppUser a partir de un Map.
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: UserRole.values.firstWhere(
            (value) => value.name == map['role'],
      ),
    );
  }

  /// Convierte el objeto en formato JSON.
  String toJson() => json.encode(toMap());

  /// Crea un AppUser a partir de un JSON.
  factory AppUser.fromJson(String source) =>
      AppUser.fromMap(json.decode(source));

  @override
  List<Object> get props => [
    id,
    name,
    email,
    role,
  ];
}