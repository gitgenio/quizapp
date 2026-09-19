import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/enums/quiz_status.dart';
import '../models/quiz.dart';

class QuizRepository {
  final SupabaseClient _supabase;

  QuizRepository({
    SupabaseClient? supabase,
  }) : _supabase =
      supabase ?? Supabase.instance.client;

  Future<List<Quiz>> getQuizzes() async {
    final response = await _supabase
        .from('quizzes')
        .select()
        .order(
      'created_at',
      ascending: false,
    );

    return (response as List)
        .map(
          (item) => Quiz.fromMap(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }

  Future<Quiz?> getQuizById(String quizId) async {
    final response = await _supabase.rpc(
      'get_quiz_by_id',
      params: {'p_quiz_id': quizId},
    );

    if (response == null) return null;

    final rows = response as List;
    if (rows.isEmpty) return null;

    return Quiz.fromMap(Map<String, dynamic>.from(rows.first));
  }

  Future<Quiz> createQuiz({
    required String title,
    required int questionCount,
    required int timePerQuestionSeconds,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'No hay un usuario autenticado.',
      );
    }

    final accessCode = _generateAccessCode();

    final data = {
      'title': title,
      'created_by': user.id,
      'status': 'draft',
      'access_code': accessCode,
      'question_count': questionCount,
      'time_per_question_seconds':
      timePerQuestionSeconds,
    };

    final response = await _supabase
        .from('quizzes')
        .insert(data)
        .select()
        .single();

    return Quiz.fromMap(
      Map<String, dynamic>.from(response),
    );
  }

  /// CORREGIDO: elimina primero las filas hijas (por foreign keys)
  /// y al final el quiz. Orden: answers -> quiz_selected_questions
  /// -> questions -> participants -> quizzes.
  Future<void> deleteQuiz(String id) async {
    // 1. IDs de participantes del quiz
    final participantsResponse = await _supabase
        .from('participants')
        .select('id')
        .eq('quiz_id', id);

    final participantIds = (participantsResponse as List)
        .map((e) => Map<String, dynamic>.from(e)['id'] as String)
        .toList();

    // 2. Respuestas de esos participantes
    if (participantIds.isNotEmpty) {
      await _supabase
          .from('answers')
          .delete()
          .inFilter('participant_id', participantIds);
    }

    // 3. Preguntas seleccionadas del quiz
    await _supabase
        .from('quiz_selected_questions')
        .delete()
        .eq('quiz_id', id);

    // 4. Preguntas del quiz
    await _supabase
        .from('questions')
        .delete()
        .eq('quiz_id', id);

    // 5. Participantes del quiz
    await _supabase
        .from('participants')
        .delete()
        .eq('quiz_id', id);

    // 6. Finalmente el quiz
    await _supabase
        .from('quizzes')
        .delete()
        .eq('id', id);
  }

  Future<Quiz?> getQuizByAccessCode(
      String accessCode,
      ) async {
    final code = accessCode.trim().toUpperCase();

    if (code.isEmpty) {
      return null;
    }

    final response = await _supabase.rpc(
      'get_quiz_by_access_code',
      params: {
        'p_access_code': code,
      },
    );

    print('========== RPC QUIZ ==========');
    print(response);
    print('==============================');

    if (response == null) {
      return null;
    }

    final rows = response as List;

    if (rows.isEmpty) {
      return null;
    }

    final quizMap =
    Map<String, dynamic>.from(rows.first);

    print('STATUS RECIBIDO POR FLUTTER: ${quizMap['status']}');

    return Quiz.fromMap(quizMap);
  }

  String _generateAccessCode() {
    const characters =
        'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

    final random = Random();

    return List.generate(
      6,
          (_) => characters[
      random.nextInt(
        characters.length,
      )],
    ).join();
  }

  Future<void> startQuiz(String quizId) async {
    await _supabase
        .from('quizzes')
        .update({
      'status': QuizStatus.started.name,
    })
        .eq('id', quizId);
  }

  /// Actualiza el estado del Quiz.
  Future<void> updateStatus({
    required String quizId,
    required QuizStatus status,
  }) async {
    await _supabase
        .from('quizzes')
        .update({'status': status.name})
        .eq('id', quizId);
  }

  /// NUEVO: Verifica si TODOS los participantes del Quiz ya terminaron
  /// (cada uno respondió la totalidad de sus preguntas asignadas).
  /// Si es así, cambia el estado de 'started' a 'finished'.
  ///
  /// Retorna true si el quiz fue finalizado en esta llamada.
  Future<bool> finalizeQuizIfAllParticipantsFinished(String quizId) async {
    final quiz = await getQuizById(quizId);
    if (quiz == null || quiz.status != QuizStatus.started) return false;

    // 1. Participantes del quiz
    final participantsResponse = await _supabase
        .from('participants')
        .select('id')
        .eq('quiz_id', quizId);

    final participantIds = (participantsResponse as List)
        .map((e) => Map<String, dynamic>.from(e)['id'] as String)
        .toList();

    // Sin participantes no hay nada que finalizar.
    if (participantIds.isEmpty) return false;

    // 2. Preguntas que debe responder cada participante
    final selectedResponse = await _supabase
        .from('quiz_selected_questions')
        .select('question_id')
        .eq('quiz_id', quizId);

    int expected = (selectedResponse as List).length;
    if (expected == 0) expected = quiz.questionCount;
    if (expected == 0) return false;

    // 3. Conteo de respuestas por participante
    final answersResponse = await _supabase
        .from('answers')
        .select('participant_id')
        .inFilter('participant_id', participantIds);

    final counts = <String, int>{};
    for (final row in (answersResponse as List)) {
      final pid = Map<String, dynamic>.from(row)['participant_id'] as String;
      counts[pid] = (counts[pid] ?? 0) + 1;
    }

    // 4. ¿Todos respondieron todo?
    final allFinished = participantIds.every(
          (pid) => (counts[pid] ?? 0) >= expected,
    );

    if (!allFinished) return false;

    await updateStatus(quizId: quizId, status: QuizStatus.finished);
    return true;
  }

  /// Inicia el Quiz de forma atómica:
  /// 1. Verifica que esté en 'waiting'
  /// 2. Selecciona y guarda las preguntas en quiz_selected_questions
  /// 3. Cambia el estado a 'started'
  Future<List<Map<String, dynamic>>> startQuizWithQuestions(String quizId) async {
    final response = await _supabase.rpc(
      'start_quiz_with_questions',
      params: {'p_quiz_id': quizId},
    );

    if (response == null) {
      throw Exception('No se pudo iniciar el Quiz.');
    }

    return List<Map<String, dynamic>>.from(response);
  }

}