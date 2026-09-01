import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/enums/quiz_status.dart';
import '../../../data/models/quiz.dart';
import '../../../data/repositories/quiz_repository.dart';

class StartQuizScreen extends StatefulWidget {
  final Quiz quiz;

  const StartQuizScreen({
    super.key,
    required this.quiz,
  });

  @override
  State<StartQuizScreen> createState() => _StartQuizScreenState();
}

class _StartQuizScreenState extends State<StartQuizScreen> {
  final QuizRepository _quizRepository = QuizRepository();

  bool _isStarting = false;

  Future<void> _startQuiz() async {
    if (_isStarting) return;

    setState(() {
      _isStarting = true;
    });

    try {
      await _quizRepository.startQuiz(widget.quiz.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El Quiz ha sido iniciado.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isStarting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo iniciar el Quiz: $e',
          ),
          backgroundColor:
          Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quiz = widget.quiz;

    final canStart =
        quiz.status == QuizStatus.waiting;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Quiz'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 650,
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.play_circle_outline,
                      size: 72,
                    ),

                    const SizedBox(height: 24),

                    Text(
                      quiz.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium,
                    ),

                    const SizedBox(height: 32),

                    _InfoRow(
                      label: 'Código de acceso',
                      value: quiz.accessCode,
                    ),

                    const Divider(),

                    _InfoRow(
                      label: 'Preguntas por participante',
                      value: '${quiz.questionCount}',
                    ),

                    const Divider(),

                    _InfoRow(
                      label: 'Tiempo por pregunta',
                      value:
                      '${quiz.timePerQuestionSeconds} segundos',
                    ),

                    const Divider(),

                    _InfoRow(
                      label: 'Estado actual',
                      value: quiz.status.name,
                    ),

                    const SizedBox(height: 32),

                    if (canStart)
                      FilledButton.icon(
                        onPressed:
                        _isStarting
                            ? null
                            : _startQuiz,
                        icon: _isStarting
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : const Icon(
                          Icons.play_arrow,
                        ),
                        label: Text(
                          _isStarting
                              ? 'INICIANDO...'
                              : 'INICIAR QUIZ',
                        ),
                      )
                    else
                      Container(
                        padding:
                        const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(12),
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                        child: Text(
                          quiz.status ==
                              QuizStatus.started
                              ? 'Este Quiz ya fue iniciado.'
                              : 'El Quiz debe estar en estado "waiting" para poder iniciarlo.',
                          textAlign:
                          TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 12),

                    OutlinedButton(
                      onPressed: _isStarting
                          ? null
                          : () => context.pop(),
                      child: const Text('VOLVER'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(value),
        ],
      ),
    );
  }
}