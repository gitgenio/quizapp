import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/enums/answer_option.dart';
import '../../../data/repositories/answer_repository.dart';
import '../../../data/repositories/participant_repository.dart';
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
  final ParticipantRepository _participantRepository = ParticipantRepository();

  QuizSessionData? _sessionData;
  int _currentIndex = 0;
  int? _selectedIndex;

  late int _timeLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sessionData = widget.sessionData;
    _timeLeft = widget.sessionData.timePerQuestionSeconds;
    print('========== QUIZ SCREEN INIT ==========');
    print('Participant ID: ${widget.sessionData.participantId}');
    print('Time per question: ${widget.sessionData.timePerQuestionSeconds}');
    print('Total questions: ${widget.sessionData.questions.length}');
    _markParticipantPlaying();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// NUEVO: marca al participante como 'playing' al entrar al quiz.
  Future<void> _markParticipantPlaying() async {
    try {
      await _participantRepository.updateStatus(
        participantId: widget.sessionData.participantId,
        status: 'playing',
      );
    } catch (e) {
      print('No se pudo marcar playing: $e');
    }
  }

  /// NUEVO: marca al participante como 'finished' al terminar,
  /// ya sea respondiendo la última pregunta o por tiempo agotado.
  Future<void> _markParticipantFinished() async {
    try {
      await _participantRepository.updateStatus(
        participantId: _sessionData!.participantId,
        status: 'finished',
      );
    } catch (e) {
      print('No se pudo marcar finished: $e');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
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
    print('Opción seleccionada: índice $index');
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _nextQuestion() async {
    print('========== _nextQuestion llamado ==========');
    print('_selectedIndex: $_selectedIndex');

    if (_selectedIndex == null) {
      print('ERROR: _selectedIndex es null, retornando');
      return;
    }

    print('Llamando a _saveCurrentAnswer...');
    await _saveCurrentAnswer();
    print('_saveCurrentAnswer completado');

    if (_currentIndex < _sessionData!.questions.length - 1) {
      print('Avanzando a siguiente pregunta');
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
      });
      _startTimer();
    } else {
      print('Última pregunta, navegando a finish');
      await _markParticipantFinished();
      _timer?.cancel();
      context.go(AppRoutes.finish);
    }
  }

  Future<void> _handleTimeUp() async {
    print('========== TIEMPO AGOTADO ==========');
    _timer?.cancel();

    if (_currentIndex < _sessionData!.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
      });
      _startTimer();
    } else {
      // Terminó por timeout: también se marca como finished.
      await _markParticipantFinished();
      context.go(AppRoutes.finish);
    }
  }

  Future<void> _saveCurrentAnswer() async {
    if (_selectedIndex == null) {
      print('No hay respuesta seleccionada, no se guarda');
      return;
    }

    try {
      print('========== GUARDANDO RESPUESTA ==========');
      final currentQuestion = _sessionData!.questions[_currentIndex];
      final selectedText = currentQuestion.shuffledOptions[_selectedIndex!];

      print('Question ID: ${currentQuestion.question.id}');
      print('Participant ID: ${_sessionData!.participantId}');
      print('Texto seleccionado: $selectedText');

      final originalOption = _getOriginalOption(
        currentQuestion,
        selectedText,
      );

      print('Opción original: ${originalOption.name}');

      print('Llamando a AnswerRepository.saveAnswer...');
      await _answerRepository.saveAnswer(
        participantId: _sessionData!.participantId,
        questionId: currentQuestion.question.id,
        selectedOption: originalOption,
      );
      print('✓ Respuesta guardada exitosamente en Supabase');

    } catch (e, stackTrace) {
      print('✗ ERROR al guardar respuesta: $e');
      print('Stack trace: $stackTrace');
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


    throw Exception('Opción no válida: $selectedText');
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