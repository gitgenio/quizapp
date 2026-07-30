import '../../../data/models/enums/answer_option.dart';

class ImportedQuestion {
  final int rowNumber;

  final String statement;

  final String optionA;

  final String optionB;

  final String optionC;

  final String optionD;

  final AnswerOption correctAnswer;

  const ImportedQuestion({
    required this.rowNumber,
    required this.statement,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
  });
}