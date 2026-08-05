import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/parsed_question.dart';

class QuestionRepository {
  final SupabaseClient _supabase;

  QuestionRepository({
    SupabaseClient? supabase,
  }) : _supabase =
      supabase ?? Supabase.instance.client;

  /// Inserta todas las preguntas de un Quiz.
  Future<void> createQuestions({
    required String quizId,
    required List<ParsedQuestion> questions,
  }) async {
    if (questions.isEmpty) return;

    final data = questions
        .asMap()
        .entries
        .map((entry) {
      final index = entry.key;
      final question = entry.value;

      return {
        'quiz_id': quizId,
        'order': index + 1,
        'statement': question.statement,
        'option_a': question.optionA,
        'option_b': question.optionB,
        'option_c': question.optionC,
        'option_d': question.optionD,
        'correct_answer':
        question.correctAnswer.trim().toUpperCase(),
        'type': 'singleChoice',
      };
    }).toList();

    await _supabase
        .from('questions')
        .insert(data);
  }
}