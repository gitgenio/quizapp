import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';

import '../data/models/parsed_question.dart';

/// Se encarga de leer el contenido de un archivo Excel
/// y convertir sus filas en objetos ParsedQuestion.
class ExcelParser {
  /// Nombre esperado de la hoja de Excel.
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
  List<ParsedQuestion> parse(Uint8List bytes) {
    if (bytes.isEmpty) {
      throw const FormatException('El archivo está vacío.');
    }

    final Excel excel;

    try {
      excel = Excel.decodeBytes(bytes);
    } catch (e) {
      throw const FormatException(
        'No fue posible leer el archivo Excel. '
            'Verifique que sea un archivo XLSX válido.',
      );
    }

    debugPrint('=== [EXCEL PARSER] INICIO DE LECTURA ===');
    debugPrint('Hojas encontradas en el Excel: ${excel.tables.keys.toList()}');

    // Búsqueda flexible de la hoja (ignora mayúsculas/espacios)
    String? foundSheetName;
    for (final key in excel.tables.keys) {
      if (key.trim().toLowerCase() == expectedSheetName.toLowerCase()) {
        foundSheetName = key;
        break;
      }
    }

    if (foundSheetName == null) {
      throw FormatException(
        'No se encontró la hoja "$expectedSheetName". '
            'Hojas disponibles: ${excel.tables.keys.join(", ")}',
      );
    }

    final sheet = excel.tables[foundSheetName];

    if (sheet == null) {
      throw FormatException(
        'No fue posible acceder a la hoja "$foundSheetName".',
      );
    }

    debugPrint('Filas totales en la hoja: ${sheet.rows.length}');

    if (sheet.rows.length < 2) {
      throw const FormatException(
        'El archivo no contiene filas de preguntas.',
      );
    }

    final headers = _readHeaders(sheet);
    debugPrint('Encabezados leídos: $headers');

    _validateRequiredColumns(headers);

    final columnIndexes = _buildColumnIndexes(headers);
    debugPrint('Índices de columnas construidos: $columnIndexes');

    final questions = <ParsedQuestion>[];

    for (int rowIndex = 1; rowIndex < sheet.rows.length; rowIndex++) {
      final row = sheet.rows[rowIndex];

      final values = _extractRowValues(
        row,
        columnIndexes,
      );

      // Ignoramos filas completamente vacías.
      if (_isCompletelyEmpty(values)) {
        continue;
      }

      final parsed = ParsedQuestion(
        rowNumber: rowIndex + 1,
        statement: values['Pregunta'] ?? '',
        optionA: values['A'] ?? '',
        optionB: values['B'] ?? '',
        optionC: values['C'] ?? '',
        optionD: values['D'] ?? '',
        correctAnswer: values['Correcta'] ?? '',
      );

      debugPrint('-> Fila ${parsed.rowNumber} parseada exitosamente: "${parsed.statement}"');
      questions.add(parsed);
    }

    debugPrint('=== TOTAL PREGUNTAS EXTRAÍDAS: ${questions.length} ===');
    return questions;
  }

  /// Lee los encabezados de la primera fila.
  List<String> _readHeaders(Sheet sheet) {
    if (sheet.rows.isEmpty) return [];

    final headerRow = sheet.rows.first;

    return headerRow.map((cell) => _cellToString(cell)).toList();
  }

  /// Verifica que todas las columnas obligatorias existan.
  void _validateRequiredColumns(List<String> headers) {
    final normalizedHeaders = headers.map(_normalizeHeader).toSet();

    for (final requiredColumn in requiredColumns) {
      if (!normalizedHeaders.contains(_normalizeHeader(requiredColumn))) {
        throw FormatException(
          'Falta la columna obligatoria "$requiredColumn".',
        );
      }
    }
  }

  /// Construye un mapa: nombre de columna → índice
  Map<String, int> _buildColumnIndexes(List<String> headers) {
    final indexes = <String, int>{};

    for (int i = 0; i < headers.length; i++) {
      final normalized = _normalizeHeader(headers[i]);

      for (final requiredColumn in requiredColumns) {
        if (normalized == _normalizeHeader(requiredColumn)) {
          indexes[requiredColumn] = i;
        }
      }
    }

    return indexes;
  }

  /// Extrae los valores de una fila utilizando los índices de las columnas.
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

  /// Convierte una celda de Excel en String limpio de forma universal.
  String _cellToString(Data? cell) {
    if (cell == null || cell.value == null) {
      return '';
    }

    final value = cell.value;
    dynamic rawVal;

    try {
      // Si el objeto 'CellValue' tiene una propiedad interna .value la extraemos
      rawVal = (value as dynamic).value ?? value;
    } catch (_) {
      rawVal = value;
    }

    String str = rawVal.toString().trim();

    // Limpia nombres de clases si la celda imprime algo como "TextCellValue(value: Texto)"
    if (str.contains('(') && str.endsWith(')')) {
      final match = RegExp(r'value:\s*([^)]+)').firstMatch(str);
      if (match != null) {
        str = match.group(1)?.trim() ?? str;
      }
    }

    return str;
  }

  String _normalizeHeader(String value) {
    return value.trim().toLowerCase();
  }

  bool _isCompletelyEmpty(Map<String, String> values) {
    return values.values.every(
          (value) => value.trim().isEmpty,
    );
  }
}