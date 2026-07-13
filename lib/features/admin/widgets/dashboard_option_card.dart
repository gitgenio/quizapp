import 'package:flutter/material.dart';

import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/primary_button.dart';

class DashboardOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onPressed;

  const DashboardOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Icon(
              icon,
              size: 48,
            ),

            const SizedBox(height: 16),

            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 8),

            Text(
              description,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: "Abrir",
                icon: Icons.arrow_forward,
                onPressed: onPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}