import 'dart:convert';
import 'package:equatable/equatable.dart';

/// Representa el resultado consolidado de un participante en un Quiz.
class QuizResult extends Equatable {
  /// Identificador del participante.
  final String participantId;

  /// Nombre del participante.
  final String displayName;

  /// Cantidad de respuestas correctas.
  final int correctAnswers;

  /// Cantidad de respuestas incorrectas.
  final int incorrectAnswers;

  /// Total de preguntas del quiz.
  final int totalQuestions;

  /// Puntaje porcentual (0-100).
  final double score;

  /// Fecha de participación.
  final DateTime createdAt;

  const QuizResult({
    required this.participantId,
    required this.displayName,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.totalQuestions,
    required this.score,
    required this.createdAt,
  });

  QuizResult copyWith({
    String? participantId,
    String? displayName,
    int? correctAnswers,
    int? incorrectAnswers,
    int? totalQuestions,
    double? score,
    DateTime? createdAt,
  }) {
    return QuizResult(
      participantId: participantId ?? this.participantId,
      displayName: displayName ?? this.displayName,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      score: score ?? this.score,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participant_id': participantId,
      'display_name': displayName,
      'correct_answers': correctAnswers,
      'incorrect_answers': incorrectAnswers,
      'total_questions': totalQuestions,
      'score': score,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      participantId: map['participant_id'] as String,
      displayName: map['display_name'] as String,
      correctAnswers: map['correct_answers'] as int,
      incorrectAnswers: map['incorrect_answers'] as int,
      totalQuestions: map['total_questions'] as int,
      score: (map['score'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory QuizResult.fromJson(String source) =>
      QuizResult.fromMap(json.decode(source));

  @override
  List<Object?> get props => [
    participantId,
    displayName,
    correctAnswers,
    incorrectAnswers,
    totalQuestions,
    score,
    createdAt,
  ];

  /// Calcula el porcentaje de respuestas correctas.
  double get percentage => totalQuestions > 0
      ? (correctAnswers / totalQuestions) * 100
      : 0.0;
}