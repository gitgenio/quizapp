import 'package:flutter/material.dart';

import '../../../shared/widgets/app_scaffold.dart';

class WaitingScreen extends StatelessWidget {
  const WaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: "Sala de Espera",
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            CircularProgressIndicator(),

            SizedBox(height: 30),

            Icon(
              Icons.hourglass_top,
              size: 70,
            ),

            SizedBox(height: 20),

            Text(
              "Esperando que el administrador\ninicie el Quiz...",
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}