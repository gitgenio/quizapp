import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'enums/answer_option.dart';

/// Representa la respuesta de un participante a una pregunta.
class Answer extends Equatable {
  /// Identificador único de la respuesta.
  final String id;

  /// Participante que respondió.
  final String participantId;

  /// Pregunta respondida.
  final String questionId;

  /// Opción seleccionada por el participante.
  final AnswerOption selectedOption;

  const Answer({
    required this.id,
    required this.participantId,
    required this.questionId,
    required this.selectedOption,
  });

  Answer copyWith({
    String? id,
    String? participantId,
    String? questionId,
    AnswerOption? selectedOption,
  }) {
    return Answer(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      questionId: questionId ?? this.questionId,
      selectedOption: selectedOption ?? this.selectedOption,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participantId': participantId,
      'questionId': questionId,
      'selectedOption': selectedOption.name,
    };
  }

  factory Answer.fromMap(Map<String, dynamic> map) {
    return Answer(
      id: map['id'] as String,
      participantId: map['participantId'] as String,
      questionId: map['questionId'] as String,
      selectedOption: AnswerOption.values.firstWhere(
            (value) => value.name == map['selectedOption'],
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Answer.fromJson(String source) =>
      Answer.fromMap(json.decode(source));

  @override
  List<Object> get props => [
    id,
    participantId,
    questionId,
    selectedOption,
  ];
}