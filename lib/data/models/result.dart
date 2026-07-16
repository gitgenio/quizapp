import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Representa el resultado final de un participante en un Quiz.
class Result extends Equatable {
  /// Identificador único del resultado.
  final String id;

  /// Participante al que pertenece el resultado.
  final String participantId;

  /// Quiz al que pertenece el resultado.
  final String quizId;

  /// Cantidad de respuestas correctas.
  final int correctAnswers;

  /// Puntaje obtenido.
  final int score;

  const Result({
    required this.id,
    required this.participantId,
    required this.quizId,
    required this.correctAnswers,
    required this.score,
  });

  Result copyWith({
    String? id,
    String? participantId,
    String? quizId,
    int? correctAnswers,
    int? score,
  }) {
    return Result(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      quizId: quizId ?? this.quizId,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      score: score ?? this.score,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participant_id': participantId,
      'quiz_id': quizId,
      'correct_answers': correctAnswers,
      'score': score,
    };
  }

  factory Result.fromMap(Map<String, dynamic> map) {
    return Result(
      id: map['id'] as String,
      participantId: map['participant_id'] as String,
      quizId: map['quiz_id'] as String,
      correctAnswers: map['correct_answers'] as int,
      score: map['score'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Result.fromJson(String source) =>
      Result.fromMap(json.decode(source));

  @override
  List<Object> get props => [
    id,
    participantId,
    quizId,
    correctAnswers,
    score,
  ];
}