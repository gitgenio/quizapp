import 'package:flutter/foundation.dart';

import '../../../data/models/participant.dart';
import '../../../data/models/quiz.dart';
import '../services/participant_service.dart';

class ParticipantViewModel extends ChangeNotifier {
  final ParticipantService _participantService;

  ParticipantViewModel({
    ParticipantService? participantService,
  }) : _participantService =
      participantService ?? ParticipantService();

  Participant? _participant;

  Participant? get participant => _participant;

  Quiz? _quiz;

  Quiz? get quiz => _quiz;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  /// Ingresa al Quiz y registra al participante.
  Future<bool> joinQuiz({
    required String displayName,
    required String email,
    required String accessCode,
  }) async {
    if (_isLoading) {
      return false;
    }

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final participant =
      await _participantService.joinQuiz(
        displayName: displayName,
        email: email,
        accessCode: accessCode,
      );

      _participant = participant;

      _quiz =
      await _participantService.getQuizForParticipant(
        participant,
      );

      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e);

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  /// Recupera la sesión existente después
  /// de recargar el navegador.
  Future<bool> restoreSession() async {
    if (_isLoading) {
      return _participant != null;
    }

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final participant =
      await _participantService.restoreSession();

      if (participant == null) {
        _participant = null;
        _quiz = null;

        return false;
      }

      final quiz =
      await _participantService.getQuizForParticipant(
        participant,
      );

      _participant = participant;
      _quiz = quiz;

      return true;
    } catch (e) {
      _participant = null;
      _quiz = null;

      _errorMessage =
      'No fue posible recuperar la sesión.';

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearParticipant() {
    _participant = null;
    _quiz = null;

    notifyListeners();
  }

  String _cleanErrorMessage(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }

    return message;
  }
}