import 'package:flutter/material.dart';

import '../widgets/admin_scaffold.dart';
import '../widgets/page_header.dart';

class AccessCodeScreen extends StatelessWidget {
  const AccessCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Código de Acceso',
      selectedIndex: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const PageHeader(
            title: 'Código del Quiz',
            subtitle: 'Comparte este código con los participantes.',
          ),

          const SizedBox(height: 40),

          Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 40,
                ),
                child: Column(
                  children: [

                    Text(
                      'ABC123',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium,
                    ),

                    const SizedBox(height: 20),

                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.copy),
                      label: const Text('Copiar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}