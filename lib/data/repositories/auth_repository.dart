import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/supabase_service.dart';
import '../models/app_user.dart';
import '../models/enums/user_role.dart';

/// Repositorio encargado de las operaciones relacionadas
/// con autenticación y usuarios.
class AuthRepository {
  const AuthRepository();

  /// Inicia sesión con correo electrónico y contraseña.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return SupabaseService.client.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  /// Cierra la sesión del usuario actual.
  Future<void> signOut() async {
    await SupabaseService.client.auth.signOut();
  }

  /// Devuelve el usuario autenticado actualmente.
  ///
  /// Retorna null si no existe una sesión activa.
  User? getCurrentUser() {
    return SupabaseService.client.auth.currentUser;
  }

  /// Obtiene el perfil del usuario autenticado.
  ///
  /// Retorna null si no existe una sesión activa
  /// o si el perfil no existe.
  Future<AppUser?> getCurrentUserProfile() async {
    final user = getCurrentUser();

    if (user == null) {
      return null;
    }

    final data = await SupabaseService.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return AppUser.fromMap(data);
  }

  /// Devuelve el rol del usuario autenticado.
  ///
  /// Retorna null si no existe una sesión o un perfil.
  Future<UserRole?> getCurrentUserRole() async {
    final profile = await getCurrentUserProfile();

    return profile?.role;
  }

  /// Indica si el usuario autenticado es SuperAdmin.
  Future<bool> isSuperAdmin() async {
    final role = await getCurrentUserRole();

    return role == UserRole.superAdmin;
  }

  /// Crea un nuevo profesor mediante la Edge Function
  /// `create-user`.
  ///
  /// Esta operación solo puede ser realizada por un
  /// usuario autenticado con rol `superAdmin`.
  Future<Map<String, dynamic>> createAdministrator({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await SupabaseService.client.functions.invoke(
      'create-user',
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw const AuthException(
        'La respuesta del servidor no tiene un formato válido.',
      );
    }

    if (data['success'] != true) {
      throw AuthException(
        data['message']?.toString() ??
            'No fue posible crear el profesor.',
      );
    }

    return data;
  }
}