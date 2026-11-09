import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/strings.dart';
import '../../core/state/providers.dart';
import '../../core/state/settings_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/logo.dart';

/// Phase 1 home: real greeting + account status. The full dashboard
/// (AI search box, progress, recent notes, tasks) is built in Phase 2.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guest = ref.watch(settingsProvider).guest;
    final profile = ref.watch(profileProvider);

    String name;
    if (guest) {
      name = ref.tr('guest_name');
    } else {
      final first = profile.valueOrNull?.firstName ?? '';
      name = first.isEmpty ? ref.tr('student') : first;
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${ref.tr('hello')},',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Text(ref.tr('tagline'),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                  const LogoMark(size: 64),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (guest)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ref.tr('guest_banner')),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          ref.read(settingsProvider.notifier).setGuest(false),
                      child: Text(ref.tr('guest_exit')),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            AppCard(
              onTap: () => context.go('/tutor'),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Ask anything. Learn everything!',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(150))),
                  ),
                  const Icon(Icons.lock_clock_outlined, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const ComingSoon(
              icon: Icons.dashboard_customize_rounded,
              title: 'Dashboard coming in Phase 2',
              message:
                  'Study progress, recent notes, tasks, subject shortcuts and the working AI search box arrive with the AI Tutor.',
              phaseLabel: 'Phase 2',
            ),
          ],
        ),
      ),
    );
  }
}
