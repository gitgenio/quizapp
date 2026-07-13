import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_title.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Estadísticas',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SectionTitle(
              title: 'Estadísticas',
              subtitle: 'Resumen del cuestionario',
            ),

            const SizedBox(height: 30),

            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [

                _StatCard(
                  title: 'Participantes',
                  value: '30',
                  icon: Icons.people,
                ),

                _StatCard(
                  title: 'Promedio',
                  value: '82%',
                  icon: Icons.school,
                ),

                _StatCard(
                  title: 'Mejor Puntaje',
                  value: '100%',
                  icon: Icons.emoji_events,
                ),

                _StatCard(
                  title: 'Preguntas',
                  value: '20',
                  icon: Icons.quiz,
                ),
              ],
            ),

            const SizedBox(height: 40),

            PrimaryButton(
              text: 'Volver al Dashboard',
              icon: Icons.home,
              onPressed: () {
                context.go(AppRoutes.dashboard);
              },
            )
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: AppCard(
        child: Column(
          children: [

            Icon(
              icon,
              size: 48,
            ),

            const SizedBox(height: 16),

            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 8),

            Text(title),
          ],
        ),
      ),
    );
  }
}