import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/app_database.dart';
import '../services/profile.dart';
import '../services/repositories.dart';

final supabaseProvider =
    Provider<SupabaseClient>((ref) => Supabase.instance.client);

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final authStateProvider = StreamProvider<AuthState>(
    (ref) => ref.watch(supabaseProvider).auth.onAuthStateChange);

final authRepoProvider = Provider<AuthRepository>((ref) =>
    AuthRepository(ref.watch(supabaseProvider), ref.watch(databaseProvider)));

final profileRepoProvider = Provider<ProfileRepository>((ref) =>
    ProfileRepository(ref.watch(supabaseProvider), ref.watch(databaseProvider)));

final aiServiceProvider =
    Provider<AiService>((ref) => AiService(ref.watch(supabaseProvider)));

/// Current user's profile (null for guests). Refreshes when the user changes.
final profileProvider = FutureProvider.autoDispose<Profile?>((ref) async {
  ref.watch(authStateProvider.select((s) => s.valueOrNull?.session?.user.id));
  return ref.watch(profileRepoProvider).fetchCurrent();
});

/// true = online. Emits the current state first, then every change.
final onlineProvider = StreamProvider<bool>((ref) async* {
  final c = Connectivity();
  bool isOnline(List<ConnectivityResult> r) =>
      r.any((e) => e != ConnectivityResult.none);
  yield isOnline(await c.checkConnectivity());
  yield* c.onConnectivityChanged.map(isOnline);
});
