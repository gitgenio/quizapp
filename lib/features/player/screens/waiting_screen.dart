import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // <-- AGREGADO: Necesario para usar context.go o context.push
import '../../../core/routes/app_routes.dart'; // <-- AGREGADO: Para usar tus rutas
import '../../../shared/widgets/app_scaffold.dart';

class WaitingScreen extends StatelessWidget {
  const WaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Bloquea que el botón "atrás" del celular rompa la app o la cierre de golpe
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // Al presionar atrás en la sala de espera, lo devolvemos de forma segura
        // a la pantalla de unirse al juego (o a la que prefieras) usando context.go
        if (context.canPop()) {
          context.pop(); // Esto hace un "atrás" natural respetando la pila original
        } else {
          // Por seguridad, si por alguna razón la pila quedó vacía, lo mandamos al Home
          context.go(AppRoutes.home);
        }
      },
      child: const AppScaffold(
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
      ),
    );
  }
}