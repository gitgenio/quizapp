import 'package:flutter/foundation.dart';

import '../../../data/models/participant.dart';
import '../services/participant_service.dart';

class ParticipantViewModel extends ChangeNotifier {
  final ParticipantService _participantService;

  ParticipantViewModel({
    ParticipantService? participantService,
  }) : _participantService =
      participantService ?? ParticipantService();

  Participant? _participant;

  Participant? get participant => _participant;

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

      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e);

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  /// Intenta recuperar una sesión existente.
  ///
  /// Devuelve el participante recuperado o null
  /// si no existe una sesión.
  Future<Participant?> restoreSession() async {
    if (_isLoading) {
      return _participant;
    }

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final participant =
      await _participantService.restoreSession();

      _participant = participant;

      return participant;
    } catch (e) {
      _errorMessage =
      'No fue posible recuperar la sesión.';

      return null;
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