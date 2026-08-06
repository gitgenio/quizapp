import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../data/models/enums/quiz_status.dart';
import '../../../data/models/participant.dart';
import '../../../data/repositories/participant_repository.dart';
import '../../../data/repositories/quiz_repository.dart';

class ParticipantService {
  final QuizRepository _quizRepository;
  final ParticipantRepository _participantRepository;

  ParticipantService({
    QuizRepository? quizRepository,
    ParticipantRepository? participantRepository,
  })  : _quizRepository = quizRepository ?? QuizRepository(),
        _participantRepository =
            participantRepository ?? ParticipantRepository();

  Future<Participant> joinQuiz({
    required String displayName,
    required String email,
    required String accessCode,
  }) async {
    final name = displayName.trim();
    final mail = email.trim().toLowerCase();
    final code = accessCode.trim().toUpperCase();

    if (name.isEmpty) {
      throw Exception('Debes ingresar tu nombre.');
    }

    if (mail.isEmpty) {
      throw Exception('Debes ingresar tu correo electrónico.');
    }

    if (!_isValidEmail(mail)) {
      throw Exception('El correo electrónico no es válido.');
    }

    if (code.isEmpty) {
      throw Exception('Debes ingresar el código del Quiz.');
    }

    final quiz =
    await _quizRepository.getQuizByAccessCode(code);

    if (quiz == null) {
      throw Exception('El código del Quiz no existe.');
    }

    if (quiz.status == QuizStatus.draft) {
      throw Exception(
        'El Quiz aún no está disponible.',
      );
    }

    if (quiz.status == QuizStatus.finished) {
      throw Exception(
        'El Quiz ya finalizó.',
      );
    }

    final participantToken =
    await _getParticipantToken();

    return _participantRepository.getOrCreate(
      participantToken: participantToken,
      quizId: quiz.id,
      displayName: name,
      email: mail,
    );
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(
      r'^[^@]+@[^@]+\.[^@]+$',
    );

    return regex.hasMatch(email);
  }

  Future<String> _getParticipantToken() async {
    // En la siguiente etapa este método leerá/escribirá
    // el token desde LocalStorage.

    return _generateToken();
  }

  String _generateToken() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    final random = Random.secure();

    return List.generate(
      36,
          (_) => chars[random.nextInt(chars.length)],
    ).join();
  }
}