/// Representa una pregunta obtenida temporalmente
/// desde un archivo Excel.
///
/// Este modelo NO representa una fila de la tabla questions.
/// Se utiliza únicamente durante el proceso de importación.
class ParsedQuestion {
  /// Número de fila original dentro del Excel.
  ///
  /// Se utiliza para mostrar errores al administrador.
  final int rowNumber;

  /// Enunciado de la pregunta.
  final String statement;

  /// Opción A.
  final String optionA;

  /// Opción B.
  final String optionB;

  /// Opción C.
  final String optionC;

  /// Opción D.
  final String optionD;

  /// Respuesta correcta.
  ///
  /// En esta etapa todavía es un String porque
  /// proviene directamente del Excel.
  final String correctAnswer;

  const ParsedQuestion({
    required this.rowNumber,
    required this.statement,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
  });
}