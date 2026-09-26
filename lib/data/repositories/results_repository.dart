import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/player/models/quiz_result.dart';
import '../models/quiz.dart';

/// Repositorio para consultar resultados de Quizzes.
class ResultsRepository {
  final SupabaseClient _supabase;

  ResultsRepository({
    SupabaseClient? supabase,
  }) : _supabase = supabase ?? Supabase.instance.client;

  /// Obtiene los resultados consolidados de un Quiz específico.
  Future<List<QuizResult>> getQuizResults(String quizId) async {
    try {
      print('🔍 [ResultsRepository] Ejecutando RPC get_quiz_results para: $quizId');

      final response = await _supabase.rpc(
        'get_quiz_results',
        params: {'p_quiz_id': quizId},
      );

      print('📦 [ResultsRepository] Respuesta RPC: $response');
      print('📦 [ResultsRepository] Tipo: ${response.runtimeType}');

      if (response == null) {
        print('⚠️ [ResultsRepository] Respuesta es null');
        return [];
      }

      final List<dynamic> data = response as List<dynamic>;
      print('📊 [ResultsRepository] Cantidad de registros: ${data.length}');

      return data.map((item) {
        print('📝 [ResultsRepository] Item: $item');
        return QuizResult.fromMap(Map<String, dynamic>.from(item));
      }).toList();
    } catch (e) {
      print('❌ [ResultsRepository] Error: $e');
      rethrow;
    }
  }

  /// NUEVO: Obtiene el resultado consolidado de UN participante específico.
  /// Reutiliza getQuizResults y filtra por participantId.
  Future<QuizResult?> getParticipantResult({
    required String participantId,
    required String quizId,
  }) async {
    try {
      final results = await getQuizResults(quizId);
      for (final r in results) {
        if (r.participantId == participantId) return r;
      }
      return null;
    } catch (e) {
      print('Error al obtener resultado del participante: $e');
      return null;
    }
  }

  /// Obtiene información básica del Quiz.
  Future<Quiz?> getQuizById(String quizId) async {
    try {
      final response = await _supabase.rpc(
        'get_quiz_by_id',
        params: {'p_quiz_id': quizId},
      );

      if (response == null) return null;

      final rows = response as List;
      if (rows.isEmpty) return null;

      return Quiz.fromMap(Map<String, dynamic>.from(rows.first));
    } catch (e) {
      print('Error al obtener quiz: $e');
      rethrow;
    }
  }

  /// Obtiene el detalle de respuestas de un participante específico.
  Future<Map<String, dynamic>> getParticipantDetail({
    required String participantId,
    required String quizId,
  }) async {
    try {
      final response = await _supabase
          .from('answers')
          .select('''
            id,
            question_id,
            selected_option,
            created_at,
            questions:question_id (
              id,
              statement,
              option_a,
              option_b,
              option_c,
              option_d,
              correct_answer
            )
          ''')
          .eq('participant_id', participantId)
          .order('created_at', ascending: true);

      final participant = await _supabase
          .from('participants')
          .select('display_name')
          .eq('id', participantId)
          .single();

      return {
        'display_name': participant['display_name'],
        'answers': response,
      };
    } catch (e) {
      print('Error al obtener detalle del participante: $e');
      rethrow;
    }
  }
}