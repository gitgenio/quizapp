import 'dart:typed_data';

import '../../../data/models/import_error.dart';
import '../../../data/models/import_validation_result.dart';
import '../../../data/models/parsed_question.dart';
import '../../../services/excel_parser.dart';
import '../../../services/excel_validator.dart';

/// Controla el proceso de importación y validación
/// de preguntas desde un archivo Excel.
class QuestionImportViewModel {
  final ExcelParser _excelParser;
  final ExcelValidator _excelValidator;

  QuestionImportViewModel({
    ExcelParser? excelParser,
    ExcelValidator? excelValidator,
  })  : _excelParser = excelParser ?? ExcelParser(),
        _excelValidator =
            excelValidator ?? ExcelValidator();

  /// Nombre del archivo seleccionado.
  String? fileName;

  /// Indica si actualmente se está procesando el archivo.
  bool isProcessing = false;

  /// Resultado de la última validación.
  ImportValidationResult? validationResult;

  /// Error general de procesamiento.
  String? processingError;

  /// Procesa y valida un archivo Excel.
  ImportValidationResult? processFile({
    required Uint8List bytes,
    required String selectedFileName,
    required int requiredQuestionCount,
  }) {
    fileName = selectedFileName;
    processingError = null;
    validationResult = null;
    isProcessing = true;

    try {
      // ========================================================
      // 1. Leer Excel
      // ========================================================

      final List<ParsedQuestion> questions =
      _excelParser.parse(bytes);

      // ========================================================
      // 2. Validar preguntas
      // ========================================================

      final result = _excelValidator.validate(
        questions: questions,
        requiredQuestionCount:
        requiredQuestionCount,
      );

      validationResult = result;

      return result;
    } on FormatException catch (e) {
      processingError = e.message;
      return null;
    } catch (e) {
      processingError =
      'Ocurrió un error inesperado al procesar '
          'el archivo Excel.';

      return null;
    } finally {
      isProcessing = false;
    }
  }

  /// Limpia el resultado actual.
  void clear() {
    fileName = null;
    validationResult = null;
    processingError = null;
    isProcessing = false;
  }
}