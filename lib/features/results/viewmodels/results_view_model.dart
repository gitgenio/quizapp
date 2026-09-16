import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/results_repository.dart';
import '../../../data/models/quiz.dart';
import '../../player/models/quiz_result.dart';

/// 1. Provider del repositorio
final resultsRepositoryProvider = Provider<ResultsRepository>((ref) {
  return ResultsRepository();
});

/// 2. Estado del ViewModel
class ResultsState {
  final Quiz? quiz;
  final List<QuizResult> results;
  final bool isLoading;
  final String? error;
  final String? selectedQuizId;

  ResultsState({
    this.quiz,
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.selectedQuizId,
  });

  ResultsState copyWith({
    Quiz? quiz,
    List<QuizResult>? results,
    bool? isLoading,
    String? error,
    String? selectedQuizId,
  }) {
    return ResultsState(
      quiz: quiz ?? this.quiz,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedQuizId: selectedQuizId ?? this.selectedQuizId,
    );
  }
}

/// 3. ViewModel (Notifier)
class ResultsViewModel extends Notifier<ResultsState> {
  @override
  ResultsState build() => ResultsState();

  ResultsRepository get _repository => ref.read(resultsRepositoryProvider);

  Future<void> loadResults(String quizId) async {
    print('🔍 Cargando resultados para quiz: $quizId');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final resultsFuture = _repository.getQuizResults(quizId);
      final quizFuture = _repository.getQuizById(quizId);

      final results = await resultsFuture;
      final quiz = await quizFuture;

      print('✅ Resultados obtenidos: ${results.length} participantes');
      print('✅ Quiz: ${quiz?.title}');
      print('✅ Primer resultado: ${results.firstOrNull?.displayName}');

      state = state.copyWith(
        isLoading: false,
        results: results,
        quiz: quiz,
        selectedQuizId: quizId,
      );
    } catch (e) {
      print('❌ Error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar los resultados: $e',
      );
    }
  }

  // Helpers para la UI (acceden a state.results)
  double get averageScore {
    if (state.results.isEmpty) return 0.0;
    final total = state.results.fold<double>(0, (sum, r) => sum + r.score);
    return total / state.results.length;
  }

  double get bestScore {
    if (state.results.isEmpty) return 0.0;
    return state.results.map((r) => r.score).reduce((a, b) => a > b ? a : b);
  }

  double get worstScore {
    if (state.results.isEmpty) return 0.0;
    return state.results.map((r) => r.score).reduce((a, b) => a < b ? a : b);
  }

  int get totalParticipants => state.results.length;
  bool get hasResults => state.results.isNotEmpty;
}

/// 4. Provider del ViewModel
final resultsViewModelProvider = NotifierProvider<ResultsViewModel, ResultsState>(
  ResultsViewModel.new,
);