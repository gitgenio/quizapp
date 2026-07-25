import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_title.dart';

class CreateAdministratorScreen extends StatefulWidget {
  const CreateAdministratorScreen({
    super.key,
  });

  @override
  State<CreateAdministratorScreen> createState() =>
      _CreateAdministratorScreenState();
}

class _CreateAdministratorScreenState
    extends State<CreateAdministratorScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  final AuthRepository _authRepository =
  const AuthRepository();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController =
        TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _createAdministrator() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword =
        _confirmPasswordController.text;

    // Validar nombre.
    if (name.isEmpty) {
      _showMessage(
        'Ingresa el nombre del profesor.',
      );
      return;
    }

    // Validar correo.
    if (email.isEmpty) {
      _showMessage(
        'Ingresa el correo electrónico.',
      );
      return;
    }

    // Validar contraseña.
    if (password.isEmpty) {
      _showMessage(
        'Ingresa una contraseña.',
      );
      return;
    }

    // Confirmar contraseña.
    if (password != confirmPassword) {
      _showMessage(
        'Las contraseñas no coinciden.',
      );
      return;
    }

    // Validar longitud mínima de la contraseña.
    if (password.length < 6) {
      _showMessage(
        'La contraseña debe tener mínimo 6 caracteres.',
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authRepository.createAdministrator(
        name: name,
        email: email,
        password: password,
      );

      if (!mounted) return;

      _showMessage(
        'Profesor creado correctamente.',
      );

      // Limpiar formulario.
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    } on AuthException catch (error) {
      if (!mounted) return;

      _showMessage(
        error.message,
      );
    } catch (error) {
      if (!mounted) return;

      debugPrint(
        'Error creando profesor: $error',
      );

      _showMessage(
        'Ocurrió un error inesperado.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
      title: 'Crear profesor',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          child: SingleChildScrollView(
            child: AppCard(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
                  const SectionTitle(
                    title: 'Crear profesor',
                    subtitle:
                    'Registra un nuevo usuario administrador.',
                  ),

                  const SizedBox(height: 32),

                  CustomTextField(
                    label: 'Nombre',
                    controller: _nameController,
                  ),

                  const SizedBox(height: 20),

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

                  const SizedBox(height: 20),

                  CustomTextField(
                    label: 'Confirmar contraseña',
                    controller:
                    _confirmPasswordController,
                    obscureText: true,
                  ),

                  const SizedBox(height: 32),

                  PrimaryButton(
                    text: _isLoading
                        ? 'Creando profesor...'
                        : 'Crear profesor',
                    icon: Icons.person_add,
                    onPressed: _isLoading
                        ? null
                        : _createAdministrator,
                  ),

                  const SizedBox(height: 12),

                  TextButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                    ),
                    label: const Text(
                      'Volver',
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