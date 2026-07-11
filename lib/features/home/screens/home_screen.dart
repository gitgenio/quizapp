import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/section_title.dart';
import '../widgets/role_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'QuizApp',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                const SectionTitle(
                  title: 'Bienvenido a QuizApp',
                  subtitle:
                  'Selecciona el tipo de usuario para continuar.',
                ),

                const SizedBox(height: 40),

                if (isMobile)
                  Column(
                    children: [
                      RoleCard(
                        icon: Icons.admin_panel_settings,
                        title: 'Administrador',
                        description:
                        'Crear quizzes, administrar preguntas y revisar resultados.',
                        buttonText: 'Ingresar',
                        onPressed: () {
                          context.go('/login');
                        },
                      ),

                      const SizedBox(height: 24),

                      RoleCard(
                        icon: Icons.school,
                        title: 'Participante',
                        description:
                        'Ingresa un código y responde el cuestionario.',
                        buttonText: 'Comenzar',
                        onPressed: () {
                          context.go('/join');
                        },
                      ),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RoleCard(
                          icon: Icons.admin_panel_settings,
                          title: 'Administrador',
                          description:
                          'Crear quizzes, administrar preguntas y revisar resultados.',
                          buttonText: 'Ingresar',
                          onPressed: () {
                            context.go(AppRoutes.login);
                          },
                        ),
                      ),

                      const SizedBox(width: 24),

                      Expanded(
                        child: RoleCard(
                          icon: Icons.school,
                          title: 'Participante',
                          description:
                          'Ingresa un código y responde el cuestionario.',
                          buttonText: 'Comenzar',
                          onPressed: () {
                            context.go(AppRoutes.join);
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}