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

  Future<Quiz> getQuizById(
      String quizId,
      ) async {
    final response = await _supabase
        .from('quizzes')
        .select()
        .eq('id', quizId)
        .single();

    return Quiz.fromMap(
      Map<String, dynamic>.from(response),
    );
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

  // Future<void> deleteQuiz(String id) async {
  //   await supabase
  //       .from('quizzes')
  //       .delete()
  //       .eq('id', id);
  // }

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