import 'imported_question.dart';

class ExcelImportResult {
  final List<ImportedQuestion> questions;

  final List<String> errors;

  const ExcelImportResult({
    required this.questions,
    required this.errors,
  });

  bool get isValid => errors.isEmpty;
}