import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'enums/quiz_status.dart';

/// Representa un cuestionario creado por un administrador.
class Quiz extends Equatable {
  /// Identificador único del Quiz.
  final String id;

  /// Título del Quiz.
  final String title;

  /// Descripción del Quiz.
  final String description;

  /// Usuario que creó el Quiz.
  final String createdBy;

  /// Estado actual del Quiz.
  final QuizStatus status;

  const Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.status,
  });

  /// Crea una copia del objeto modificando únicamente
  /// las propiedades indicadas.
  Quiz copyWith({
    String? id,
    String? title,
    String? description,
    String? createdBy,
    QuizStatus? status,
  }) {
    return Quiz(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
    );
  }

  /// Convierte el objeto en un Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_by': createdBy,
      'status': status.name,
    };
  }

  /// Crea un Quiz a partir de un Map.
  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      createdBy: map['created_by'] as String,
      status: QuizStatus.values.firstWhere(
            (value) => value.name == map['status'],
      ),
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
    description,
    createdBy,
    status,
  ];
}