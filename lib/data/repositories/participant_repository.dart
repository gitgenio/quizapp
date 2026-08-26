import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/participant.dart';

class ParticipantRepository {
  final SupabaseClient _supabase;

  ParticipantRepository({
    SupabaseClient? supabase,
  }) : _supabase = supabase ?? Supabase.instance.client;

  /// Busca un participante por su token y opcionalmente por el id del quiz.
  Future<Participant?> getByToken({
    required String participantToken,
    String? quizId,
  }) async {
    var query = _supabase
        .from('participants')
        .select()
        .eq('participant_token', participantToken);

    // Si se proporciona el quizId, aplicamos el filtro adicional
    if (quizId != null && quizId.isNotEmpty) {
      query = query.eq('quiz_id', quizId);
    }

    final response = await query.maybeSingle();

    if (response == null) {
      return null;
    }

    return Participant.fromMap(
      Map<String, dynamic>.from(response),
    );
  }

  /// Crea un nuevo participante.
  Future<Participant> create({
    required String participantToken,
    required String quizId,
    required String displayName,
    required String email,
  }) async {
    final response = await _supabase.rpc(
      'join_quiz',
      params: {
        'p_participant_token': participantToken,
        'p_quiz_id': quizId,
        'p_display_name': displayName,
        'p_email': email,
      },
    );

    if (response == null) {
      throw Exception(
        'No fue posible registrar la participación.',
      );
    }

    final rows = response as List;

    if (rows.isEmpty) {
      throw Exception(
        'No fue posible registrar la participación.',
      );
    }

    return Participant.fromMap(
      Map<String, dynamic>.from(rows.first),
    );
  }


  /// Devuelve el participante existente o lo crea si aún no existe.
  Future<Participant> getOrCreate({
    required String participantToken,
    required String quizId,
    required String displayName,
    required String email,
  }) async {
    return create(
      participantToken: participantToken,
      quizId: quizId,
      displayName: displayName,
      email: email,
    );
  }

  /// Actualiza el estado del participante.
  Future<void> updateStatus({
    required String participantId,
    required String status,
  }) async {
    await _supabase
        .from('participants')
        .update({
      'status': status,
    })
        .eq('id', participantId);
  }

  Future<Participant?> getById(String participantId) async {
    final response = await _supabase
        .from('participants')
        .select()
        .eq('id', participantId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Participant.fromMap(
      Map<String, dynamic>.from(response),
    );
  }
}