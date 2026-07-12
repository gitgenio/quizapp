import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/page_header.dart';

class QuizFormScreen extends StatefulWidget {
  const QuizFormScreen({super.key});

  @override
  State<QuizFormScreen> createState() => _QuizFormScreenState();
}

class _QuizFormScreenState extends State<QuizFormScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isActive = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: "Quiz",
      selectedIndex: 1,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: "Nuevo Quiz",
              subtitle: "Completa la información del cuestionario.",
            ),

            const SizedBox(height: 30),

            CustomTextField(
              label: "Título",
              controller: _titleController,
            ),

            const SizedBox(height: 20),

            CustomTextField(
              label: "Descripción",
              controller: _descriptionController,
            ),

            const SizedBox(height: 20),

            SwitchListTile(
              value: _isActive,
              title: const Text("Quiz Activo"),
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),

            const SizedBox(height: 30),

            PrimaryButton(
              text: "Guardar Quiz",
              icon: Icons.save,
              onPressed: () {
                context.go(AppRoutes.questionList);
              },
            ),
          ],
        ),
      ),
    );
  }
}