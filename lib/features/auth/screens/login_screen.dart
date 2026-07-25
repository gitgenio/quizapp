import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/enums/user_role.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_title.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  final AuthRepository _authRepository =
  const AuthRepository();

  bool _isLoading = false;

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

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validar campos obligatorios.
    if (email.isEmpty || password.isEmpty) {
      _showMessage(
        'Ingresa tu correo electrónico y contraseña.',
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Iniciar sesión en Supabase Auth.
      await _authRepository.signIn(
        email: email,
        password: password,
      );

      // 2. Cargar el perfil del usuario autenticado.
      final appUser =
      await authController.loadCurrentUser();

      if (!mounted) return;

      // 3. Verificar que exista el perfil.
      if (appUser == null) {
        await authController.signOut();

        _showMessage(
          'No se encontró el perfil del usuario.',
        );

        return;
      }

      // 4. Redireccionar según el rol.
      switch (appUser.role) {
        case UserRole.superAdmin:
          context.go(AppRoutes.dashboard);
          break;

        case UserRole.administrator:
          context.go(AppRoutes.dashboard);
          break;
      }
    } on AuthException catch (error) {
      if (!mounted) return;

      _showMessage(
        _getAuthErrorMessage(error),
      );
    } catch (error) {
      if (!mounted) return;

      debugPrint(
        'Error inesperado durante el login: $error',
      );

      _showMessage(
        'Ocurrió un error inesperado. Intenta nuevamente.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getAuthErrorMessage(
      AuthException error,
      ) {
    if (error.message == 'Invalid login credentials') {
      return 'Correo o contraseña incorrectos.';
    }

    return error.message;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Panel de Administración',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 420,
          ),
          child: SingleChildScrollView(
            child: AppCard(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
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
                    text: _isLoading
                        ? 'Iniciando sesión...'
                        : 'Iniciar sesión',
                    icon: Icons.login,
                    onPressed:
                    _isLoading ? null : _login,
                  ),

                  const SizedBox(height: 12),

                  TextButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => context.go(
                      AppRoutes.home,
                    ),
                    icon: const Icon(
                      Icons.arrow_back,
                    ),
                    label: const Text(
                      'Volver al inicio',
                    ),
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