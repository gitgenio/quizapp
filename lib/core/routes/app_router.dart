import 'package:go_router/go_router.dart';
import '../../features/admin/screens/access_code_screen.dart';
import '../../features/admin/screens/dashboard_screen.dart';
import '../../features/admin/screens/question_form_screen.dart';
import '../../features/admin/screens/question_list_screen.dart';
import '../../features/admin/screens/quiz_form_screen.dart';
import '../../features/admin/screens/quiz_list_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/player/screens/finish_screen.dart';
import '../../features/player/screens/join_quiz_screen.dart';
import '../../features/player/screens/quiz_screen.dart';
import '../../features/player/screens/waiting_screen.dart';
import '../../features/results/screens/results_screen.dart';
import '../../features/results/screens/statistics_screen.dart';
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
      builder: (_, __) => LoginScreen(),
    ),

    GoRoute(
      path: AppRoutes.dashboard,
      builder: (_, __) => const DashboardScreen(),
    ),

    GoRoute(
      path: AppRoutes.quizForm,
      builder: (_, __) => const QuizFormScreen(),
    ),

    GoRoute(
      path: AppRoutes.questionList,
      builder: (_, __) => QuestionListScreen(),
    ),

    GoRoute(
      path: AppRoutes.questionForm,
      builder: (_, __) => const QuestionFormScreen(),
    ),

    GoRoute(
      path: AppRoutes.accessCode,
      builder: (_, __) => const AccessCodeScreen(),
    ),

    GoRoute(
      path: AppRoutes.join,
      builder: (_, __) => const JoinQuizScreen(),
    ),

    GoRoute(
      path: AppRoutes.waiting,
      builder: (_, __) => const WaitingScreen(),
    ),

    GoRoute(
      path: AppRoutes.quiz,
      builder: (_, __) => const QuizScreen(),
    ),

    GoRoute(
      path: AppRoutes.finish,
      builder: (_, __) => const FinishScreen(),
    ),

    GoRoute(
      path: AppRoutes.quizList,
      builder: (_, __) => QuizListScreen(),
    ),

    GoRoute(
      path: AppRoutes.results,
      builder: (_, __) => ResultsScreen(),
    ),

    GoRoute(
      path: AppRoutes.statistics,
      builder: (_, __) => const StatisticsScreen(),
    ),
  ],
);