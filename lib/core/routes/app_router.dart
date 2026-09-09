import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/quiz.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../features/admin/screens/access_code_screen.dart';
import '../../features/admin/screens/create_administrator_screen.dart';
import '../../features/admin/screens/dashboard_screen.dart';
import '../../features/admin/screens/question_form_screen.dart';
import '../../features/admin/screens/question_list_screen.dart';
import '../../features/admin/screens/start_quiz_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/player/models/quiz_session_data.dart'; // <-- IMPORTACIÓN AGREGADA
import '../../features/player/screens/finish_screen.dart';
import '../../features/player/screens/join_quiz_screen.dart';
import '../../features/player/screens/quiz_loading_screen.dart';
import '../../features/player/screens/quiz_screen.dart';
import '../../features/player/screens/waiting_screen.dart';
import '../../features/quiz/screens/question_import_screen.dart';
import '../../features/quiz/screens/quiz_detail_screen.dart';
import '../../features/quiz/screens/quiz_form_screen.dart';
import '../../features/quiz/screens/quiz_list_screen.dart';
import '../../features/results/screens/results_screen.dart';
import '../../features/results/screens/statistics_screen.dart';

import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,

  redirect: (
      context,
      state,
      ) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
    final location = state.matchedLocation;
    final isLoginRoute = location == AppRoutes.login;

    // ============================================
    // RUTAS ADMINISTRATIVAS
    // ============================================

    final isAdminRoute =
        location == AppRoutes.dashboard ||
            location == AppRoutes.createAdministrator ||
            location == AppRoutes.quizList ||
            location == AppRoutes.quizForm ||
            location == AppRoutes.quizDetail ||
            location == AppRoutes.startQuiz ||
            location == AppRoutes.questionList ||
            location == AppRoutes.questionForm ||
            location == AppRoutes.questionImport ||
            location == AppRoutes.accessCode ||
            location == AppRoutes.results ||
            location == AppRoutes.statistics;

    // ============================================
    // USUARIO NO AUTENTICADO
    // ============================================

    if (!isLoggedIn && isAdminRoute) {
      return AppRoutes.login;
    }

    // ============================================
    // USUARIO AUTENTICADO INTENTA IR AL LOGIN
    // ============================================

    if (isLoggedIn && isLoginRoute) {
      return AppRoutes.dashboard;
    }

    return null;
  },

  routes: [
    // ============================================
    // HOME
    // ============================================
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) {
        return const HomeScreen();
      },
    ),

    // ============================================
    // LOGIN
    // ============================================
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) {
        return const LoginScreen();
      },
    ),

    // ============================================
    // DASHBOARD
    // ============================================
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) {
        return const DashboardScreen();
      },
    ),

    // ============================================
    // CREAR ADMINISTRADOR
    // ============================================
    GoRoute(
      path: AppRoutes.createAdministrator,
      builder: (context, state) {
        return const CreateAdministratorScreen();
      },
    ),

    // ============================================
    // CREAR QUIZ
    // ============================================
    GoRoute(
      path: AppRoutes.quizForm,
      builder: (context, state) {
        return const QuizFormScreen();
      },
    ),

    // ============================================
    // DETALLE DEL QUIZ
    // ============================================
    GoRoute(
      path: AppRoutes.quizDetail,
      builder: (context, state) {
        final quizId = state.uri.queryParameters['quizId'];

        if (quizId == null || quizId.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text('No se especificó el Quiz.'),
            ),
          );
        }

        return QuizDetailScreen(quizId: quizId);
      },
    ),

    GoRoute(
      path: AppRoutes.startQuiz,
      builder: (context, state) {
        final quizId = state.uri.queryParameters['quizId'];

        if (quizId == null || quizId.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text('No se especificó el Quiz.'),
            ),
          );
        }

        return FutureBuilder<Quiz?>(
          future: QuizRepository().getQuizById(quizId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError || snapshot.data == null) {
              return const Scaffold(
                body: Center(
                  child: Text('No se pudo cargar el Quiz.'),
                ),
              );
            }

            return StartQuizScreen(quiz: snapshot.data!);
          },
        );
      },
    ),

    // ============================================
    // LISTA DE PREGUNTAS
    // ============================================
    GoRoute(
      path: AppRoutes.questionList,
      builder: (context, state) {
        return QuestionListScreen();
      },
    ),

    // ============================================
    // FORMULARIO DE PREGUNTA
    // ============================================
    GoRoute(
      path: AppRoutes.questionForm,
      builder: (context, state) {
        return const QuestionFormScreen();
      },
    ),

    // ============================================
    // CÓDIGO DE ACCESO
    // ============================================
    GoRoute(
      path: AppRoutes.accessCode,
      builder: (context, state) {
        return const AccessCodeScreen();
      },
    ),

    // ============================================
    // LISTA DE QUIZZES
    // ============================================
    GoRoute(
      path: AppRoutes.quizList,
      builder: (context, state) {
        return QuizListScreen();
      },
    ),

    // ============================================
    // IMPORTAR PREGUNTAS DESDE EXCEL
    // ============================================
    GoRoute(
      path: AppRoutes.questionImport,
      builder: (context, state) {
        final quizId = state.uri.queryParameters['quizId'];
        final questionCountString = state.uri.queryParameters['questionCount'];
        final questionCount = int.tryParse(questionCountString ?? '');

        if (quizId == null || quizId.isEmpty || questionCount == null) {
          return const Scaffold(
            body: Center(
              child: Text('Información del Quiz no válida.'),
            ),
          );
        }

        return QuestionImportScreen(
          quizId: quizId,
          requiredQuestionCount: questionCount,
        );
      },
    ),

    // ============================================
    // UNIRSE A QUIZ
    // ============================================
    GoRoute(
      path: AppRoutes.join,
      builder: (context, state) {
        return const JoinQuizScreen();
      },
    ),

    // ============================================
    // ESPERA
    // ============================================
    GoRoute(
      path: AppRoutes.waiting,
      builder: (context, state) {
        final quizId = state.uri.queryParameters['quizId'];
        final participantId = state.uri.queryParameters['participantId'];

        if (quizId == null || quizId.isEmpty || participantId == null || participantId.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text('No se pudo identificar el Quiz o el Participante.'),
            ),
          );
        }

        return WaitingScreen(
          quizId: quizId,
          participantId: participantId,
        );
      },
    ),

    // ============================================
    // CARGANDO QUIZ
    // ============================================
    GoRoute(
      path: AppRoutes.quizLoading,
      builder: (context, state) {
        final quizId = state.uri.queryParameters['quizId'];
        final participantId = state.uri.queryParameters['participantId'];

        if (quizId == null || quizId.isEmpty || participantId == null || participantId.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text('No se pudo identificar el Quiz o el Participante.'),
            ),
          );
        }

        return QuizLoadingScreen(
          quizId: quizId,
          participantId: participantId,
        );
      },
    ),

    // ============================================
    // QUIZ DEL PARTICIPANTE
    // ============================================
    GoRoute(
      path: AppRoutes.quiz,
      builder: (context, state) {
        // <-- CAMBIO CLAVE: Extraer los datos pasados por 'extra'
        final sessionData = state.extra as QuizSessionData?;

        if (sessionData == null) {
          return const Scaffold(
            body: Center(
              child: Text('No se pudieron cargar los datos del Quiz.'),
            ),
          );
        }

        return QuizScreen(sessionData: sessionData);
      },
    ),

    // ============================================
    // FINALIZAR QUIZ
    // ============================================
    GoRoute(
      path: AppRoutes.finish,
      builder: (context, state) {
        return const FinishScreen();
      },
    ),

    // ============================================
    // RESULTADOS
    // ============================================
    GoRoute(
      path: AppRoutes.results,
      builder: (context, state) {
        return ResultsScreen();
      },
    ),

    // ============================================
    // ESTADÍSTICAS
    // ============================================
    GoRoute(
      path: AppRoutes.statistics,
      builder: (context, state) {
        return const StatisticsScreen();
      },
    ),
  ],
);