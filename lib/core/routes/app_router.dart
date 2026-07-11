import 'package:go_router/go_router.dart';

import '../../features/home/screens/home_screen.dart';
import '../../shared/widgets/placeholder_screen.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [

    GoRoute(
      path: AppRoutes.home,
      builder: (_, __) => const HomeScreen(),
    ),

    GoRoute(
      path: AppRoutes.login,
      builder: (_, __) =>
      const PlaceholderScreen(title: 'Login'),
    ),

    GoRoute(
      path: AppRoutes.dashboard,
      builder: (_, __) =>
      const PlaceholderScreen(title: 'Dashboard'),
    ),

    GoRoute(
      path: AppRoutes.quizList,
      builder: (_, __) =>
      const PlaceholderScreen(title: 'Lista de Quizzes'),
    ),

    GoRoute(
      path: AppRoutes.quizForm,
      builder: (_, __) =>
      const PlaceholderScreen(title: 'Formulario Quiz'),
    ),

    GoRoute(
      path: AppRoutes.questionList,
      builder: (_, __) =>
      const PlaceholderScreen(title: 'Lista de Preguntas'),
    ),

    GoRoute(
      path: AppRoutes.questionForm,
      builder: (_, __) =>
      const PlaceholderScreen(title: 'Formulario Pregunta'),
    ),

    GoRoute(
      path: AppRoutes.accessCode,
      builder: (_, __) =>
      const PlaceholderScreen(title: 'Código de Acceso'),
    ),

    GoRoute(
      path: AppRoutes.join,
      builder: (_, __) =>
      const PlaceholderScreen(title: 'Ingresar al Quiz'),
    ),

    GoRoute(
      path: AppRoutes.waiting,
      builder: (_, __) =>
      const PlaceholderScreen(title: 'Sala de Espera'),
    ),

    GoRoute(
      path: AppRoutes.quiz,
      builder: (_, __) =>
      const PlaceholderScreen(title: 'Quiz'),
    ),

    GoRoute(
      path: AppRoutes.finish,
      builder: (_, __) =>
      const PlaceholderScreen(title: 'Finalización'),
    ),

    GoRoute(
      path: AppRoutes.results,
      builder: (_, __) =>
      const PlaceholderScreen(title: 'Resultados'),
    ),

    GoRoute(
      path: AppRoutes.statistics,
      builder: (_, __) =>
      const PlaceholderScreen(title: 'Estadísticas'),
    ),
  ],
);