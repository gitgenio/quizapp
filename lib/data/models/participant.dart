import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'enums/participant_status.dart';

/// Representa un participante de un Quiz.
class Participant extends Equatable {
  /// Identificador único.
  final String id;

  /// Identificador único almacenado en el navegador.
  final String participantToken;

  /// Quiz al que pertenece.
  final String quizId;

  /// Nombre que se mostrará durante el Quiz.
  final String displayName;

  /// Correo electrónico del participante.
  final String email;

  /// Estado actual del participante.
  final ParticipantStatus status;

  /// Fecha de ingreso al Quiz.
  final DateTime createdAt;

  const Participant({
    required this.id,
    required this.participantToken,
    required this.quizId,
    required this.displayName,
    required this.email,
    required this.status,
    required this.createdAt,
  });

  Participant copyWith({
    String? id,
    String? participantToken,
    String? quizId,
    String? displayName,
    String? email,
    ParticipantStatus? status,
    DateTime? createdAt,
  }) {
    return Participant(
      id: id ?? this.id,
      participantToken: participantToken ?? this.participantToken,
      quizId: quizId ?? this.quizId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participant_token': participantToken,
      'quiz_id': quizId,
      'display_name': displayName,
      'email': email,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Participant.fromMap(Map<String, dynamic> map) {
    return Participant(
      id: map['id'] as String,
      participantToken: map['participant_token'] as String,
      quizId: map['quiz_id'] as String,
      displayName: map['display_name'] as String,
      email: map['email'] as String,
      status: ParticipantStatus.values.firstWhere(
            (value) => value.name == map['status'],
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory Participant.fromJson(String source) =>
      Participant.fromMap(json.decode(source));

  @override
  List<Object> get props => [
    id,
    participantToken,
    quizId,
    displayName,
    email,
    status,
    createdAt,
  ];
}