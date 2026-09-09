import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/enums/answer_option.dart';

class AnswerRepository {
  final SupabaseClient _supabaseClient;

  AnswerRepository({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  Future<void> saveAnswer({
    required String participantId,
    required String questionId,
    required AnswerOption selectedOption,
  }) async {
    try {
      await _supabaseClient.from('answers').insert({
        'participant_id': participantId,
        'question_id': questionId,
        'selected_option': selectedOption.name,
      });
    } catch (e) {
      throw Exception('Error al guardar la respuesta: $e');
    }
  }
}