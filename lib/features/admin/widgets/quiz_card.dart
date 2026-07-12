import 'package:flutter/material.dart';

import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/primary_button.dart';

class QuizCard extends StatelessWidget {

  final String title;
  final int questions;
  final bool active;

  final VoidCallback onEdit;
  final VoidCallback onQuestions;
  final VoidCallback onAccess;

  const QuizCard({
    super.key,
    required this.title,
    required this.questions,
    required this.active,
    required this.onEdit,
    required this.onQuestions,
    required this.onAccess,
  });

  @override
  Widget build(BuildContext context) {

    return AppCard(

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height:10),

          Text("$questions preguntas"),

          const SizedBox(height:12),

          Chip(

            label: Text(
              active
                  ? "Activo"
                  : "Borrador",
            ),
          ),

          const SizedBox(height:20),

          Wrap(

            spacing:12,

            runSpacing:12,

            children: [

              FilledButton.icon(

                onPressed: onEdit,

                icon: const Icon(Icons.edit),

                label: const Text("Editar"),
              ),

              OutlinedButton.icon(

                onPressed: onQuestions,

                icon: const Icon(Icons.help),

                label: const Text("Preguntas"),
              ),

              OutlinedButton.icon(

                onPressed: onAccess,

                icon: const Icon(Icons.password),

                label: const Text("Código"),
              ),
            ],
          )
        ],
      ),
    );
  }
}