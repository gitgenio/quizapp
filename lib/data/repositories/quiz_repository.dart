import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<Quiz?> getQuizById(String quizId) async { // Cambia a Quiz? para ser más seguro
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

  Future<void> deleteQuiz(String id) async {
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
}