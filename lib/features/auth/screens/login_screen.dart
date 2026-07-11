import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_title.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Panel de Administración',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.quiz_rounded,
                    size: 72,
                  ),

                  const SizedBox(height: 24),

                  const SectionTitle(
                    title: 'Panel de Administración',
                    subtitle:
                    'Ingresa para administrar tus cuestionarios.',
                  ),

                  const SizedBox(height: 32),

                  CustomTextField(
                    label: 'Correo electrónico',
                    controller: _emailController,
                  ),

                  const SizedBox(height: 20),

                  CustomTextField(
                    label: 'Contraseña',
                    controller: _passwordController,
                    obscureText: true,
                  ),

                  const SizedBox(height: 32),

                  PrimaryButton(
                    text: 'Iniciar sesión',
                    icon: Icons.login,
                    onPressed: () {
                      context.go(AppRoutes.dashboard);
                    },
                  ),

                  const SizedBox(height: 12),

                  TextButton.icon(
                    onPressed: () => context.go(AppRoutes.home),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver al inicio'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}