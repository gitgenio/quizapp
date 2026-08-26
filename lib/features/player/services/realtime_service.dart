import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeService {
  final SupabaseClient _supabase;

  RealtimeService({
    SupabaseClient? supabase,
  }) : _supabase = supabase ?? Supabase.instance.client;

  RealtimeChannel? _quizChannel;

  RealtimeChannel listenToQuiz({
    required String quizId,
    required void Function(String status) onStatusChanged,
  }) {
    // Si ya existe un canal, lo eliminamos antes de crear uno nuevo
    if (_quizChannel != null) {
      _supabase.removeChannel(_quizChannel!);
      _quizChannel = null;
    }

    _quizChannel = _supabase
        .channel('quiz-status-$quizId')
        .onPostgresChanges(
      event: PostgresChangeEvent.all, // Escucha cualquier cambio en la fila
      schema: 'public',
      table: 'quizzes',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: quizId,
      ),
      callback: (payload) {
        final newRecord = payload.newRecord;
        if (newRecord.isNotEmpty && newRecord.containsKey('status')) {
          final status = newRecord['status'];
          if (status is String) {
            onStatusChanged(status);
          }
        }
      },
    )
        .subscribe();

    return _quizChannel!;
  }

  Future<void> unsubscribeFromQuiz() async {
    final channel = _quizChannel;

    if (channel == null) {
      return;
    }

    await _supabase.removeChannel(channel);
    _quizChannel = null;
  }

  Future<void> dispose() async {
    await unsubscribeFromQuiz();
  }
}