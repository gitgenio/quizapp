import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_title.dart';
import '../viewmodels/participant_view_model.dart';

class JoinQuizScreen extends StatefulWidget {
  const JoinQuizScreen({super.key});

  @override
  State<JoinQuizScreen> createState() => _JoinQuizScreenState();
}

class _JoinQuizScreenState extends State<JoinQuizScreen> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  late final ParticipantViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ParticipantViewModel();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _joinQuiz() async {
    final success = await _viewModel.joinQuiz(
      displayName: _nameController.text,
      email: _emailController.text,
      accessCode: _codeController.text,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.errorMessage ?? 'Ocurrió un error.',
          ),
        ),
      );
      return;
    }

    context.go(
      '${AppRoutes.waiting}?quizId=${_viewModel.participant!.quizId}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Unirse al Quiz",
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AppCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SectionTitle(
                    title: "Ingresar al Quiz",
                    subtitle: "Escribe tus datos para unirte.",
                  ),

                  const SizedBox(height: 30),

                  CustomTextField(
                    label: "Nombre y Apellido",
                    controller: _nameController,
                  ),

                  const SizedBox(height: 20),

                  CustomTextField(
                    label: "Correo electrónico",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20,
                  ),

                  CustomTextField(
                    label: "Código",
                    controller: _codeController,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.characters,
                  ),

                  const SizedBox(height: 30),

                  AnimatedBuilder(
                    animation: _viewModel,
                    builder: (_, __) {
                      return PrimaryButton(
                        text: _viewModel.isLoading
                            ? "Ingresando..."
                            : "Unirse",
                        icon: Icons.login,
                        onPressed: _viewModel.isLoading
                            ? null
                            : _joinQuiz,
                      );
                    },
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