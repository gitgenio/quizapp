import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../../data/models/quiz.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_title.dart';
import '../../player/models/quiz_result.dart';
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

      if (!mounted) return;

      setState(() {
        _quizzes = quizzes;
        _isLoadingQuizzes = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingQuizzes = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar quizzes: $e'),
        ),
      );
    }
  }

  void _onQuizSelected(Quiz? quiz) {
    setState(() {
      _selectedQuiz = quiz;
    });

    if (quiz != null) {
      ref
          .read(resultsViewModelProvider.notifier)
          .loadResults(quiz.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resultsViewModelProvider);

    return AppScaffold(
      title: 'Resultados',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1200,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // =========================================================
                // ENCABEZADO
                // =========================================================

                const SectionTitle(
                  title: 'Resultados',
                  subtitle: 'Consultar resultados por Quiz',
                ),

                const SizedBox(height: 24),

                // =========================================================
                // SELECTOR DE QUIZ
                // =========================================================

                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Seleccionar Quiz',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (_isLoadingQuizzes)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_quizzes.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          child: Text(
                            'No hay quizzes disponibles.',
                          ),
                        )
                      else
                        DropdownButtonFormField<Quiz>(
                          value: _selectedQuiz,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Selecciona un quiz',
                          ),
                          items: _quizzes.map((quiz) {
                            return DropdownMenuItem<Quiz>(
                              value: quiz,
                              child: Text(
                                quiz.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: _onQuizSelected,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // =========================================================
                // RESULTADOS
                // =========================================================

                if (_selectedQuiz != null)
                  _buildResultsContent(
                    context,
                    state,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsContent(
      BuildContext context,
      ResultsState state,
      ) {
    // =========================================================
    // CARGANDO
    // =========================================================

    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(48),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // =========================================================
    // ERROR
    // =========================================================

    if (state.error != null) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 56,
                color: Theme.of(context).colorScheme.error,
              ),

              const SizedBox(height: 16),

              Text(
                state.error!,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              PrimaryButton(
                text: 'Reintentar',
                icon: Icons.refresh,
                onPressed: () {
                  ref
                      .read(resultsViewModelProvider.notifier)
                      .loadResults(_selectedQuiz!.id);
                },
              ),
            ],
          ),
        ),
      );
    }

    // =========================================================
    // SIN RESULTADOS
    // =========================================================

    if (state.results.isEmpty) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              const Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Colors.grey,
              ),

              const SizedBox(height: 16),

              const Text(
                'No hay resultados para este quiz aún.',
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // =========================================================
    // CON RESULTADOS
    // =========================================================

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Estadísticas
        _buildStatsCards(context),

        const SizedBox(height: 24),

        // Tabla
        _buildResultsTable(context),

        const SizedBox(height: 24),

        // Botones
        _buildActionButtons(context, state),

        const SizedBox(height: 16),
      ],
    );
  }

  // =========================================================
  // TARJETAS DE ESTADÍSTICAS
  // =========================================================

  Widget _buildStatsCards(BuildContext context) {
    final notifier =
    ref.read(resultsViewModelProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        double cardWidth;

        if (width >= 900) {
          cardWidth = (width - 48) / 4;
        } else if (width >= 600) {
          cardWidth = (width - 16) / 2;
        } else {
          cardWidth = width;
        }

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                title: 'Participantes',
                value: notifier.totalParticipants.toString(),
                icon: Icons.people,
                color: Colors.blue,
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: _StatCard(
                title: 'Promedio',
                value:
                '${notifier.averageScore.toStringAsFixed(1)}%',
                icon: Icons.school,
                color: Colors.green,
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: _StatCard(
                title: 'Mejor Puntaje',
                value:
                '${notifier.bestScore.toStringAsFixed(1)}%',
                icon: Icons.emoji_events,
                color: Colors.amber,
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: _StatCard(
                title: 'Peor Puntaje',
                value:
                '${notifier.worstScore.toStringAsFixed(1)}%',
                icon: Icons.trending_down,
                color: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // TABLA
  // =========================================================

  Widget _buildResultsTable(BuildContext context) {
    final results =
        ref.watch(resultsViewModelProvider).results;

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

          // SOLO LA TABLA TIENE SCROLL HORIZONTAL
          ClipRect(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 24,
                horizontalMargin: 8,

                columns: const [
                  DataColumn(
                    label: Text('#'),
                  ),
                  DataColumn(
                    label: Text('Participante'),
                  ),
                  DataColumn(
                    label: Text('Correctas'),
                  ),
                  DataColumn(
                    label: Text('Incorrectas'),
                  ),
                  DataColumn(
                    label: Text('Total'),
                  ),
                  DataColumn(
                    label: Text('Puntaje'),
                  ),
                  DataColumn(
                    label: Text('Fecha'),
                  ),
                  DataColumn(
                    label: Text('Detalle'),
                  ),
                ],

                rows: results
                    .asMap()
                    .entries
                    .map(
                      (entry) {
                    final index = entry.key;
                    final result = entry.value;

                    return DataRow(
                      cells: [
                        DataCell(
                          Text('${index + 1}'),
                        ),

                        DataCell(
                          Text(
                            result.displayName,
                          ),
                        ),

                        DataCell(
                          Text(
                            '${result.correctAnswers}',
                          ),
                        ),

                        DataCell(
                          Text(
                            '${result.incorrectAnswers}',
                          ),
                        ),

                        DataCell(
                          Text(
                            '${result.totalQuestions}',
                          ),
                        ),

                        DataCell(
                          Text(
                            '${result.score.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontWeight:
                              FontWeight.bold,
                              color:
                              result.score >= 70
                                  ? Colors.green
                                  : result.score >= 60
                                  ? Colors.orange
                                  : Colors.red,
                            ),
                          ),
                        ),

                        DataCell(
                          Text(
                            _formatDate(
                              result.createdAt,
                            ),
                          ),
                        ),

                        DataCell(
                          IconButton(
                            icon: const Icon(
                              Icons.visibility,
                              size: 20,
                            ),
                            tooltip:
                            'Ver detalle',
                            onPressed: () {
                              _showParticipantDetail(
                                context,
                                result,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BOTONES
  // =========================================================

  Widget _buildActionButtons(
      BuildContext context,
      ResultsState state,
      ) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 12,
      runSpacing: 12,
      children: [
        PrimaryButton(
          text: 'Exportar PDF',
          icon: Icons.picture_as_pdf,
          onPressed: () async {
            // Mostrar indicador de carga
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Generando PDF, por favor espera...'),
                duration: Duration(seconds: 2),
              ),
            );

            try {
              await PdfGenerator.generateAndDownloadQuizResults(
                quiz: _selectedQuiz!,
                results: state.results,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PDF generado y descargado exitosamente.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al generar el PDF: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),

        PrimaryButton(
          text: 'Ver Estadísticas',
          icon: Icons.bar_chart,
          onPressed: () {
            context.push(
              AppRoutes.statistics,
              extra: {
                'quizId': _selectedQuiz!.id,
                'results': state.results,
              },
            );
          },
        ),
      ],
    );
  }

  // =========================================================
  // DETALLE PARTICIPANTE
  // =========================================================

  void _showParticipantDetail(
      BuildContext context,
      QuizResult result,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Detalle: ${result.displayName}',
          ),

          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Puntaje: '
                      '${result.score.toStringAsFixed(1)}%',
                ),

                Text(
                  'Correctas: '
                      '${result.correctAnswers}/'
                      '${result.totalQuestions}',
                ),

                const SizedBox(height: 16),

                const Text(
                  'Detalle de respuestas:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  '(Cargando respuestas...)',
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    // Convertir a hora local
    final localDate = date.toLocal();
    return '${localDate.day.toString().padLeft(2, '0')}/${localDate.month.toString().padLeft(2, '0')}/${localDate.year}';
  }
}

// =============================================================
// STAT CARD
// =============================================================

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
    return AppCard(
      child: SizedBox(
        height: 140,
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 38,
              color: color,
            ),

            const SizedBox(height: 10),

            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}