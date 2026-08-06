import 'package:flutter/material.dart';
import '../../../services/participant_service.dart';
import '../../../data/models/participant.dart';

class ParticipantViewModel extends ChangeNotifier {
  final ParticipantService _participantService;

  ParticipantViewModel({
    ParticipantService? participantService,
  }) : _participantService =
      participantService ?? ParticipantService();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Participant? _participant;

  Participant? get participant => _participant;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  Future<bool> joinQuiz({
    required String displayName,
    required String email,
    required String accessCode,
  }) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _participant = await _participantService.joinQuiz(
        displayName: displayName,
        email: email,
        accessCode: accessCode,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst(
        'Exception: ',
        '',
      );

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

  void reset() {
    _participant = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}