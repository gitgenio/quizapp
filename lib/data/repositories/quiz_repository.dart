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
        .order('created_at', ascending: false);

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

  Future<Quiz> createQuiz(
      Quiz quiz,
      ) async {
    final response = await _supabase
        .from('quizzes')
        .insert(
      quiz.toMap(),
    )
        .select()
        .single();

    return Quiz.fromMap(
      Map<String, dynamic>.from(response),
    );
  }
}