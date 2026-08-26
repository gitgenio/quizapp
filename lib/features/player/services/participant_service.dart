import '../../../data/models/enums/quiz_status.dart';
import '../../../data/models/participant.dart';
import '../../../data/models/quiz.dart';
import '../../../data/repositories/participant_repository.dart';
import '../../../data/repositories/quiz_repository.dart';
import 'participant_token_service.dart';

class ParticipantService {
  final QuizRepository _quizRepository;
  final ParticipantRepository _participantRepository;
  final ParticipantTokenService _tokenService;

  ParticipantService({
    QuizRepository? quizRepository,
    ParticipantRepository? participantRepository,
    ParticipantTokenService? tokenService,
  })  : _quizRepository =
      quizRepository ?? QuizRepository(),
        _participantRepository =
            participantRepository ?? ParticipantRepository(),
        _tokenService =
            tokenService ?? ParticipantTokenService();

  Future<Participant> joinQuiz({
    required String displayName,
    required String email,
    required String accessCode,
  }) async {
    final name = displayName.trim();
    final mail = email.trim().toLowerCase();
    final code = accessCode.trim().toUpperCase();

    if (name.isEmpty) {
      throw Exception(
        'Debes ingresar tu nombre.',
      );
    }

    if (mail.isEmpty) {
      throw Exception(
        'Debes ingresar tu correo electrónico.',
      );
    }

    if (!_isValidEmail(mail)) {
      throw Exception(
        'El correo electrónico no es válido.',
      );
    }

    if (code.isEmpty) {
      throw Exception(
        'Debes ingresar el código del Quiz.',
      );
    }

    final quiz =
    await _quizRepository.getQuizByAccessCode(code);

    if (quiz == null) {
      throw Exception(
        'El código del Quiz no existe.',
      );
    }

    switch (quiz.status) {
      case QuizStatus.draft:
        throw Exception(
          'El Quiz aún no está disponible.',
        );

      case QuizStatus.started:
        throw Exception(
          'El Quiz ya comenzó. No es posible ingresar.',
        );

      case QuizStatus.finished:
        throw Exception(
          'El Quiz ya finalizó.',
        );

      case QuizStatus.waiting:
        break;
    }

    final participantToken =
    await _tokenService.getToken();

    return _participantRepository.getOrCreate(
      participantToken: participantToken,
      quizId: quiz.id,
      displayName: name,
      email: mail,
    );
  }

  /// Recupera el participante asociado al token
  /// guardado en el navegador.
  ///
  /// No genera un nuevo token.
  Future<Participant?> restoreSession() async {
    final token =
    await _tokenService.getExistingToken();

    if (token == null) {
      return null;
    }

    return _participantRepository.getByToken(
      participantToken: token,
    );
  }

  /// Recupera el Quiz al que pertenece el participante.
  Future<Quiz> getQuizForParticipant(Participant participant) async {
    final quiz = await _quizRepository.getQuizById(participant.quizId);

    if (quiz == null) {
      throw Exception('No se encontró el Quiz.');
    }

    return quiz;
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(
      r'^[^@]+@[^@]+\.[^@]+$',
    );

    return regex.hasMatch(email);
  }
}