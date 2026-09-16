import 'package:flutter/foundation.dart';

import '../../../data/repositories/results_repository.dart';
import '../../../data/models/quiz.dart';
import '../../player/models/quiz_result.dart';

/// ViewModel para la pantalla de resultados.
class ResultsViewModel extends ChangeNotifier {
  final ResultsRepository _repository;

  ResultsViewModel({
    ResultsRepository? repository,
  }) : _repository = repository ?? ResultsRepository();

  Quiz? _quiz;
  List<QuizResult> _results = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedQuizId;

  Quiz? get quiz => _quiz;
  List<QuizResult> get results => _results;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedQuizId => _selectedQuizId;

  /// Carga los resultados de un Quiz específico.
  Future<void> loadResults(String quizId) async {
    _isLoading = true;
    _error = null;
    _selectedQuizId = quizId;
    notifyListeners();

    try {
      final resultsFuture = _repository.getQuizResults(quizId);
      final quizFuture = _repository.getQuizById(quizId);

      final results = await resultsFuture;
      final quiz = await quizFuture;

      _results = results;
      _quiz = quiz;
    } catch (e) {
      _error = 'Error al cargar los resultados: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtiene el detalle de respuestas de un participante.
  Future<Map<String, dynamic>> getParticipantDetail(String participantId) async {
    if (_selectedQuizId == null) {
      throw Exception('No hay un quiz seleccionado');
    }

    return await _repository.getParticipantDetail(
      participantId: participantId,
      quizId: _selectedQuizId!,
    );
  }

  /// Calcula el promedio de puntajes.
  double get averageScore {
    if (_results.isEmpty) return 0.0;
    final total = _results.fold<double>(
      0,
          (sum, result) => sum + result.score,
    );
    return total / _results.length;
  }

  /// Obtiene el mejor puntaje.
  double get bestScore {
    if (_results.isEmpty) return 0.0;
    return _results.map((r) => r.score).reduce((a, b) => a > b ? a : b);
  }

  /// Obtiene el peor puntaje.
  double get worstScore {
    if (_results.isEmpty) return 0.0;
    return _results.map((r) => r.score).reduce((a, b) => a < b ? a : b);
  }

  /// Total de participantes.
  int get totalParticipants => _results.length;

  /// Verifica si hay resultados.
  bool get hasResults => _results.isNotEmpty;
}