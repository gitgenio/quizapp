import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/parsed_question.dart';
import '../models/question.dart';

class QuestionRepository {
  final SupabaseClient _supabase;

  QuestionRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<void> createQuestions({
    required String quizId,
    required List<ParsedQuestion> questions,
  }) async {
    if (questions.isEmpty) return;

    final data = questions.asMap().entries.map((entry) {
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
        'correct_answer': question.correctAnswer.trim().toUpperCase(),
        'type': 'singleChoice',
      };
    }).toList();

    await _supabase.from('questions').insert(data);
  }

  Future<List<Question>> getSelectedQuestionsForQuiz(String quizId) async {
    print('========== QUERY SELECTED QUESTIONS ==========');
    print('Quiz ID: $quizId');

    try {
      final response = await _supabase
          .from('quiz_selected_questions')
          .select('''
            question_order,
            questions:question_id (
              id,
              quiz_id,
              order,
              statement,
              option_a,
              option_b,
              option_c,
              option_d,
              correct_answer,
              type
            )
          ''')
          .eq('quiz_id', quizId)
          .order('question_order', ascending: true);

      print('Response from Supabase: $response');
      print('Response type: ${response.runtimeType}');

      final List<dynamic> data = response as List<dynamic>;
      print('Number of records: ${data.length}');

      final questions = data.map((item) {
        print('Processing item: $item');
        final qMap = Map<String, dynamic>.from(item['questions']);
        return Question.fromMap(qMap);
      }).toList();

      print('Questions loaded: ${questions.length}');
      print('==========================================');

      return questions;
    } catch (e, stackTrace) {
      print('========== ERROR IN QUERY ==========');
      print('Error: $e');
      print('Stack: $stackTrace');
      print('====================================');
      rethrow;
    }
  }
}