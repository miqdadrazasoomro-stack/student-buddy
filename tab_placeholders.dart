import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/strings.dart';
import '../../core/widgets/common_widgets.dart';

/// These tabs exist so navigation is complete, but their features are built in
/// later phases. They are clearly labelled and contain no fake data.
class _TabPlaceholder extends ConsumerWidget {
  const _TabPlaceholder({
    required this.titleKey,
    required this.icon,
    required this.message,
    required this.phase,
  });
  final String titleKey;
  final IconData icon;
  final String message;
  final int phase;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(title: Text(ref.tr(titleKey))),
        body: ComingSoon(
          icon: icon,
          title: ref.tr('coming_soon'),
          message: message,
          phaseLabel: 'Phase $phase',
        ),
      );
}

class TutorTab extends StatelessWidget {
  const TutorTab({super.key});
  @override
  Widget build(BuildContext context) => const _TabPlaceholder(
        titleKey: 'tutor',
        icon: Icons.auto_awesome_rounded,
        message:
            'The AI Tutor with streaming answers, Urdu / English / Roman Urdu support and follow-up questions is built in Phase 2.',
        phase: 2,
      );
}

class NotesTab extends StatelessWidget {
  const NotesTab({super.key});
  @override
  Widget build(BuildContext context) => const _TabPlaceholder(
        titleKey: 'notes',
        icon: Icons.edit_note_rounded,
        message:
            'Manual and AI-generated notes, folders, search and PDF export are built in Phase 3.',
        phase: 3,
      );
}

class PlannerTab extends StatelessWidget {
  const PlannerTab({super.key});
  @override
  Widget build(BuildContext context) => const _TabPlaceholder(
        titleKey: 'planner',
        icon: Icons.event_note_rounded,
        message:
            'Study tasks, deadlines, exam countdowns and reminders are built in Phase 5.',
        phase: 5,
      );
}
