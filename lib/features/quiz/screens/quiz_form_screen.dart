import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/repositories/quiz_repository.dart';

class QuizFormScreen extends StatefulWidget {
  const QuizFormScreen({
    super.key,
  });

  @override
  State<QuizFormScreen> createState() =>
      _QuizFormScreenState();
}

class _QuizFormScreenState
    extends State<QuizFormScreen> {
  final _formKey =
  GlobalKey<FormState>();

  final _titleController =
  TextEditingController();

  final _questionCountController =
  TextEditingController();

  final _timeController =
  TextEditingController();

  final QuizRepository _quizRepository =
  QuizRepository();

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _questionCountController.dispose();
    _timeController.dispose();

    super.dispose();
  }

  Future<void> _createQuiz() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final title =
    _titleController.text.trim();

    final questionCount =
    int.parse(
      _questionCountController.text
          .trim(),
    );

    final timePerQuestionSeconds =
    int.parse(
      _timeController.text.trim(),
    );

    setState(() {
      _isLoading = true;
    });

    try {
      final quiz =
      await _quizRepository.createQuiz(
        title: title,
        questionCount:
        questionCount,
        timePerQuestionSeconds:
        timePerQuestionSeconds,
      );

      if (!mounted) return;

      context.go(
        '${AppRoutes.quizDetail}'
            '?quizId=${quiz.id}',
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo crear el Quiz: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateRequired(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Este campo es obligatorio.';
    }

    return null;
  }

  String? _validatePositiveInteger(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Este campo es obligatorio.';
    }

    final number =
    int.tryParse(value.trim());

    if (number == null ||
        number <= 0) {
      return 'Ingresa un número mayor que 0.';
    }

    return null;
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crear Quiz',
        ),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints:
          const BoxConstraints(
            maxWidth: 600,
          ),

          child: SingleChildScrollView(
            padding:
            const EdgeInsets.all(24),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,

                children: [
                  Text(
                    'Nuevo Quiz',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium,
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Text(
                    'Configura el Quiz antes de importar las preguntas.',
                  ),

                  const SizedBox(
                    height: 32,
                  ),

                  TextFormField(
                    controller:
                    _titleController,
                    decoration:
                    const InputDecoration(
                      labelText: 'Título',
                      border:
                      OutlineInputBorder(),
                    ),
                    validator:
                    _validateRequired,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  TextFormField(
                    controller:
                    _questionCountController,
                    keyboardType:
                    TextInputType.number,
                    decoration:
                    const InputDecoration(
                      labelText:
                      'Preguntas por participante',
                      helperText:
                      'Ejemplo: 5',
                      border:
                      OutlineInputBorder(),
                    ),
                    validator:
                    _validatePositiveInteger,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  TextFormField(
                    controller:
                    _timeController,
                    keyboardType:
                    TextInputType.number,
                    decoration:
                    const InputDecoration(
                      labelText:
                      'Tiempo por pregunta (segundos)',
                      helperText:
                      'Ejemplo: 30',
                      border:
                      OutlineInputBorder(),
                    ),
                    validator:
                    _validatePositiveInteger,
                  ),

                  const SizedBox(
                    height: 32,
                  ),

                  SizedBox(
                    height: 48,
                    child:
                    ElevatedButton.icon(
                      onPressed:
                      _isLoading
                          ? null
                          : _createQuiz,
                      icon: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                        CircularProgressIndicator(
                          strokeWidth:
                          2,
                        ),
                      )
                          : const Icon(
                        Icons.save,
                      ),
                      label: Text(
                        _isLoading
                            ? 'Creando...'
                            : 'Crear Quiz',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}