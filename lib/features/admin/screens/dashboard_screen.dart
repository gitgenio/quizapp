import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive.dart';
import '../../auth/controllers/auth_controller.dart';
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

    // Solo el SuperAdmin puede crear profesores.
    if (authController.isSuperAdmin) {
      cards.add(
        (
        icon: Icons.person_add_outlined,
        title: 'Crear profesor',
        description:
        'Registrar un nuevo profesor en QuizApp.',
        route: AppRoutes.createAdministrator,
        ),
      );
    }

    final screenWidth =
        MediaQuery.of(context).size.width;

    double cardWidth;

    if (Responsive.isDesktop(context)) {
      // Dos tarjetas por fila.
      cardWidth = (screenWidth - 380) / 2;
    } else if (Responsive.isTablet(context)) {
      cardWidth = (screenWidth - 160) / 2;
    } else {
      cardWidth = double.infinity;
    }

    return AdminScaffold(
      title: 'Dashboard',
      selectedIndex: 0,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium,
            ),

            const SizedBox(height: 8),

            Text(
              'Selecciona una opción para administrar QuizApp.',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge,
            ),

            const SizedBox(height: 28),

            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: cards.map((card) {
                return SizedBox(
                  width: cardWidth,
                  child: DashboardOptionCard(
                    icon: card.icon,
                    title: card.title,
                    description: card.description,
                    onPressed: () {
                      context.push(card.route);
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}