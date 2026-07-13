import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {

  String? answer;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Quiz",
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "Pregunta 1 de 10",
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 20),

                Text(
                  "¿Cuál es la capital de Colombia?",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 30),

                RadioListTile(
                  value: "A",
                  groupValue: answer,
                  title: const Text("Bogotá"),
                  onChanged: (value){
                    setState(() {
                      answer=value;
                    });
                  },
                ),

                RadioListTile(
                  value: "B",
                  groupValue: answer,
                  title: const Text("Quito"),
                  onChanged: (value){
                    setState(() {
                      answer=value;
                    });
                  },
                ),

                RadioListTile(
                  value: "C",
                  groupValue: answer,
                  title: const Text("Lima"),
                  onChanged: (value){
                    setState(() {
                      answer=value;
                    });
                  },
                ),

                RadioListTile(
                  value: "D",
                  groupValue: answer,
                  title: const Text("Caracas"),
                  onChanged: (value){
                    setState(() {
                      answer=value;
                    });
                  },
                ),

                const SizedBox(height: 30),

                PrimaryButton(
                  text: "Finalizar (Demo)",
                  icon: Icons.arrow_forward,
                  onPressed: (){
                    context.go(AppRoutes.finish);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}