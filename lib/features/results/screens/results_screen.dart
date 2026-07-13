import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_title.dart';

class ResultsScreen extends StatelessWidget {
  ResultsScreen({super.key});

  final List<Map<String, dynamic>> results = const [
    {
      'name': 'Juan',
      'score': 90,
    },
    {
      'name': 'María',
      'score': 85,
    },
    {
      'name': 'Pedro',
      'score': 80,
    },
    {
      'name': 'Laura',
      'score': 75,
    },
    {
      'name': 'Carlos',
      'score': 70,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Resultados',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SectionTitle(
            title: 'Resultados',
            subtitle: 'Ranking de participantes',
          ),

          const SizedBox(height: 24),

          Expanded(
            child: ListView.separated(
              itemCount: results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {

                final result = results[index];

                return AppCard(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(result['name']),
                    trailing: Text(
                      '${result['score']}%',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          Align(
            alignment: Alignment.centerRight,
            child: PrimaryButton(
              text: 'Ver Estadísticas',
              icon: Icons.bar_chart,
              onPressed: () {
                context.go(AppRoutes.statistics);
              },
            ),
          )
        ],
      ),
    );
  }
}