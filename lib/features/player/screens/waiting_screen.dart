import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../viewmodels/waiting_room_view_model.dart';

class WaitingScreen extends StatefulWidget {
  final String quizId;

  const WaitingScreen({
    super.key,
    required this.quizId,
  });

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  late final WaitingRoomViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = WaitingRoomViewModel();

    _viewModel.addListener(_onViewModelChanged);

    _viewModel.startListening(
      quizId: widget.quizId,
    );
  }

  void _onViewModelChanged() {
    if (!mounted) return;

    if (_viewModel.quizStarted) {
      context.go(AppRoutes.quizLoading);
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const PopScope(
      canPop: false,
      child: AppScaffold(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}