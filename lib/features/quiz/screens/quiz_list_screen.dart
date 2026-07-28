import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/quiz.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../core/routes/app_routes.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({
    super.key,
  });

  @override
  State<QuizListScreen> createState() =>
      _QuizListScreenState();
}

class _QuizListScreenState
    extends State<QuizListScreen> {
  final QuizRepository _quizRepository =
  QuizRepository();

  late Future<List<Quiz>> _quizzesFuture;

  @override
  void initState() {
    super.initState();

    _loadQuizzes();
  }

  void _loadQuizzes() {
    _quizzesFuture =
        _quizRepository.getQuizzes();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadQuizzes();
    });

    await _quizzesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Quizzes'),
      ),

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: () {
          context.push(
            AppRoutes.quizForm,
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Crear Quiz'),
      ),

      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Quiz>>(
          future: _quizzesFuture,

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
                        'No se pudieron cargar '
                            'los Quizzes.',
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _loadQuizzes();
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

            final quizzes =
                snapshot.data ?? [];

            if (quizzes.isEmpty) {
              return ListView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 200,
                  ),
                  Center(
                    child: Text(
                      'Todavía no has creado '
                          'ningún Quiz.',
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding:
              const EdgeInsets.all(16),
              itemCount: quizzes.length,
              itemBuilder:
                  (context, index) {
                final quiz =
                quizzes[index];

                return _QuizCard(
                  quiz: quiz,
                  onTap: () {
                    context.push(
                      '${AppRoutes.quizDetail}'
                          '?quizId=${quiz.id}',
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback onTap;

  const _QuizCard({
    required this.quiz,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
      const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(
            Icons.quiz,
          ),
        ),

        title: Text(
          quiz.title,
        ),

        subtitle: Text(
          'Código: ${quiz.accessCode}',
        ),

        trailing: const Icon(
          Icons.chevron_right,
        ),

        onTap: onTap,
      ),
    );
  }
}