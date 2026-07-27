import '../data/models/import_error.dart';
import '../data/models/import_validation_result.dart';
import '../data/models/parsed_question.dart';

/// Se encarga de validar las preguntas obtenidas
/// desde un archivo Excel.
///
/// Esta clase no lee archivos Excel.
/// Esa responsabilidad pertenece a ExcelParser.
///
/// ExcelValidator recibe datos ya convertidos
/// a ParsedQuestion y valida las reglas de negocio.
class ExcelValidator {
  /// Valores permitidos para la respuesta correcta.
  static const Set<String> validAnswerOptions = {
    'A',
    'B',
    'C',
    'D',
  };

  /// Valida una lista de preguntas importadas desde Excel.
  ///
  /// [questions] contiene las preguntas obtenidas
  /// por ExcelParser.
  ///
  /// [requiredQuestionCount] representa la cantidad
  /// de preguntas que el Quiz necesita mostrar
  /// a cada participante.
  ImportValidationResult validate({
    required List<ParsedQuestion> questions,
    required int requiredQuestionCount,
  }) {
    final errors = <ImportError>[];

    // ==========================================================
    // 1. Verificar que exista al menos una pregunta.
    // ==========================================================

    if (questions.isEmpty) {
      errors.add(
        const ImportError(
          rowNumber: 0,
          message: 'El archivo no contiene ninguna pregunta.',
        ),
      );

      return ImportValidationResult(
        questions: questions,
        errors: errors,
      );
    }

    // ==========================================================
    // 2. Verificar cantidad suficiente de preguntas.
    // ==========================================================

    if (questions.length < requiredQuestionCount) {
      errors.add(
        ImportError(
          rowNumber: 0,
          message:
          'El archivo contiene ${questions.length} preguntas, '
              'pero el Quiz requiere al menos '
              '$requiredQuestionCount preguntas.',
        ),
      );
    }

    // ==========================================================
    // 3. Detectar preguntas duplicadas.
    // ==========================================================

    final questionRows = <String, int>{};

    for (final question in questions) {
      final normalizedStatement =
      _normalizeText(question.statement);

      if (normalizedStatement.isEmpty) {
        continue;
      }

      final previousRow =
      questionRows[normalizedStatement];

      if (previousRow != null) {
        errors.add(
          ImportError(
            rowNumber: question.rowNumber,
            column: 'Pregunta',
            message:
            'La pregunta está duplicada. '
                'También aparece en la fila $previousRow.',
          ),
        );
      } else {
        questionRows[normalizedStatement] =
            question.rowNumber;
      }
    }

    // ==========================================================
    // 4. Validar cada pregunta.
    // ==========================================================

    for (final question in questions) {
      _validateQuestion(
        question: question,
        errors: errors,
      );
    }

    return ImportValidationResult(
      questions: questions,
      errors: errors,
    );
  }

  /// Valida individualmente una pregunta.
  void _validateQuestion({
    required ParsedQuestion question,
    required List<ImportError> errors,
  }) {
    // ==========================================================
    // Pregunta
    // ==========================================================

    if (question.statement.trim().isEmpty) {
      errors.add(
        ImportError(
          rowNumber: question.rowNumber,
          column: 'Pregunta',
          message: 'La pregunta está vacía.',
        ),
      );
    }

    // ==========================================================
    // Opción A
    // ==========================================================

    if (question.optionA.trim().isEmpty) {
      errors.add(
        ImportError(
          rowNumber: question.rowNumber,
          column: 'A',
          message: 'La opción A está vacía.',
        ),
      );
    }

    // ==========================================================
    // Opción B
    // ==========================================================

    if (question.optionB.trim().isEmpty) {
      errors.add(
        ImportError(
          rowNumber: question.rowNumber,
          column: 'B',
          message: 'La opción B está vacía.',
        ),
      );
    }

    // ==========================================================
    // Opción C
    // ==========================================================

    if (question.optionC.trim().isEmpty) {
      errors.add(
        ImportError(
          rowNumber: question.rowNumber,
          column: 'C',
          message: 'La opción C está vacía.',
        ),
      );
    }

    // ==========================================================
    // Opción D
    // ==========================================================

    if (question.optionD.trim().isEmpty) {
      errors.add(
        ImportError(
          rowNumber: question.rowNumber,
          column: 'D',
          message: 'La opción D está vacía.',
        ),
      );
    }

    // ==========================================================
    // Respuesta correcta
    // ==========================================================

    final normalizedCorrectAnswer =
    question.correctAnswer.trim().toUpperCase();

    if (!validAnswerOptions.contains(
      normalizedCorrectAnswer,
    )) {
      errors.add(
        ImportError(
          rowNumber: question.rowNumber,
          column: 'Correcta',
          message:
          'La respuesta "$normalizedCorrectAnswer" '
              'no es válida. Debe ser A, B, C o D.',
        ),
      );
    }
  }

  /// Normaliza el texto para detectar duplicados.
  ///
  /// Ejemplo:
  ///
  /// "¿Cuál es la capital de Francia?"
  ///
  /// "  ¿Cuál es la capital de Francia?  "
  ///
  /// serán consideradas la misma pregunta.
  String _normalizeText(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase();
  }
}