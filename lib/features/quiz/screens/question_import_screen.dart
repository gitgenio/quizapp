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
      final result =
      await FilePicker.platform.pickFiles(
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
        'No fue posible procesar el archivo Excel.',
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final result =
        _viewModel.validationResult;

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

          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,

              children: [
                _buildHeader(context),

                const SizedBox(height: 24),

                _buildFilePickerButton(),

                const SizedBox(height: 24),

                if (_viewModel.fileName != null)
                  _buildSelectedFile(),

                if (_viewModel.isProcessing)
                  _buildProcessingIndicator(),

                if (result != null)
                  _buildValidationResult(result),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ENCABEZADO
  // ============================================================

  Widget _buildHeader(
      BuildContext context,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

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
              .bodyLarge,
        ),

        const SizedBox(height: 8),

        Text(
          'El archivo debe contener una hoja llamada '
              '"Preguntas" y las columnas: '
              'Pregunta, A, B, C, D y Correcta.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium,
        ),
      ],
    );
  }

  // ============================================================
  // BOTÓN SELECCIONAR ARCHIVO
  // ============================================================

  Widget _buildFilePickerButton() {
    return SizedBox(
      height: 48,

      child: ElevatedButton.icon(
        onPressed:
        _viewModel.isProcessing
            ? null
            : _selectFile,

        icon: const Icon(
          Icons.upload_file,
        ),

        label: const Text(
          'Seleccionar archivo Excel',
        ),
      ),
    );
  }

  // ============================================================
  // ARCHIVO SELECCIONADO
  // ============================================================

  Widget _buildSelectedFile() {
    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(16),

        child: Row(
          children: [
            const Icon(
              Icons.description,
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Archivo seleccionado',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    _viewModel.fileName!,
                  ),
                ],
              ),
            ),

            if (!_viewModel.isProcessing)
              const Icon(
                Icons.check_circle_outline,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROCESANDO
  // ============================================================

  Widget _buildProcessingIndicator() {
    return const Padding(
      padding:
      EdgeInsets.symmetric(
        vertical: 32,
      ),

      child: Column(
        children: [
          CircularProgressIndicator(),

          SizedBox(
            height: 16,
          ),

          Text(
            'Procesando y validando el archivo...',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESULTADO DE VALIDACIÓN
  // ============================================================

  Widget _buildValidationResult(
      ImportValidationResult result,
      ) {
    final isValid =
        result.isValid;

    return Card(
      margin:
      const EdgeInsets.only(
        top: 8,
      ),

      child: Padding(
        padding:
        const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Icon(
                  isValid
                      ? Icons.check_circle
                      : Icons.error_outline,
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Text(
                    isValid
                        ? 'Archivo válido'
                        : 'Se encontraron errores',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            _buildSummary(
              result,
            ),

            if (!isValid)
              _buildErrors(
                result,
              ),

            if (isValid)
              _buildValidFileActions(
                result,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RESUMEN
  // ============================================================

  Widget _buildSummary(
      ImportValidationResult result,
      ) {
    return Container(
      width: double.infinity,

      padding:
      const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(12),

        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Text(
            'Resumen de validación',
            style: Theme.of(context)
                .textTheme
                .titleMedium,
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            'Preguntas encontradas: '
                '${result.validQuestionCount}',
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            'Errores encontrados: '
                '${result.errorCount}',
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            'Preguntas requeridas por el Quiz: '
                '${widget.requiredQuestionCount}',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERRORES
  // ============================================================

  Widget _buildErrors(
      ImportValidationResult result,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        const SizedBox(
          height: 24,
        ),

        Text(
          'Errores encontrados',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(
            fontWeight:
            FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        Container(
          width: double.infinity,

          padding:
          const EdgeInsets.all(16),

          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(8),

            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .error
                  .withOpacity(0.4),
            ),
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              ...result.errors.map(
                    (error) {
                  return Padding(
                    padding:
                    const EdgeInsets.only(
                      bottom: 10,
                    ),

                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        Icon(
                          Icons
                              .error_outline,
                          size: 20,
                          color: Theme.of(
                            context,
                          )
                              .colorScheme
                              .error,
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        Expanded(
                          child: Text(
                            error.toString(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 16,
        ),

        const Text(
          'Corrige los errores en el archivo Excel '
              'y vuelve a seleccionarlo para validar '
              'nuevamente.',
        ),
      ],
    );
  }

  // ============================================================
  // ARCHIVO VÁLIDO
  // ============================================================

  Widget _buildValidFileActions(
      ImportValidationResult result,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,

      children: [
        const SizedBox(
          height: 24,
        ),

        Container(
          padding:
          const EdgeInsets.all(16),

          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(8),

            color: Colors.green
                .withOpacity(0.08),
          ),

          child: const Text(
            'Todas las preguntas cumplen '
                'con las reglas de validación.',
          ),
        ),

        const SizedBox(
          height: 20,
        ),

        ElevatedButton.icon(
          onPressed: () {
            // Próximo paso:
            // mostrar vista previa
            // y permitir confirmar
            // la importación.
          },

          icon: const Icon(
            Icons.preview,
          ),

          label: const Text(
            'Ver vista previa',
          ),
        ),
      ],
    );
  }
}