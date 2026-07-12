import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/page_header.dart';

class QuestionListScreen extends StatelessWidget {
  QuestionListScreen({super.key});

  final List<String> questions = const [
    "¿Cuánto es 5 + 8?",
    "¿Capital de Colombia?",
    "¿Quién descubrió América?",
    "¿Qué es Flutter?",
    "¿Cuál es el planeta rojo?",
  ];

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: "Preguntas",
      selectedIndex: 2,
      child: Column(
        children: [
          PageHeader(
            title: "Preguntas",
            subtitle: "Administra las preguntas del cuestionario.",
            action: FilledButton.icon(
              onPressed: () {
                context.go(AppRoutes.questionForm);
              },
              icon: const Icon(Icons.add),
              label: const Text("Nueva"),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView.separated(
              itemCount: questions.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, index) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Text("${index + 1}"),
                  ),
                  title: Text(questions[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      context.go(AppRoutes.questionForm);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}