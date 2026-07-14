import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/page_header.dart';
import '../widgets/quiz_card.dart';

class QuizListScreen extends StatelessWidget {
  QuizListScreen({super.key});

  final List<Map<String, dynamic>> quizzes = const [
    {
      "title": "Matemáticas",
      "questions": 20,
      "active": true,
    },
    {
      "title": "Historia",
      "questions": 15,
      "active": true,
    },
    {
      "title": "Biología",
      "questions": 30,
      "active": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Quizzes',
      selectedIndex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Quizzes',
            subtitle: 'Administra todos tus cuestionarios.',
            action: FilledButton.icon(
              onPressed: () {
                context.push(AppRoutes.quizForm);
              },
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Quiz'),
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: ListView.separated(
              itemCount: quizzes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final quiz = quizzes[index];

                return QuizCard(
                  title: quiz["title"],
                  questions: quiz["questions"],
                  active: quiz["active"],
                  onEdit: () {
                    context.push(AppRoutes.quizForm);
                  },
                  onQuestions: () {
                    context.push(AppRoutes.questionList);
                  },
                  onAccess: () {
                    context.push(AppRoutes.accessCode);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}