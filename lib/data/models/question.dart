import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'enums/answer_option.dart';
import 'enums/question_type.dart';

/// Representa una pregunta de un Quiz.
class Question extends Equatable {
  /// Identificador único.
  final String id;

  /// Quiz al que pertenece.
  final String quizId;

  /// Posición de la pregunta dentro del Quiz.
  final int order;

  /// Enunciado de la pregunta.
  final String statement;

  /// Opción A.
  final String optionA;

  /// Opción B.
  final String optionB;

  /// Opción C.
  final String optionC;

  /// Opción D.
  final String optionD;

  /// Respuesta correcta.
  final AnswerOption correctAnswer;

  /// Tipo de pregunta.
  final QuestionType type;

  const Question({
    required this.id,
    required this.quizId,
    required this.order,
    required this.statement,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    required this.type,
  });

  Question copyWith({
    String? id,
    String? quizId,
    int? order,
    String? statement,
    String? optionA,
    String? optionB,
    String? optionC,
    String? optionD,
    AnswerOption? correctAnswer,
    QuestionType? type,
  }) {
    return Question(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      order: order ?? this.order,
      statement: statement ?? this.statement,
      optionA: optionA ?? this.optionA,
      optionB: optionB ?? this.optionB,
      optionC: optionC ?? this.optionC,
      optionD: optionD ?? this.optionD,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quiz_id': quizId,
      'order': order,
      'statement': statement,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'correct_answer': correctAnswer.name,
      'type': type.name,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as String,
      quizId: map['quiz_id'] as String,
      order: map['order'] as int,
      statement: map['statement'] as String,
      optionA: map['option_a'] as String,
      optionB: map['option_b'] as String,
      optionC: map['option_c'] as String,
      optionD: map['option_d'] as String,
      correctAnswer: AnswerOption.values.firstWhere(
            (e) => e.name == map['correct_answer'],
      ),
      type: QuestionType.values.firstWhere(
            (e) => e.name == map['type'],
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Question.fromJson(String source) =>
      Question.fromMap(json.decode(source));

  @override
  List<Object> get props => [
    id,
    quizId,
    order,
    statement,
    optionA,
    optionB,
    optionC,
    optionD,
    correctAnswer,
    type,
  ];
}