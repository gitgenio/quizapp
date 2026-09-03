import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../models/prepared_question.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<PreparedQuestion> _questions;
  int _currentIndex = 0;
  int? _selectedIndex; // Guarda el índice (0-3) de la opción que el usuario tocó

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Recibimos las preguntas preparadas desde QuizLoadingScreen
    final args = GoRouterState.of(context).extra;
    if (args is List<PreparedQuestion> && args.isNotEmpty) {
      _questions = args;
    } else {
      // Fallback por si se accede directamente a la ruta sin datos
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.home);
      });
      _questions = [];
    }
  }

  void _handleOptionSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _nextQuestion() {
    if (_selectedIndex == null) return; // Obligar a seleccionar una respuesta

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null; // Resetear para la siguiente pregunta
      });
    } else {
      // Fin del quiz
      // Aquí podrías guardar la respuesta final en Supabase antes de navegar
      context.go(AppRoutes.finish);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const AppScaffold(
        title: 'Quiz',
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = _questions[_currentIndex];
    final totalQuestions = _questions.length;

    return AppScaffold(
      title: 'Pregunta ${_currentIndex + 1} de $totalQuestions',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Enunciado
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  currentQuestion.question.statement,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Opciones mezcladas
            Expanded(
              child: ListView.separated(
                itemCount: currentQuestion.shuffledOptions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final isSelected = _selectedIndex == index;

                  return InkWell(
                    onTap: () => _handleOptionSelected(index),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade300,
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index), // A, B, C, D
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              currentQuestion.shuffledOptions[index],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Botón Siguiente / Finalizar
            FilledButton(
              onPressed: _selectedIndex == null ? null : _nextQuestion,
              child: Text(
                _currentIndex == totalQuestions - 1 ? 'FINALIZAR QUIZ' : 'SIGUIENTE',
              ),
            ),
          ],
        ),
      ),
    );
  }
}