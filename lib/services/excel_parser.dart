import 'dart:typed_data';

import 'package:excel/excel.dart';

import '../data/models/parsed_question.dart';

/// Se encarga de leer el contenido de un archivo Excel
/// y convertir sus filas en objetos ParsedQuestion.
///
/// Esta clase NO realiza validaciones de negocio.
/// Su responsabilidad es únicamente interpretar
/// la estructura básica del archivo.
class ExcelParser {
  /// Nombre esperado de la hoja de Excel.
  ///
  /// Por ahora utilizaremos "Preguntas".
  static const String expectedSheetName = 'Preguntas';

  /// Columnas obligatorias que debe contener el Excel.
  static const List<String> requiredColumns = [
    'Pregunta',
    'A',
    'B',
    'C',
    'D',
    'Correcta',
  ];

  /// Lee un archivo XLSX a partir de sus bytes.
  ///
  /// Devuelve una lista de ParsedQuestion.
  ///
  /// Los errores de estructura del archivo se lanzan
  /// como excepciones para que la capa superior
  /// pueda mostrarlos al usuario.
  List<ParsedQuestion> parse(Uint8List bytes) {
    if (bytes.isEmpty) {
      throw const FormatException(
        'El archivo está vacío.',
      );
    }

    final Excel excel;

    try {
      excel = Excel.decodeBytes(bytes);
    } catch (e) {
      throw FormatException(
        'No fue posible leer el archivo Excel. '
            'Verifique que sea un archivo XLSX válido.',
      );
    }

    if (!excel.tables.containsKey(expectedSheetName)) {
      throw FormatException(
        'No se encontró la hoja "$expectedSheetName". '
            'El archivo debe contener una hoja con ese nombre.',
      );
    }

    final sheet = excel.tables[expectedSheetName];

    if (sheet == null) {
      throw FormatException(
        'No fue posible acceder a la hoja "$expectedSheetName".',
      );
    }

    if (sheet.maxRows < 2) {
      throw const FormatException(
        'El archivo no contiene preguntas.',
      );
    }

    final headers = _readHeaders(sheet);

    _validateRequiredColumns(headers);

    final columnIndexes = _buildColumnIndexes(headers);

    final questions = <ParsedQuestion>[];

    for (int rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
      final row = sheet.row(rowIndex);

      final values = _extractRowValues(
        row,
        columnIndexes,
      );

      // Ignoramos filas completamente vacías.
      //
      // La validación específica de filas vacías
      // la realizaremos posteriormente.
      if (_isCompletelyEmpty(values)) {
        continue;
      }

      questions.add(
        ParsedQuestion(
          // Excel utiliza filas humanas comenzando en 1.
          // rowIndex comienza en 0.
          rowNumber: rowIndex + 1,
          statement: values['Pregunta'] ?? '',
          optionA: values['A'] ?? '',
          optionB: values['B'] ?? '',
          optionC: values['C'] ?? '',
          optionD: values['D'] ?? '',
          correctAnswer: values['Correcta'] ?? '',
        ),
      );
    }

    return questions;
  }

  /// Lee los encabezados de la primera fila.
  List<String> _readHeaders(Sheet sheet) {
    final headerRow = sheet.row(0);

    return headerRow.map((cell) {
      return _cellToString(cell);
    }).toList();
  }

  /// Verifica que todas las columnas obligatorias existan.
  void _validateRequiredColumns(List<String> headers) {
    final normalizedHeaders = headers
        .map(_normalizeHeader)
        .toSet();

    for (final requiredColumn in requiredColumns) {
      if (!normalizedHeaders.contains(
        _normalizeHeader(requiredColumn),
      )) {
        throw FormatException(
          'Falta la columna obligatoria "$requiredColumn".',
        );
      }
    }
  }

  /// Construye un mapa:
  ///
  /// nombre de columna → índice
  Map<String, int> _buildColumnIndexes(
      List<String> headers,
      ) {
    final indexes = <String, int>{};

    for (int i = 0; i < headers.length; i++) {
      final normalized = _normalizeHeader(headers[i]);

      for (final requiredColumn in requiredColumns) {
        if (normalized ==
            _normalizeHeader(requiredColumn)) {
          indexes[requiredColumn] = i;
        }
      }
    }

    return indexes;
  }

  /// Extrae los valores de una fila utilizando
  /// los índices de las columnas.
  Map<String, String> _extractRowValues(
      List<Data?> row,
      Map<String, int> columnIndexes,
      ) {
    final result = <String, String>{};

    for (final column in requiredColumns) {
      final index = columnIndexes[column];

      if (index == null || index >= row.length) {
        result[column] = '';
        continue;
      }

      result[column] = _cellToString(row[index]);
    }

    return result;
  }

  /// Convierte una celda Excel en String.
  String _cellToString(Data? cell) {
    if (cell == null) {
      return '';
    }

    final value = cell.value;

    if (value == null) {
      return '';
    }

    return value.toString().trim();
  }

  /// Normaliza encabezados para permitir pequeñas
  /// diferencias de espacios y mayúsculas.
  String _normalizeHeader(String value) {
    return value.trim().toLowerCase();
  }

  /// Determina si todos los campos de una fila están vacíos.
  bool _isCompletelyEmpty(
      Map<String, String> values,
      ) {
    return values.values.every(
          (value) => value.trim().isEmpty,
    );
  }
}