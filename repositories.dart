import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/app_database.dart';
import 'errors.dart';
import 'profile.dart';

class AuthRepository {
  AuthRepository(this._client, this._db);
  final SupabaseClient _client;
  final AppDatabase _db;

  Future<void> signIn(String email, String password) async {
    await _client.auth
        .signInWithPassword(email: email.trim(), password: password)
        .timeout(const Duration(seconds: 20));
  }

  /// Returns true when the user is signed in immediately, false when the
  /// project requires email confirmation first.
  Future<bool> signUp(String fullName, String email, String password) async {
    final res = await _client.auth
        .signUp(
          email: email.trim(),
          password: password,
          data: {'full_name': fullName.trim()},
        )
        .timeout(const Duration(seconds: 20));
    return res.session != null;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    await _db.clearAll();
  }

  Future<void> deleteAccount() async {
    try {
      await _client.functions
          .invoke('delete-account')
          .timeout(const Duration(seconds: 30));
    } on FunctionException catch (e) {
      final d = e.details;
      throw AiException(d is Map && d['message'] != null
          ? d['message'].toString()
          : 'Could not delete the account (${e.status}). Is the delete-account function deployed?');
    }
    // The server-side user no longer exists, so only clear the local session.
    await _client.auth.signOut(scope: SignOutScope.local);
    await _db.clearAll();
  }
}

class ProfileRepository {
  ProfileRepository(this._client, this._db);
  final SupabaseClient _client;
  final AppDatabase _db;

  /// Loads the profile from Supabase; falls back to the offline cache.
  Future<Profile?> fetchCurrent() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    try {
      final row = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single()
          .timeout(const Duration(seconds: 12));
      await _db.saveProfile(user.id, jsonEncode(row));
      return Profile.fromJson(row, email: user.email);
    } catch (_) {
      final cached = await _db.loadProfile(user.id);
      if (cached != null) {
        return Profile.fromJson(jsonDecode(cached) as Map<String, dynamic>,
            email: user.email);
      }
      rethrow;
    }
  }

  Future<Profile> update({
    required String fullName,
    required String? grade,
    required String preferredLanguage,
    required List<String> subjects,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw AiException('Please sign in again.');
    final row = await _client
        .from('profiles')
        .update({
          'full_name': fullName.trim(),
          'grade': grade,
          'preferred_language': preferredLanguage,
          'subjects': subjects,
        })
        .eq('id', user.id)
        .select()
        .single()
        .timeout(const Duration(seconds: 15));
    await _db.saveProfile(user.id, jsonEncode(row));
    return Profile.fromJson(row, email: user.email);
  }
}

class AiService {
  AiService(this._client);
  final SupabaseClient _client;

  /// Phase 1 health check: asks the backend to make one tiny real call to the
  /// configured AI provider. Throws [AiException] with a clear reason on failure.
  Future<String> ping() async {
    try {
      final res = await _client.functions
          .invoke('ai-proxy', body: {'action': 'ping'})
          .timeout(const Duration(seconds: 40));
      final data = res.data;
      if (data is Map && data['ok'] == true) {
        return 'AI is connected (${data['provider']} · ${data['model']}).';
      }
      throw AiException('Unexpected response from the AI service.');
    } on FunctionException catch (e) {
      final d = e.details;
      throw AiException(d is Map && d['message'] != null
          ? d['message'].toString()
          : 'AI service error (${e.status}). Is the ai-proxy function deployed?');
    } on TimeoutException {
      throw AiException('The AI service did not respond in time.');
    } on SocketException {
      throw AiException('No internet connection.');
    }
  }
}
