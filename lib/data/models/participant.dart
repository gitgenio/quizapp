import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'enums/participant_status.dart';

/// Representa la participación de un usuario en un Quiz.
class Participant extends Equatable {
  /// Identificador único de la participación.
  final String id;

  /// Usuario participante.
  final String userId;

  /// Quiz al que pertenece.
  final String quizId;

  /// Nombre que se mostrará durante el Quiz.
  final String displayName;

  /// Estado actual del participante.
  final ParticipantStatus status;

  const Participant({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.displayName,
    required this.status,
  });

  Participant copyWith({
    String? id,
    String? userId,
    String? quizId,
    String? displayName,
    ParticipantStatus? status,
  }) {
    return Participant(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      quizId: quizId ?? this.quizId,
      displayName: displayName ?? this.displayName,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'quizId': quizId,
      'displayName': displayName,
      'status': status.name,
    };
  }

  factory Participant.fromMap(Map<String, dynamic> map) {
    return Participant(
      id: map['id'] as String,
      userId: map['userId'] as String,
      quizId: map['quizId'] as String,
      displayName: map['displayName'] as String,
      status: ParticipantStatus.values.firstWhere(
            (value) => value.name == map['status'],
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Participant.fromJson(String source) =>
      Participant.fromMap(json.decode(source));

  @override
  List<Object> get props => [
    id,
    userId,
    quizId,
    displayName,
    status,
  ];
}