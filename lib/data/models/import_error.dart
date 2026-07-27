/// Representa un error encontrado durante
/// la validación de un archivo Excel.
class ImportError {
  /// Número de fila donde ocurrió el error.
  final int rowNumber;

  /// Nombre de la columna relacionada con el error.
  final String? column;

  /// Descripción del error.
  final String message;

  const ImportError({
    required this.rowNumber,
    this.column,
    required this.message,
  });

  @override
  String toString() {
    if (column != null && column!.isNotEmpty) {
      return 'Fila $rowNumber - Columna $column: $message';
    }

    return 'Fila $rowNumber: $message';
  }
}