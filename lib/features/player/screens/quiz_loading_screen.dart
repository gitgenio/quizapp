import 'package:flutter/material.dart';

import '../../../shared/widgets/app_scaffold.dart';

class QuizLoadingScreen extends StatelessWidget {
  const QuizLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Quiz',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),

            SizedBox(height: 30),

            Icon(
              Icons.play_circle_outline,
              size: 70,
            ),

            SizedBox(height: 20),

            Text(
              '¡El Quiz ha comenzado!',
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8),

            Text(
              'Preparando las preguntas...',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}