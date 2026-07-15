import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- AGREGADO: Necesario para SystemChannels
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/section_title.dart';
import '../widgets/role_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Método auxiliar para mostrar el diálogo de confirmación de salida
  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar la aplicación?'),
        content: const Text('¿Estás seguro de que quieres salir?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // No salir
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Sí salir
            child: const Text('Sí, salir'),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Bloquea que el botón "atrás" físico del móvil cierre la app bruscamente
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Preguntamos al usuario si realmente desea salir
        final shouldClose = await _showExitConfirmationDialog(context);

        // Si confirma, cerramos la aplicación de forma limpia para evitar la pantalla negra
        if (shouldClose && context.mounted) {
          await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
      },
      child: AppScaffold(
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
                    subtitle: 'Selecciona el tipo de usuario para continuar.',
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
                            // Cambiado a AppRoutes para mantener consistencia
                            context.push(AppRoutes.login);
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
                            // Cambiado a AppRoutes para mantener consistencia
                            context.push(AppRoutes.join);
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
                              context.push(AppRoutes.login);
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
                              context.push(AppRoutes.join);
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
      ),
    );
  }
}