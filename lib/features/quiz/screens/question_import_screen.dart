import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../data/models/import_validation_result.dart';
import '../viewmodels/question_import_view_model.dart';

class QuestionImportScreen extends StatefulWidget {
  final String quizId;
  final int requiredQuestionCount;

  const QuestionImportScreen({
    super.key,
    required this.quizId,
    required this.requiredQuestionCount,
  });

  @override
  State<QuestionImportScreen> createState() =>
      _QuestionImportScreenState();
}

class _QuestionImportScreenState
    extends State<QuestionImportScreen> {
  late final QuestionImportViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = QuestionImportViewModel();
  }

  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );

      if (result == null) {
        return;
      }

      final file = result.files.single;

      if (file.bytes == null) {
        _showError(
          'No fue posible leer el archivo seleccionado.',
        );

        return;
      }

      setState(() {
        _viewModel.isProcessing = true;
        _viewModel.fileName = file.name;
        _viewModel.processingError = null;
        _viewModel.validationResult = null;
      });

      final validationResult =
      _viewModel.processFile(
        bytes: file.bytes!,
        selectedFileName: file.name,
        requiredQuestionCount:
        widget.requiredQuestionCount,
      );

      if (!mounted) {
        return;
      }

      setState(() {});

      if (validationResult == null &&
          _viewModel.processingError != null) {
        _showError(
          _viewModel.processingError!,
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showError(
        'No fue posible procesar el archivo.',
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _viewModel.validationResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Importar preguntas',
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 900,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Importar preguntas desde Excel',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall,
                ),

                const SizedBox(height: 8),

                Text(
                  'Selecciona un archivo XLSX con las '
                      'preguntas del Quiz.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
                ),

                const SizedBox(height: 24),

                ElevatedButton.icon(
                  onPressed: _viewModel.isProcessing
                      ? null
                      : _selectFile,
                  icon: const Icon(
                    Icons.upload_file,
                  ),
                  label: const Text(
                    'Seleccionar archivo Excel',
                  ),
                ),

                const SizedBox(height: 24),

                if (_viewModel.fileName != null)
                  Card(
                    child: Padding(
                      padding:
                      const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.description,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _viewModel.fileName!,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_viewModel.isProcessing)
                  const Padding(
                    padding:
                    EdgeInsets.symmetric(
                      vertical: 24,
                    ),
                    child: Center(
                      child:
                      CircularProgressIndicator(),
                    ),
                  ),

                if (result != null)
                  _buildValidationResult(
                    result,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValidationResult(
      ImportValidationResult  result,
      ) {
    final isValid = result.isValid;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              isValid
                  ? 'Archivo válido'
                  : 'Se encontraron errores',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge,
            ),

            const SizedBox(height: 16),

            Text(
              'Preguntas encontradas: '
                  '${result.validQuestionCount}',
            ),

            Text(
              'Errores: '
                  '${result.errorCount}',
            ),

            if (!isValid) ...[
              const SizedBox(height: 20),

              const Text(
                'Errores encontrados:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              ...result.errors.map(
                    (error) => Padding(
                  padding:
                  const EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: Text(
                    error.toString(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}