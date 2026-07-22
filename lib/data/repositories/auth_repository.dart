import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/supabase_service.dart';

/// Repositorio encargado de las operaciones relacionadas
/// con autenticación y administración de usuarios.
class AuthRepository {
  const AuthRepository();

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