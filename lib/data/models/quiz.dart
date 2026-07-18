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

  const Quiz({
    required this.id,
    required this.title,
    required this.createdBy,
    required this.status,
    required this.accessCode,
  });

  /// Crea una copia del objeto modificando únicamente
  /// las propiedades indicadas.
  Quiz copyWith({
    String? id,
    String? title,
    String? createdBy,
    QuizStatus? status,
    String? accessCode,
  }) {
    return Quiz(
      id: id ?? this.id,
      title: title ?? this.title,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      accessCode: accessCode ?? this.accessCode,
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
  ];
}