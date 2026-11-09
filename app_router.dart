import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/shell/tab_placeholders.dart';
import '../state/providers.dart';
import '../state/settings_controller.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Re-run redirect whenever auth or guest status changes.
  final refresh = ValueNotifier<int>(0);
  ref.listen(settingsProvider.select((s) => s.guest), (_, __) => refresh.value++);
  ref.listen(authStateProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: refresh,
    redirect: (context, state) {
      final signedIn = Supabase.instance.client.auth.currentSession != null;
      final guest = ref.read(settingsProvider).guest;
      final loc = state.matchedLocation;
      final onAuthPage = loc == '/login' || loc == '/signup';

      if (!signedIn && !guest) return onAuthPage ? null : '/login';
      if (onAuthPage) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/tutor', builder: (_, __) => const TutorTab()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/notes', builder: (_, __) => const NotesTab()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/planner', builder: (_, __) => const PlannerTab()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfileScreen(),
              routes: [
                GoRoute(
                    path: 'edit',
                    builder: (_, __) => const EditProfileScreen()),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});
