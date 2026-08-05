import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/participant.dart';

class ParticipantRepository {
  final SupabaseClient _supabase;

  ParticipantRepository({
    SupabaseClient? supabase,
  }) : _supabase = supabase ?? Supabase.instance.client;

  /// Busca un participante por su token y quiz.
  Future<Participant?> getByToken({
    required String participantToken,
    required String quizId,
  }) async {
    final response = await _supabase
        .from('participants')
        .select()
        .eq('participant_token', participantToken)
        .eq('quiz_id', quizId)
        .maybeSingle();

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
    final response = await _supabase
        .from('participants')
        .insert({
      'participant_token': participantToken,
      'quiz_id': quizId,
      'display_name': displayName,
      'email': email,
      'status': 'waiting',
    })
        .select()
        .single();

    return Participant.fromMap(
      Map<String, dynamic>.from(response),
    );
  }

  /// Devuelve el participante existente o lo crea si aún no existe.
  Future<Participant> getOrCreate({
    required String participantToken,
    required String quizId,
    required String displayName,
    required String email,
  }) async {
    final existing = await getByToken(
      participantToken: participantToken,
      quizId: quizId,
    );

    if (existing != null) {
      return existing;
    }

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
}