import 'package:flutter/foundation.dart';

import '../services/realtime_service.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../data/models/enums/quiz_status.dart';

class WaitingRoomViewModel extends ChangeNotifier {
  final RealtimeService _realtimeService;
  final QuizRepository _quizRepository;

  WaitingRoomViewModel({
    RealtimeService? realtimeService,
    QuizRepository? quizRepository,
  })  : _realtimeService = realtimeService ?? RealtimeService(),
        _quizRepository = quizRepository ?? QuizRepository();

  bool _isListening = false;
  bool get isListening => _isListening;

  bool _quizStarted = false;
  bool get quizStarted => _quizStarted;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Comienza a escuchar los cambios de estado del Quiz.
  Future<void> startListening({
    required String quizId,
  }) async {
    if (_isListening) {
      return;
    }

    _isListening = true;
    _errorMessage = null;

    notifyListeners();

    try {
      // 1. Verificación inicial de seguridad: ¿El quiz ya inició o existe?
      final currentQuiz = await _quizRepository.getQuizById(quizId);

      // CORRECCIÓN: Manejar el caso null
      if (currentQuiz == null) {
        _isListening = false;
        _errorMessage = 'El Quiz no existe o ya no está disponible.';
        notifyListeners();
        return;
      }

      if (currentQuiz.status == QuizStatus.started) {
        _quizStarted = true;
        notifyListeners();
        return;
      }

      // 2. Escuchar cambios en tiempo real
      _realtimeService.listenToQuiz(
        quizId: quizId,
        onStatusChanged: _handleQuizStatusChanged,
      );
    } catch (e) {
      _isListening = false;
      _errorMessage = 'No fue posible conectarse a la sala de espera.';
      notifyListeners();
    }
  }

  void _handleQuizStatusChanged(String status) {
    if (status == 'started') {
      _quizStarted = true;
      notifyListeners();
      return;
    }

    if (status == 'finished') {
      _errorMessage = 'El Quiz ha finalizado.';
      notifyListeners();
    }
  }

  /// Detiene la escucha de Realtime.
  Future<void> stopListening() async {
    if (!_isListening) {
      return;
    }

    await _realtimeService.unsubscribeFromQuiz();
    _isListening = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _realtimeService.dispose();
    super.dispose();
  }
}