import 'package:supabase_flutter/supabase_flutter.dart';

/// Punto único de acceso al cliente de Supabase.
///
/// Toda la aplicación debe utilizar este servicio para
/// interactuar con la base de datos.
class SupabaseService {
  const SupabaseService._();

  /// Cliente único de Supabase.
  static SupabaseClient get client => Supabase.instance.client;
}