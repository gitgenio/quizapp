import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/repositories/question_repository.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../models/prepared_question.dart';
import '../models/quiz_session_data.dart';

class QuizLoadingScreen extends StatefulWidget {
  final String quizId;
  final String participantId; // <-- AGREGADO

  const QuizLoadingScreen({
    super.key,
    required this.quizId,
    required this.participantId, // <-- AGREGADO
  });

  @override
  State<QuizLoadingScreen> createState() => _QuizLoadingScreenState();
}

class _QuizLoadingScreenState extends State<QuizLoadingScreen> {
  final QuestionRepository _questionRepository = QuestionRepository();
  final QuizRepository _quizRepository = QuizRepository();

  @override
  void initState() {
    super.initState();
    _loadAndPrepareQuestions();
  }

  Future<void> _loadAndPrepareQuestions() async {
    try {
      print('========== QUIZ LOADING STARTED ==========');
      print('Participant ID recibido: ${widget.participantId}');

      // 1. Obtener el tiempo configurado para este Quiz
      final quiz = await _quizRepository.getQuizById(widget.quizId);
      if (quiz == null) throw Exception('Quiz no encontrado');

      // 2. Obtener preguntas seleccionadas desde Supabase
      final questions = await _questionRepository.getSelectedQuestionsForQuiz(widget.quizId);
      print('Preguntas cargadas: ${questions.length}');

      if (!mounted) return;

      // 3. Mezclar preguntas y opciones para ESTE participante
      final preparedQuestions = prepareQuestionsForParticipant(questions);
      print('Preguntas preparadas: ${preparedQuestions.length}');

      if (!mounted) return;

      // 4. Navegar al QuizScreen pasando los datos ya procesados
      context.pushReplacement(
        AppRoutes.quiz,
        extra: QuizSessionData(
          participantId: widget.participantId, // <-- USAMOS EL QUE RECIBIMOS
          timePerQuestionSeconds: quiz.timePerQuestionSeconds,
          questions: preparedQuestions,
        ),
      );
    } catch (e, stackTrace) {
      print('========== ERROR EN QUIZ LOADING ==========');
      print('Error: $e');
      print('Stack: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      context.go(AppRoutes.home);
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