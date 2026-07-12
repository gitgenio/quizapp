import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/page_header.dart';

class QuestionFormScreen extends StatefulWidget {
  const QuestionFormScreen({super.key});

  @override
  State<QuestionFormScreen> createState() => _QuestionFormScreenState();
}

class _QuestionFormScreenState extends State<QuestionFormScreen> {
  final _questionController = TextEditingController();

  final _optionAController = TextEditingController();
  final _optionBController = TextEditingController();
  final _optionCController = TextEditingController();
  final _optionDController = TextEditingController();

  String _correctAnswer = 'A';

  @override
  void dispose() {
    _questionController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    _optionCController.dispose();
    _optionDController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Pregunta',
      selectedIndex: 2,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const PageHeader(
              title: 'Nueva Pregunta',
              subtitle: 'Completa la información.',
            ),

            const SizedBox(height: 24),

            CustomTextField(
              label: 'Pregunta',
              controller: _questionController,
            ),

            const SizedBox(height: 20),

            CustomTextField(
              label: 'Opción A',
              controller: _optionAController,
            ),

            const SizedBox(height: 20),

            CustomTextField(
              label: 'Opción B',
              controller: _optionBController,
            ),

            const SizedBox(height: 20),

            CustomTextField(
              label: 'Opción C',
              controller: _optionCController,
            ),

            const SizedBox(height: 20),

            CustomTextField(
              label: 'Opción D',
              controller: _optionDController,
            ),

            const SizedBox(height: 30),

            DropdownButtonFormField<String>(
              value: _correctAnswer,
              decoration: const InputDecoration(
                labelText: 'Respuesta correcta',
              ),
              items: const [

                DropdownMenuItem(
                  value: 'A',
                  child: Text('Opción A'),
                ),

                DropdownMenuItem(
                  value: 'B',
                  child: Text('Opción B'),
                ),

                DropdownMenuItem(
                  value: 'C',
                  child: Text('Opción C'),
                ),

                DropdownMenuItem(
                  value: 'D',
                  child: Text('Opción D'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _correctAnswer = value;
                });
              },
            ),

            const SizedBox(height: 30),

            PrimaryButton(
              text: 'Guardar Pregunta',
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