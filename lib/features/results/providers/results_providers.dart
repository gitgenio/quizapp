import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/results_view_model.dart';

/// Provider para ResultsViewModel.
final resultsViewModelProvider =
ChangeNotifierProvider<ResultsViewModel>((ref) {
  return ResultsViewModel();
});