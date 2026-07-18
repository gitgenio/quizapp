import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

/// Servicio encargado de la autenticación mediante Supabase Auth.
class AuthService {
  const AuthService._();

  /// Usuario autenticado actualmente.
  static User? get currentUser =>
      SupabaseService.client.auth.currentUser;

  /// Stream que notifica cambios en la sesión.
  static Stream<AuthState> get authStateChanges =>
      SupabaseService.client.auth.onAuthStateChange;

  /// Inicia sesión.
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return SupabaseService.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Cierra la sesión actual.
  static Future<void> signOut() {
    return SupabaseService.client.auth.signOut();
  }

  /// Crea un usuario en Supabase Auth.
  ///
  /// El perfil en la tabla `profiles` se creará en un segundo paso.
  static Future<AuthResponse> createAdministrator({
    required String email,
    required String password,
  }) {
    return SupabaseService.client.auth.signUp(
      email: email,
      password: password,
    );
  }
}