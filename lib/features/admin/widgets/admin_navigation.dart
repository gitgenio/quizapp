import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';

class AdminNavigation extends StatelessWidget {
  final int selectedIndex;

  const AdminNavigation({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      labelType: NavigationRailLabelType.all,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go(AppRoutes.dashboard);
            break;
          case 1:
            context.go(AppRoutes.quizList);
            break;
          case 2:
            context.go(AppRoutes.questionList);
            break;
          case 3:
            context.go(AppRoutes.accessCode);
            break;
          case 4:
            context.go(AppRoutes.results);
            break;
        }
      },
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.quiz_outlined),
          selectedIcon: Icon(Icons.quiz),
          label: Text('Quizzes'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.help_outline),
          selectedIcon: Icon(Icons.help),
          label: Text('Preguntas'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.password_outlined),
          selectedIcon: Icon(Icons.password),
          label: Text('Código'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: Text('Resultados'),
        ),
      ],
    );
  }
}