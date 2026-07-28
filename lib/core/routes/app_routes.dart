class AppRoutes {
  AppRoutes._();

  // ============================================
  // RUTAS PÚBLICAS
  // ============================================

  static const home = '/';
  static const login = '/login';

  // ============================================
  // RUTAS ADMINISTRATIVAS
  // ============================================

  static const dashboard = '/dashboard';

  static const quizList = '/admin/quizzes';

  static const quizForm = '/admin/quiz-form';

  static const quizDetail = '/admin/quiz-detail';

  static const questionList = '/admin/questions';

  static const questionForm = '/admin/question-form';

  static const questionImport =
      '/admin/question-import';

  static const accessCode =
      '/admin/access-code';

  // ============================================
  // RUTA EXCLUSIVA PARA SUPERADMIN
  // ============================================

  static const createAdministrator =
      '/admin/create-administrator';

  // ============================================
  // RUTAS DEL PARTICIPANTE
  // ============================================

  static const join = '/join';

  static const waiting = '/waiting';

  static const quiz = '/quiz';

  static const finish = '/finish';

  // ============================================
  // RUTAS DE RESULTADOS
  // ============================================

  static const results = '/results';

  static const statistics = '/statistics';
}