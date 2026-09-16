import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive.dart';
import 'admin_navigation.dart';

class AdminScaffold extends StatelessWidget {
  final String title;
  final int selectedIndex;
  final Widget child;

  const AdminScaffold({
    super.key,
    required this.title,
    required this.selectedIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Inicio',
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go(AppRoutes.home),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => context.go(AppRoutes.login),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: isDesktop ? null : const Drawer(
        child: SafeArea(
          child: _DrawerMenu(),
        ),
      ),
      body: Row(
        children: [
          if (isDesktop)
            AdminNavigation(selectedIndex: selectedIndex),

          Expanded(
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.maxContentWidth(context),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                      Responsive.pagePadding(context),
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerMenu extends StatelessWidget {
  const _DrawerMenu();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const DrawerHeader(
          child: Center(
            child: Text(
              'QuizApp Admin',
              style: TextStyle(fontSize: 22),
            ),
          ),
        ),

        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Dashboard'),
          onTap: () => context.go(AppRoutes.dashboard),
        ),

        ListTile(
          leading: const Icon(Icons.quiz),
          title: const Text('Quizzes'),
          onTap: () => context.go(AppRoutes.quizList),
        ),

        ListTile(
          leading: const Icon(Icons.bar_chart),
          title: const Text('Resultados'),
          onTap: () => context.go(AppRoutes.results),
        ),
      ],
    );
  }
}