import 'parsed_question.dart';
import 'import_error.dart';

/// Resultado del proceso de lectura y validación
/// de un archivo Excel.
class ImportValidationResult {
  /// Preguntas obtenidas y consideradas válidas.
  final List<ParsedQuestion> questions;

  /// Errores encontrados durante la validación.
  final List<ImportError> errors;

  const ImportValidationResult({
    required this.questions,
    required this.errors,
  });

  /// Indica si la importación es válida.
  bool get isValid => errors.isEmpty;

  /// Cantidad de preguntas válidas.
  int get validQuestionCount => questions.length;

  /// Cantidad de errores.
  int get errorCount => errors.length;
}