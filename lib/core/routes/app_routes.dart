class AppRoutes {
  AppRoutes._();

  // Rutas públicas
  static const home = '/';
  static const login = '/login';

  // Rutas administrativas
  static const dashboard = '/dashboard';

  static const quizList = '/admin/quizzes';
  static const quizForm = '/admin/quiz-form';

  static const questionList = '/admin/questions';
  static const questionForm = '/admin/question-form';

  static const accessCode = '/admin/access-code';

  static const String questionImport = '/question-import';

  // Ruta exclusiva para SuperAdmin
  static const createAdministrator =
      '/admin/create-administrator';

  // Rutas del participante
  static const join = '/join';
  static const waiting = '/waiting';
  static const quiz = '/quiz';
  static const finish = '/finish';

  // Rutas de resultados
  static const results = '/results';
  static const statistics = '/statistics';
}