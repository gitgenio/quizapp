import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/repositories/results_repository.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../player/models/quiz_result.dart';

class FinishScreen extends StatelessWidget {
  final String? participantId;
  final String? quizId;

  const FinishScreen({
    super.key,
    this.participantId,
    this.quizId,
  });

  @override
  Widget build(BuildContext context) {
    // Si no tenemos IDs, mostramos pantalla genérica de respaldo.
    if (participantId == null || quizId == null || quizId!.isEmpty) {
      return _buildGenericScreen(context);
    }

    return _buildResultScreen(context);
  }

  Widget _buildGenericScreen(BuildContext context) {
    return AppScaffold(
      title: "Finalizado",
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, size: 90, color: Colors.amber),
                const SizedBox(height: 20),
                Text(
                  "¡Has terminado!",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Gracias por participar en el cuestionario.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                PrimaryButton(
                  text: "Volver al inicio",
                  icon: Icons.home,
                  onPressed: () => context.go(AppRoutes.home),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen(BuildContext context) {
    return AppScaffold(
      title: "Tus Resultados",
      child: FutureBuilder<QuizResult?>(
        future: ResultsRepository().getParticipantResult(
          participantId: participantId!,
          quizId: quizId!,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorView(context, 'Ocurrió un error al cargar tus resultados.');
          }

          final result = snapshot.data;
          if (result == null) {
            return _buildErrorView(
              context,
              'Tus resultados aún se están procesando. Revisa con tu profesor.',
            );
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTrophyIcon(result.score),
                        const SizedBox(height: 16),
                        Text(
                          "¡Has terminado!",
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        _buildScoreCircle(context, result.score),
                        const SizedBox(height: 32),
                        _buildStatsGrid(context, result),
                        const SizedBox(height: 32),
                        PrimaryButton(
                          text: "Volver al inicio",
                          icon: Icons.home,
                          onPressed: () => context.go(AppRoutes.home),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrophyIcon(double score) {
    IconData icon;
    Color color;

    if (score >= 80) {
      icon = Icons.emoji_events;
      color = Colors.amber;
    } else if (score >= 60) {
      icon = Icons.emoji_events_outlined;
      color = Colors.orange;
    } else {
      icon = Icons.star_border;
      color = Colors.red;
    }

    return Icon(icon, size: 90, color: color);
  }

  Widget _buildScoreCircle(BuildContext context, double score) {
    Color color;
    String message;

    if (score >= 80) {
      color = Colors.green;
      message = "¡Excelente trabajo!";
    } else if (score >= 60) {
      color = Colors.orange;
      message = "¡Buen trabajo!";
    } else {
      color = Colors.red;
      message = "Sigue practicando";
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: CircularProgressIndicator(
                value: (score / 100).clamp(0.0, 1.0),
                strokeWidth: 12,
                backgroundColor: Colors.grey[200],
                color: color,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${score.toStringAsFixed(0)}%",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const Text(
                  "puntaje",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          message,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, QuizResult result) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            value: result.correctAnswers.toString(),
            label: "Correctas",
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            value: result.incorrectAnswers.toString(),
            label: "Incorrectas",
            icon: Icons.cancel,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            value: result.totalQuestions.toString(),
            label: "Total",
            icon: Icons.format_list_numbered,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      BuildContext context, {
        required String value,
        required String label,
        required IconData icon,
        required Color color,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: AppCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events, size: 90, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    "¡Has terminado!",
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  PrimaryButton(
                    text: "Volver al inicio",
                    icon: Icons.home,
                    onPressed: () => context.go(AppRoutes.home),
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