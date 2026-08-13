import 'package:flutter/foundation.dart';

import '../services/realtime_service.dart';

class WaitingRoomViewModel extends ChangeNotifier {
  final RealtimeService _realtimeService;

  WaitingRoomViewModel({
    RealtimeService? realtimeService,
  }) : _realtimeService =
      realtimeService ?? RealtimeService();

  bool _isListening = false;

  bool get isListening => _isListening;

  bool _quizStarted = false;

  bool get quizStarted => _quizStarted;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  /// Comienza a escuchar los cambios de estado del Quiz.
  void startListening({
    required String quizId,
  }) {
    if (_isListening) {
      return;
    }

    _isListening = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _realtimeService.listenToQuiz(
        quizId: quizId,
        onStatusChanged: _handleQuizStatusChanged,
      );
    } catch (e) {
      _isListening = false;
      _errorMessage =
      'No fue posible conectarse a la sala de espera.';

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