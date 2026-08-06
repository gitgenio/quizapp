import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ParticipantTokenService {
  static const _key = 'participant_token';

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    final existing = prefs.getString(_key);

    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    const uuid = Uuid();
    final token = uuid.v4();

    await prefs.setString(_key, token);

    return token;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}