import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/enums/answer_option.dart';
import '../../../data/repositories/answer_repository.dart';

import '../../player/models/prepared_question.dart';
import '../../player/models/quiz_session_data.dart';

class QuizScreen extends StatefulWidget {
  final QuizSessionData sessionData;

  const QuizScreen({
    super.key,
    required this.sessionData,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final AnswerRepository _answerRepository = AnswerRepository();

  QuizSessionData? _sessionData;
  int _currentIndex = 0;
  int? _selectedIndex;

  late int _timeLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sessionData = widget.sessionData;
    // <-- CORRECCIÓN: Usar el tiempo configurado en el quiz
    _timeLeft = widget.sessionData.timePerQuestionSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      // <-- CORRECCIÓN: Reiniciar con el tiempo configurado
      _timeLeft = widget.sessionData!.timePerQuestionSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _handleTimeUp();
      }
    });
  }

  void _handleOptionSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _nextQuestion() async {
    if (_selectedIndex == null) return;

    await _saveCurrentAnswer();

    if (_currentIndex < _sessionData!.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
      });

      _startTimer();
    } else {
      _timer?.cancel();
      context.go(AppRoutes.finish);
    }
  }

  Future<void> _handleTimeUp() async {
    _timer?.cancel();

    if (_currentIndex < _sessionData!.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
      });

      _startTimer();
    } else {
      context.go(AppRoutes.finish);
    }
  }

  Future<void> _saveCurrentAnswer() async {
    if (_selectedIndex == null) return;

    try {
      final currentQuestion = _sessionData!.questions[_currentIndex];
      final selectedText = currentQuestion.shuffledOptions[_selectedIndex!];

      final originalOption = _getOriginalOption(
        currentQuestion,
        selectedText,
      );

      await _answerRepository.saveAnswer(
        participantId: _sessionData!.participantId,
        questionId: currentQuestion.question.id,
        selectedOption: originalOption,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar respuesta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  AnswerOption _getOriginalOption(
      PreparedQuestion preparedQuestion,
      String selectedText,
      ) {
    final question = preparedQuestion.question;

    if (selectedText == question.optionA) {
      return AnswerOption.A;
    } else if (selectedText == question.optionB) {
      return AnswerOption.B;
    } else if (selectedText == question.optionC) {
      return AnswerOption.C;
    } else if (selectedText == question.optionD) {
      return AnswerOption.D;
    }

    throw Exception('Opción no válida');
  }

  @override
  Widget build(BuildContext context) {
    if (_sessionData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = _sessionData!.questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Pregunta ${_currentIndex + 1} de ${_sessionData!.questions.length}'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '$_timeLeft s',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      currentQuestion.question.statement,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              currentQuestion.shuffledOptions.length,
                  (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton(
                  onPressed: () => _handleOptionSelected(index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    foregroundColor: _selectedIndex == index
                        ? Theme.of(context).colorScheme.onPrimary
                        : null,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    currentQuestion.shuffledOptions[index],
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _selectedIndex != null ? _nextQuestion : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _currentIndex < _sessionData!.questions.length - 1
                    ? 'SIGUIENTE'
                    : 'FINALIZAR',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}