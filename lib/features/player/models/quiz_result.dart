import 'dart:convert';
import 'package:equatable/equatable.dart';

class QuizResult extends Equatable {
  final String participantId;
  final String displayName;
  final String email; // <-- 1. AGREGADO
  final int correctAnswers;
  final int incorrectAnswers;
  final int totalQuestions;
  final double score;
  final DateTime createdAt;

  const QuizResult({
    required this.participantId,
    required this.displayName,
    required this.email, // <-- 2. AGREGADO
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.totalQuestions,
    required this.score,
    required this.createdAt,
  });

  QuizResult copyWith({
    String? participantId,
    String? displayName,
    String? email, // <-- 3. AGREGADO
    int? correctAnswers,
    int? incorrectAnswers,
    int? totalQuestions,
    double? score,
    DateTime? createdAt,
  }) {
    return QuizResult(
      participantId: participantId ?? this.participantId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email, // <-- 4. AGREGADO
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
      'email': email, // <-- 5. AGREGADO
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
      email: map['email'] as String? ?? 'No disponible', // <-- 6. AGREGADO (con fallback seguro)
      correctAnswers: map['correct_answers'] as int,
      incorrectAnswers: map['incorrect_answers'] as int,
      totalQuestions: map['total_questions'] as int,
      score: (map['score'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory QuizResult.fromJson(String source) => QuizResult.fromMap(json.decode(source));

  @override
  List<Object?> get props => [
    participantId,
    displayName,
    email, // <-- 7. AGREGADO
    correctAnswers,
    incorrectAnswers,
    totalQuestions,
    score,
    createdAt,
  ];

  double get percentage => totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;
}