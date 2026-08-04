import 'package:flutter/material.dart';

import '../../../data/models/import_validation_result.dart';
import '../../../data/models/parsed_question.dart';

class ImportPreviewScreen extends StatelessWidget {
  final String quizId;
  final String fileName;
  final int requiredQuestionCount;
  final ImportValidationResult validationResult;

  const ImportPreviewScreen({
    super.key,
    required this.quizId,
    required this.fileName,
    required this.requiredQuestionCount,
    required this.validationResult,
  });

  @override
  Widget build(BuildContext context) {
    final questions = validationResult.questions;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vista previa de preguntas',
        ),
      ),
      body: Column(
        children: [
          // LISTA DE PREGUNTAS
          Expanded(
            child: questions.isEmpty
                ? const Center(
              child: Text(
                'No hay preguntas para mostrar.',
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: questions.length,
              separatorBuilder: (context, index) =>
              const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final question = questions[index];
                return _QuestionPreviewCard(
                  question: question,
                  index: index,
                );
              },
            ),
          ),

          // BARRA INFERIOR
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(0.08),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                ),
                onPressed: () {
                  // Próximo paso: guardar en Supabase
                },
                icon: const Icon(Icons.upload),
                label: const Text('Confirmar importación'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionPreviewCard extends StatelessWidget {
  final ParsedQuestion question;
  final int index;

  const _QuestionPreviewCard({
    required this.question,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pregunta ${index + 1}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              question.statement,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            _buildOption(context, 'A', question.optionA, question.correctAnswer),
            _buildOption(context, 'B', question.optionB, question.correctAnswer),
            _buildOption(context, 'C', question.optionC, question.correctAnswer),
            _buildOption(context, 'D', question.optionD, question.correctAnswer),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
      BuildContext context,
      String letter,
      String text,
      String correctAnswer,
      ) {
    final isCorrect = letter.toUpperCase() == correctAnswer.trim().toUpperCase();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect ? Colors.green : Theme.of(context).dividerColor,
        ),
        color: isCorrect ? Colors.green.withOpacity(0.08) : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            child: Text(letter),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
          if (isCorrect)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
        ],
      ),
    );
  }
}