import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/repositories/question_repository.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../models/prepared_question.dart';

class QuizLoadingScreen extends StatefulWidget {
  final String quizId;

  const QuizLoadingScreen({super.key, required this.quizId});

  @override
  State<QuizLoadingScreen> createState() => _QuizLoadingScreenState();
}

class _QuizLoadingScreenState extends State<QuizLoadingScreen> {
  final QuestionRepository _questionRepository = QuestionRepository();

  @override
  void initState() {
    super.initState();
    _loadAndPrepareQuestions();
  }

  Future<void> _loadAndPrepareQuestions() async {
    try {
      // 1. Obtener preguntas seleccionadas desde Supabase
      final questions = await _questionRepository.getSelectedQuestionsForQuiz(widget.quizId);

      if (!mounted) return;

      // 2. Mezclar preguntas y opciones para ESTE participante
      final preparedQuestions = prepareQuestionsForParticipant(questions);

      if (!mounted) return;

      // 3. Navegar al QuizScreen pasando los datos ya procesados
      // Usamos pushReplacement para que no pueda volver a la pantalla de carga
      context.pushReplacement(
        AppRoutes.quiz,
        extra: preparedQuestions,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar las preguntas: $e'),
          backgroundColor: Colors.red,
        ),
      );
      context.go(AppRoutes.home); // Fallback seguro
    }
  }

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Quiz',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 30),
            Icon(Icons.play_circle_outline, size: 70),
            SizedBox(height: 20),
            Text(
              '¡El Quiz ha comenzado!',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Preparando las preguntas...',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}