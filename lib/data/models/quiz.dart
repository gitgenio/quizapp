import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'enums/quiz_status.dart';

/// Representa un cuestionario creado por un administrador.
class Quiz extends Equatable {
  /// Identificador único del Quiz.
  final String id;

  /// Título del Quiz.
  final String title;

  /// Usuario que creó el Quiz.
  final String createdBy;

  /// Estado actual del Quiz.
  final QuizStatus status;

  /// Código que utilizarán los participantes para ingresar.
  final String accessCode;

  /// Cantidad de preguntas que responderá cada participante.
  final int questionCount;

  /// Tiempo disponible para responder cada pregunta, en segundos.
  final int timePerQuestionSeconds;

  const Quiz({
    required this.id,
    required this.title,
    required this.createdBy,
    required this.status,
    required this.accessCode,
    required this.questionCount,
    required this.timePerQuestionSeconds,
  });

  /// Crea una copia del Quiz modificando únicamente
  /// las propiedades indicadas.
  Quiz copyWith({
    String? id,
    String? title,
    String? createdBy,
    QuizStatus? status,
    String? accessCode,
    int? questionCount,
    int? timePerQuestionSeconds,
  }) {
    return Quiz(
      id: id ?? this.id,
      title: title ?? this.title,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      accessCode: accessCode ?? this.accessCode,
      questionCount: questionCount ?? this.questionCount,
      timePerQuestionSeconds:
      timePerQuestionSeconds ?? this.timePerQuestionSeconds,
    );
  }

  /// Convierte el objeto en un Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'created_by': createdBy,
      'status': status.name,
      'access_code': accessCode,
      'question_count': questionCount,
      'time_per_question_seconds': timePerQuestionSeconds,
    };
  }

  /// Crea un Quiz a partir de un Map.
  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] as String,
      title: map['title'] as String,
      createdBy: map['created_by'] as String,
      status: QuizStatus.values.firstWhere(
            (value) => value.name == map['status'],
      ),
      accessCode: map['access_code'] as String,
      questionCount: map['question_count'] as int,
      timePerQuestionSeconds:
      map['time_per_question_seconds'] as int,
    );
  }

  /// Convierte el objeto a JSON.
  String toJson() => json.encode(toMap());

  /// Crea un Quiz a partir de un JSON.
  factory Quiz.fromJson(String source) =>
      Quiz.fromMap(json.decode(source));

  @override
  List<Object> get props => [
    id,
    title,
    createdBy,
    status,
    accessCode,
    questionCount,
    timePerQuestionSeconds,
  ];
}