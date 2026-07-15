import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_title.dart';

class JoinQuizScreen extends StatefulWidget {
  const JoinQuizScreen({super.key});

  @override
  State<JoinQuizScreen> createState() => _JoinQuizScreenState();
}

class _JoinQuizScreenState extends State<JoinQuizScreen> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Unirse al Quiz",
      child: Center(
        // 1. Envolvemos el contenido en un scroll interactivo pero ajustado
        child: SingleChildScrollView(
          // Añade un pequeño padding para que al scrollear con el teclado abierto no quede pegado a los bordes
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AppCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SectionTitle(
                    title: "Ingresar al Quiz",
                    subtitle: "Escribe el código y tu nombre.",
                  ),

                  const SizedBox(height: 30),

                  CustomTextField(
                    label: "Código",
                    controller: _codeController,
                  ),

                  const SizedBox(height: 20),

                  CustomTextField(
                    label: "Nombre",
                    controller: _nameController,
                  ),

                  const SizedBox(height: 30),

                  PrimaryButton(
                    text: "Unirse",
                    icon: Icons.login,
                    onPressed: () {
                      // 2. OJO: Cambiado de .go a .push para conservar la pila de navegación
                      // y que el botón de atrás no rompa el historial.
                      context.push(AppRoutes.waiting);
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}