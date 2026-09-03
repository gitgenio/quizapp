import 'dart:math';
import '../../../data/models/question.dart';

class PreparedQuestion {
  final Question question;
  final List<String> shuffledOptions;
  final int correctOptionIndex; // 0, 1, 2 o 3

  PreparedQuestion({
    required this.question,
    required this.shuffledOptions,
    required this.correctOptionIndex,
  });
}

/// Mezcla las preguntas y sus opciones, pero mantiene la referencia de cuál es la correcta.
List<PreparedQuestion> prepareQuestionsForParticipant(List<Question> questions) {
  final random = Random();

  // 1. Mezclar el orden de las preguntas
  final shuffledQuestions = List<Question>.from(questions)..shuffle(random);

  return shuffledQuestions.map((q) {
    // 2. Empaquetar opciones con su letra original para no perder la referencia
    final options = [
      {'letter': 'A', 'text': q.optionA},
      {'letter': 'B', 'text': q.optionB},
      {'letter': 'C', 'text': q.optionC},
      {'letter': 'D', 'text': q.optionD},
    ];

    // 3. Mezclar las opciones
    options.shuffle(random);

    // 4. Extraer solo los textos en el nuevo orden
    final shuffledOptions = options.map((o) => o['text'] as String).toList();

    // 5. Encontrar el nuevo índice (0-3) de la respuesta correcta
    final correctLetter = q.correctAnswer.name; // 'A', 'B', 'C' o 'D'
    int correctIndex = 0;
    for (int i = 0; i < options.length; i++) {
      if (options[i]['letter'] == correctLetter) {
        correctIndex = i;
        break;
      }
    }

    return PreparedQuestion(
      question: q,
      shuffledOptions: shuffledOptions,
      correctOptionIndex: correctIndex,
    );
  }).toList();
}