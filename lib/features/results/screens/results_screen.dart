import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../data/models/quiz.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_title.dart';
import '../../player/models/quiz_result.dart';
import '../providers/results_providers.dart';
import '../viewmodels/results_view_model.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  List<Quiz> _quizzes = [];
  Quiz? _selectedQuiz;
  bool _isLoadingQuizzes = false;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    setState(() {
      _isLoadingQuizzes = true;
    });

    try {
      final quizzes = await QuizRepository().getQuizzes();
      if (mounted) {
        setState(() {
          _quizzes = quizzes;
          _isLoadingQuizzes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingQuizzes = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar quizzes: $e')),
        );
      }
    }
  }

  void _onQuizSelected(Quiz? quiz) {
    setState(() {
      _selectedQuiz = quiz;
    });

    if (quiz != null) {
      ref.read(resultsViewModelProvider).loadResults(quiz.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(resultsViewModelProvider);

    return AppScaffold(
      title: 'Resultados',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Resultados',
            subtitle: 'Consultar resultados por Quiz',
          ),
          const SizedBox(height: 24),

          // Selector de Quiz
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seleccionar Quiz:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                if (_isLoadingQuizzes)
                  const Center(child: CircularProgressIndicator())
                else if (_quizzes.isEmpty)
                  const Text('No hay quizzes disponibles.')
                else
                  DropdownButtonFormField<Quiz>(
                    value: _selectedQuiz,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Selecciona un quiz',
                    ),
                    items: _quizzes.map((quiz) {
                      return DropdownMenuItem<Quiz>(
                        value: quiz,
                        child: Text(quiz.title),
                      );
                    }).toList(),
                    onChanged: _onQuizSelected,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Mostrar resultados si hay un quiz seleccionado
          if (_selectedQuiz != null) ...[
            // Cargando
            if (viewModel.isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            // Error
            else if (viewModel.error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(viewModel.error!),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        text: 'Reintentar',
                        icon: Icons.refresh,
                        onPressed: () =>
                            viewModel.loadResults(_selectedQuiz!.id),
                      ),
                    ],
                  ),
                ),
              )
            // Sin resultados
            else if (!viewModel.hasResults)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No hay resultados para este quiz aún.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              // Con resultados
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsCards(viewModel),
                        const SizedBox(height: 24),
                        _buildResultsTable(viewModel, context),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            PrimaryButton(
                              text: 'Exportar PDF',
                              icon: Icons.picture_as_pdf,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Función de exportación en desarrollo...'),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            PrimaryButton(
                              text: 'Ver Estadísticas',
                              icon: Icons.bar_chart,
                              onPressed: () {
                                context.push(
                                  AppRoutes.statistics,
                                  extra: {
                                    'quizId': _selectedQuiz!.id,
                                    'results': viewModel.results,
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsCards(ResultsViewModel viewModel) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _StatCard(
          title: 'Participantes',
          value: viewModel.totalParticipants.toString(),
          icon: Icons.people,
          color: Colors.blue,
        ),
        _StatCard(
          title: 'Promedio',
          value: '${viewModel.averageScore.toStringAsFixed(1)}%',
          icon: Icons.school,
          color: Colors.green,
        ),
        _StatCard(
          title: 'Mejor Puntaje',
          value: '${viewModel.bestScore.toStringAsFixed(1)}%',
          icon: Icons.emoji_events,
          color: Colors.amber,
        ),
        _StatCard(
          title: 'Peor Puntaje',
          value: '${viewModel.worstScore.toStringAsFixed(1)}%',
          icon: Icons.trending_down,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildResultsTable(
      ResultsViewModel viewModel, BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resultados por Participante',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('#')),
                DataColumn(label: Text('Participante')),
                DataColumn(label: Text('Correctas')),
                DataColumn(label: Text('Incorrectas')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Puntaje')),
                DataColumn(label: Text('Fecha')),
                DataColumn(label: Text('Detalle')),
              ],
              rows: viewModel.results.asMap().entries.map((entry) {
                final index = entry.key;
                final result = entry.value;
                return DataRow(
                  cells: [
                    DataCell(Text('${index + 1}')),
                    DataCell(Text(result.displayName)),
                    DataCell(Text('${result.correctAnswers}')),
                    DataCell(Text('${result.incorrectAnswers}')),
                    DataCell(Text('${result.totalQuestions}')),
                    DataCell(
                      Text(
                        '${result.score.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: result.score >= 70
                              ? Colors.green
                              : result.score >= 60
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                    ),
                    DataCell(Text(_formatDate(result.createdAt))),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.visibility, size: 20),
                        onPressed: () =>
                            _showParticipantDetail(context, result),
                        tooltip: 'Ver detalle',
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showParticipantDetail(
      BuildContext context, QuizResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalle: ${result.displayName}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Puntaje: ${result.score.toStringAsFixed(1)}%'),
              Text(
                  'Correctas: ${result.correctAnswers}/${result.totalQuestions}'),
              const SizedBox(height: 16),
              const Text(
                'Detalle de respuestas:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('(Cargando respuestas...)'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: AppCard(
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}