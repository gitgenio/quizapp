import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/player/models/quiz_result.dart';
import '../models/quiz.dart';
import '../models/participant.dart';

/// Repositorio para consultar resultados de Quizzes.
class ResultsRepository {
  final SupabaseClient _supabase;

  ResultsRepository({
    SupabaseClient? supabase,
  }) : _supabase = supabase ?? Supabase.instance.client;

  /// Obtiene los resultados consolidados de un Quiz específico.
  ///
  /// Utiliza la función RPC 'get_quiz_results' que calcula:
  /// - Respuestas correctas
  /// - Respuestas incorrectas
  /// - Puntaje porcentual
  Future<List<QuizResult>> getQuizResults(String quizId) async {
    try {
      final response = await _supabase.rpc(
        'get_quiz_results',
        params: {'p_quiz_id': quizId},
      );

      if (response == null) {
        return [];
      }

      final List<dynamic> data = response as List<dynamic>;

      return data.map((item) {
        return QuizResult.fromMap(Map<String, dynamic>.from(item));
      }).toList();
    } catch (e) {
      print('Error al obtener resultados: $e');
      rethrow;
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
      // Obtenemos las respuestas del participante con la información de las preguntas
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

      // Obtenemos el nombre del participante
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