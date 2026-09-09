import 'prepared_question.dart';

class QuizSessionData {
  final String participantId;
  final int timePerQuestionSeconds;
  final List<PreparedQuestion> questions;

  QuizSessionData({
    required this.participantId,
    required this.timePerQuestionSeconds,
    required this.questions,
  });
}