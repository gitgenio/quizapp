import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Representa el código de acceso de un Quiz.
class AccessCode extends Equatable {
  /// Identificador único del código.
  final String id;

  /// Código que el participante ingresará.
  final String code;

  /// Identificador del Quiz al que pertenece.
  final String quizId;

  const AccessCode({
    required this.id,
    required this.code,
    required this.quizId,
  });

  /// Crea una copia del objeto reemplazando
  /// únicamente las propiedades indicadas.
  AccessCode copyWith({
    String? id,
    String? code,
    String? quizId,
  }) {
    return AccessCode(
      id: id ?? this.id,
      code: code ?? this.code,
      quizId: quizId ?? this.quizId,
    );
  }

  /// Convierte el objeto en un Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'quiz_id': quizId,
    };
  }

  /// Crea un AccessCode a partir de un Map.
  factory AccessCode.fromMap(Map<String, dynamic> map) {
    return AccessCode(
      id: map['id'] as String,
      code: map['code'] as String,
      quizId: map['quiz_id'] as String,
    );
  }

  /// Convierte el objeto a formato JSON.
  String toJson() => json.encode(toMap());

  /// Crea un AccessCode a partir de un JSON.
  factory AccessCode.fromJson(String source) =>
      AccessCode.fromMap(json.decode(source));

  @override
  List<Object> get props => [
    id,
    code,
    quizId,
  ];
}