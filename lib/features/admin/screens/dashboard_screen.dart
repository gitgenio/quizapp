import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/section_title.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/dashboard_option_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Dashboard',
      selectedIndex: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Bienvenido',
            subtitle: 'Selecciona una opción para administrar QuizApp.',
          ),

          const SizedBox(height: 32),

          Expanded(
            child: GridView.count(
              crossAxisCount:
              MediaQuery.of(context).size.width > 850 ? 2 : 1,

              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 2.1,
              children: [
                DashboardOptionCard(
                  icon: Icons.quiz_outlined,
                  title: 'Quizzes',
                  description:
                  'Crear y administrar cuestionarios.',
                  onPressed: () =>
                      context.go(AppRoutes.quizList),
                ),

                DashboardOptionCard(
                  icon: Icons.help_outline,
                  title: 'Preguntas',
                  description:
                  'Administrar banco de preguntas.',
                  onPressed: () =>
                      context.go(AppRoutes.questionList),
                ),

                DashboardOptionCard(
                  icon: Icons.password,
                  title: 'Código de Acceso',
                  description:
                  'Generar código para participantes.',
                  onPressed: () =>
                      context.go(AppRoutes.accessCode),
                ),

                DashboardOptionCard(
                  icon: Icons.bar_chart,
                  title: 'Resultados',
                  description:
                  'Consultar resultados y estadísticas.',
                  onPressed: () =>
                      context.go(AppRoutes.results),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}