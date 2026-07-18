import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'enums/user_role.dart';

/// Representa la información adicional de un usuario.
///
/// El correo electrónico se obtiene desde Supabase Auth
/// mediante:
///
/// SupabaseService.client.auth.currentUser?.email
class AppUser extends Equatable {
  /// Identificador del usuario.
  final String id;

  /// Nombre que se mostrará en la aplicación.
  final String name;

  /// Rol del usuario.
  final UserRole role;

  const AppUser({
    required this.id,
    required this.name,
    required this.role,
  });

  AppUser copyWith({
    String? id,
    String? name,
    UserRole? role,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role.name,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      name: map['name'] as String,
      role: UserRole.values.firstWhere(
            (value) => value.name == map['role'],
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory AppUser.fromJson(String source) =>
      AppUser.fromMap(json.decode(source));

  @override
  List<Object> get props => [
    id,
    name,
    role,
  ];
}