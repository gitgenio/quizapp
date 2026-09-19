import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/enums/quiz_status.dart';
import '../../../data/models/quiz.dart';
import '../../../data/repositories/question_repository.dart';
import '../../../data/repositories/quiz_repository.dart';

class QuizDetailScreen extends StatefulWidget {
  final String quizId;

  const QuizDetailScreen({
    super.key,
    required this.quizId,
  });

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizData {
  final Quiz quiz;
  final int questionCount;

  const _QuizData({required this.quiz, required this.questionCount});
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  final QuizRepository _quizRepository = QuizRepository();

  late Future<_QuizData> _quizDataFuture;
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  void _loadQuizData() {
    _quizDataFuture = _fetchQuizData();
  }

  Future<_QuizData> _fetchQuizData() async {
    final quiz = await _quizRepository.getQuizById(widget.quizId);
    if (quiz == null) throw Exception('Quiz no encontrado');

    final response = await Supabase.instance.client
        .from('questions')
        .select('id')
        .eq('quiz_id', quiz.id)
        .count(CountOption.exact);

    return _QuizData(quiz: quiz, questionCount: response.count ?? 0);
  }

  Future<void> _startQuiz(Quiz quiz) async {
    if (_isStarting) return;

    setState(() {
      _isStarting = true;
    });

    try {
      // Seguridad: si por alguna razón todavía está en draft, lo pasamos a waiting.
      if (quiz.status == QuizStatus.draft) {
        await _quizRepository.updateStatus(
          quizId: quiz.id,
          status: QuizStatus.waiting,
        );
      }

      await _quizRepository.startQuizWithQuestions(quiz.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El Quiz ha sido iniciado. Los participantes ya pueden entrar.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {
        _isStarting = false;
        _loadQuizData();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isStarting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo iniciar el Quiz: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showQuestionsDialog(String quizId) async {
    final repository = QuestionRepository();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // LÍNEA CORREGIDA: usa getQuestionsForQuiz (tabla questions),
      // no getSelectedQuestionsForQuiz (tabla quiz_selected_questions).
      final questions = await repository.getQuestionsForQuiz(quizId);

      if (!mounted) return;
      Navigator.of(context).pop(); // cerrar loading

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Preguntas del Quiz (${questions.length})'),
          content: SizedBox(
            width: double.maxFinite,
            child: questions.isEmpty
                ? const Center(child: Text('No hay preguntas.'))
                : ListView.separated(
              shrinkWrap: true,
              itemCount: questions.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, index) {
                final q = questions[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(q.statement, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text('Correcta: ${q.correctAnswer}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('CERRAR'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // cerrar loading si quedó abierto

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudieron cargar las preguntas: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  String _statusLabel(QuizStatus status) {
    switch (status) {
      case QuizStatus.draft:
        return 'Borrador';
      case QuizStatus.waiting:
        return 'Esperando';
      case QuizStatus.started:
        return 'En curso';
      case QuizStatus.finished:
        return 'Finalizado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Quiz'),
      ),
      body: FutureBuilder<_QuizData>(
        future: _quizDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'No se pudo cargar el Quiz: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(_loadQuizData),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('Quiz no encontrado.'));
          }

          final quiz = data.quiz;
          final questionCount = data.questionCount;

          final bool canStart = questionCount > 0 &&
              (quiz.status == QuizStatus.waiting ||
                  quiz.status == QuizStatus.draft);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      quiz.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _InfoRow(label: 'Nombre', value: quiz.title),
                            const Divider(),
                            _InfoRow(label: 'Código', value: quiz.accessCode),
                            const Divider(),
                            _InfoRow(
                              label: 'Estado',
                              value: _statusLabel(quiz.status),
                            ),
                            const Divider(),
                            _InfoRow(
                              label: 'Preguntas cargadas',
                              value: '$questionCount',
                              valueColor:
                              questionCount > 0 ? Colors.green : Colors.orange,
                            ),
                            const Divider(),
                            _InfoRow(
                              label: 'Preguntas por participante',
                              value: '${quiz.questionCount}',
                            ),
                            const Divider(),
                            _InfoRow(
                              label: 'Tiempo por pregunta',
                              value: '${quiz.timePerQuestionSeconds} segundos',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ===== REGLA DE BOTONES =====
                    if (questionCount == 0) ...[
                      FilledButton.icon(
                        onPressed: () async {
                          await context.push(
                            '${AppRoutes.questionImport}?quizId=${quiz.id}&questionCount=${quiz.questionCount}',
                          );
                          if (mounted) setState(_loadQuizData);
                        },
                        icon: const Icon(Icons.upload_file),
                        label: const Text('IMPORTAR EXCEL'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ] else if (canStart) ...[
                      OutlinedButton.icon(
                        onPressed: () => _showQuestionsDialog(quiz.id),
                        icon: const Icon(Icons.list),
                        label: const Text('VER PREGUNTAS'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _isStarting ? null : () => _startQuiz(quiz),
                        icon: _isStarting
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(Icons.play_arrow, size: 28),
                        label: Text(
                          _isStarting ? 'INICIANDO...' : 'INICIAR QUIZ',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green.shade600,
                        ),
                      ),
                    ] else if (quiz.status == QuizStatus.started) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.live_tv,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'QUIZ EN CURSO',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (quiz.status == QuizStatus.finished) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline),
                            SizedBox(width: 12),
                            Text(
                              'QUIZ FINALIZADO',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w600, color: valueColor),
          ),
        ],
      ),
    );
  }
}