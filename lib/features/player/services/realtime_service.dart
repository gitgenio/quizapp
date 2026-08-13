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
    _quizChannel?.unsubscribe();

    _quizChannel = _supabase
        .channel('quiz-status-$quizId')
        .onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'quizzes',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: quizId,
      ),
      callback: (payload) {
        final status = payload.newRecord['status'];

        if (status is String) {
          onStatusChanged(status);
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