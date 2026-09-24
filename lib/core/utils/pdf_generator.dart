import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/models/quiz.dart';
import '../../features/player/models/quiz_result.dart';

class PdfGenerator {
  /// Genera y descarga el PDF de resultados de un Quiz.
  static Future<void> generateAndDownloadQuizResults({
    required Quiz quiz,
    required List<QuizResult> results,
  }) async {
    final pdf = pw.Document();

    // Sanitizar nombre del archivo
    final safeTitle = quiz.title
        .replaceAll(RegExp(r'[^a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s]'), '')
        .replaceAll(' ', '_')
        .toLowerCase();
    final fileName = 'resultados_${safeTitle}.pdf';

    // Calcular estadísticas para el encabezado
    final totalParticipants = results.length;
    final averageScore = totalParticipants > 0
        ? results.fold<double>(0, (sum, r) => sum + r.score) / totalParticipants
        : 0.0;

    // NOTA: Ajusta 'results.first.date' o 'results.first.completedAt' según
    // el nombre real de la propiedad de fecha en tu modelo QuizResult.
    final quizDate = results.isNotEmpty && results.first.createdAt != null
        ? results.first.createdAt!
        : DateTime.now();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ENCABEZADO
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'QUIZAPP',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.Text(
                      'RESULTADOS DEL QUIZ',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // INFO DEL QUIZ
              pw.Text(
                  'Quiz: ${quiz.title}',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)
              ),
              pw.SizedBox(height: 8),

              // FECHAS (Generación a la izquierda, Realización a la derecha)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                      'Fecha de generación: ${_formatDate(DateTime.now())}',
                      style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)
                  ),
                  pw.Text(
                      'Fecha de realización: ${_formatDate(quizDate)}',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // ESTADÍSTICAS GENERALES
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('Participantes', '$totalParticipants'),
                    _buildStatColumn('Promedio', '${averageScore.toStringAsFixed(1)}%'),
                    _buildStatColumn('Mejor Puntaje', '${results.isNotEmpty ? results.first.score.toStringAsFixed(1) : 0}%'),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // TABLA DE RESULTADOS
              pw.Text(
                'Detalle por Participante',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),

              pw.TableHelper.fromTextArray(
                border: null,
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blue800,
                ),
                headerHeight: 25,
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.center,       // #
                  1: pw.Alignment.centerLeft,   // Participante
                  2: pw.Alignment.centerLeft,   // Email
                  3: pw.Alignment.center,       // Respuestas
                  4: pw.Alignment.center,       // Puntaje
                },
                headers: [
                  '#',
                  'Participante',
                  'Email',
                  'Respuestas',
                  'Puntaje',
                ],
                data: results.asMap().entries.map((entry) {
                  final index = entry.key;
                  final result = entry.value;

                  // Usamos el totalQuestions que ya viene en tu modelo
                  final totalQuestions = result.totalQuestions;

                  // Mostramos el email, o un mensaje por defecto si viene vacío
                  final emailDisplay = result.email.trim().isNotEmpty
                      ? result.email
                      : 'No disponible';

                  return [
                    '${index + 1}',
                    result.displayName,
                    emailDisplay,
                    '${result.correctAnswers}/$totalQuestions', // Ej: 1/3
                    '${result.score.toStringAsFixed(1)}%',
                  ];
                }).toList(),
              ),
              pw.Spacer(),

              // PIE DE PÁGINA
              pw.Divider(),
              pw.Text(
                'Generado automáticamente por QuizApp',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
              ),
            ],
          );
        },
      ),
    );

    // Guardar y descargar
    final pdfBytes = await pdf.save();

    // Printing.sharePdf maneja la descarga en Web y la vista previa en móvil/escritorio
    // Nota: se usa 'filename' en lugar de 'body' que es el parámetro correcto del paquete
    await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
  }

  static pw.Widget _buildStatColumn(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    return '${localDate.day.toString().padLeft(2, '0')}/${localDate.month.toString().padLeft(2, '0')}/${localDate.year}';
  }
}