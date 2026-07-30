import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/quiz.dart';
import '../../../data/repositories/quiz_repository.dart';

class QuizDetailScreen extends StatefulWidget {
  final String quizId;

  const QuizDetailScreen({
    super.key,
    required this.quizId,
  });

  @override
  State<QuizDetailScreen> createState() =>
      _QuizDetailScreenState();
}

class _QuizDetailScreenState
    extends State<QuizDetailScreen> {
  final QuizRepository _quizRepository =
  QuizRepository();

  late Future<Quiz> _quizFuture;

  @override
  void initState() {
    super.initState();

    _loadQuiz();
  }

  void _loadQuiz() {
    _quizFuture =
        _quizRepository.getQuizById(
          widget.quizId,
        );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle del Quiz',
        ),
      ),

      body: FutureBuilder<Quiz>(
        future: _quizFuture,

        builder: (
            context,
            snapshot,
            ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    const Text(
                      'No se pudo cargar el Quiz.',
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _loadQuiz();
                        });
                      },
                      child: const Text(
                        'Reintentar',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final quiz =
              snapshot.data;

          if (quiz == null) {
            return const Center(
              child: Text(
                'Quiz no encontrado.',
              ),
            );
          }

          return SingleChildScrollView(
            padding:
            const EdgeInsets.all(24),

            child: Center(
              child: ConstrainedBox(
                constraints:
                const BoxConstraints(
                  maxWidth: 700,
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .stretch,

                  children: [
                    Text(
                      quiz.title,
                      style: Theme.of(
                        context,
                      )
                          .textTheme
                          .headlineMedium,
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    Card(
                      child: Padding(
                        padding:
                        const EdgeInsets.all(
                          20,
                        ),

                        child: Column(
                          children: [
                            _InfoRow(
                              label:
                              'Código de acceso',
                              value:
                              quiz.accessCode,
                            ),

                            const Divider(),

                            _InfoRow(
                              label:
                              'Preguntas por participante',
                              value:
                              '${quiz.questionCount}',
                            ),

                            const Divider(),

                            _InfoRow(
                              label:
                              'Tiempo por pregunta',
                              value:
                              '${quiz.timePerQuestionSeconds} segundos',
                            ),

                            const Divider(),

                            _InfoRow(
                              label:
                              'Estado',
                              value:
                              quiz.status.name,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    FilledButton.icon(
                      onPressed: () {
                        context.push(
                          '${AppRoutes.questionImport}'
                              '?quizId=${quiz.id}'
                              '&questionCount=${quiz.questionCount}',
                        );
                      },
                      icon: const Icon(
                        Icons.upload_file,
                      ),
                      label: const Text(
                        'Importar preguntas desde Excel',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow
    extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 8,
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          Text(
            value,
          ),
        ],
      ),
    );
  }
}