import 'prepared_question.dart';

class QuizSessionData {
  final int timePerQuestionSeconds;
  final List<PreparedQuestion> questions;

  QuizSessionData({
    required this.timePerQuestionSeconds,
    required this.questions,
  });
}