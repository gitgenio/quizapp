import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/dashboard_option_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
      icon: Icons.quiz_outlined,
      title: 'Quizzes',
      description: 'Crear y administrar cuestionarios.',
      route: AppRoutes.quizList,
      ),
      (
      icon: Icons.help_outline,
      title: 'Preguntas',
      description: 'Administrar banco de preguntas.',
      route: AppRoutes.questionList,
      ),
      (
      icon: Icons.password_outlined,
      title: 'Código de Acceso',
      description: 'Generar y compartir códigos.',
      route: AppRoutes.accessCode,
      ),
      (
      icon: Icons.bar_chart_outlined,
      title: 'Resultados',
      description: 'Consultar resultados y estadísticas.',
      route: AppRoutes.results,
      ),
    ];

    final columns = Responsive.dashboardColumns(context);

    return AdminScaffold(
      title: 'Dashboard',
      selectedIndex: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenido',
            style: Theme.of(context).textTheme.headlineMedium,
          ),

          const SizedBox(height: 8),

          Text(
            'Selecciona una opción para administrar QuizApp.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          const SizedBox(height: 24),

          Expanded(
            child: GridView.builder(
              itemCount: cards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,

                // Muy importante para evitar overflows
                childAspectRatio:
                Responsive.isMobile(context) ? 1.05 : 1.18,
              ),
              itemBuilder: (context, index) {
                final card = cards[index];

                return DashboardOptionCard(
                  icon: card.icon,
                  title: card.title,
                  description: card.description,
                  onPressed: () {
                    context.go(card.route);
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