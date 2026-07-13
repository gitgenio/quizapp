import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';

class FinishScreen extends StatelessWidget {
  const FinishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Finalizado",
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Icon(
                  Icons.emoji_events,
                  size: 90,
                ),

                const SizedBox(height: 20),

                Text(
                  "¡Has terminado!",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Gracias por participar en el cuestionario.",
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                PrimaryButton(
                  text: "Ver Resultados",
                  icon: Icons.bar_chart,
                  onPressed: (){
                    context.go(AppRoutes.results);
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