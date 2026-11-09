import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/strings.dart';
import '../../core/services/errors.dart';
import '../../core/services/profile.dart';
import '../../core/state/providers.dart';
import '../../core/widgets/common_widgets.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(ref.tr('edit_profile')),
        leading: BackButton(onPressed: () => context.go('/profile')),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(friendlyError(e), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                OutlinedButton(
                    onPressed: () => ref.invalidate(profileProvider),
                    child: const Text('Retry')),
              ],
            ),
          ),
        ),
        data: (profile) => profile == null
            ? const SizedBox.shrink()
            : _EditForm(profile: profile),
      ),
    );
  }
}

class _EditForm extends ConsumerStatefulWidget {
  const _EditForm({required this.profile});
  final Profile profile;
  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<_EditForm> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  String? _grade;
  late String _answerLang;
  late Set<String> _subjects;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _name = TextEditingController(text: p.fullName);
    _grade = gradeOptions.contains(p.grade) ? p.grade : null;
    _answerLang = answerLanguageOptions.containsKey(p.preferredLanguage)
        ? p.preferredLanguage
        : 'english';
    _subjects = p.subjects.toSet();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final savedMsg = ref.trRead('saved');
    try {
      await ref.read(profileRepoProvider).update(
            fullName: _name.text,
            grade: _grade,
            preferredLanguage: _answerLang,
            subjects: _subjects.toList(),
          );
      ref.invalidate(profileProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(savedMsg)));
      context.go('/profile');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(friendlyError(e))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
                labelText: ref.tr('full_name'),
                prefixIcon: const Icon(Icons.person_outline_rounded)),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? ref.tr('required') : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _grade,
            isExpanded: true,
            decoration: InputDecoration(
                labelText: ref.tr('grade'),
                prefixIcon: const Icon(Icons.school_outlined)),
            items: [
              for (final g in gradeOptions)
                DropdownMenuItem(value: g, child: Text(g)),
            ],
            onChanged: (v) => setState(() => _grade = v),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _answerLang,
            isExpanded: true,
            decoration: InputDecoration(
                labelText: ref.tr('answer_language'),
                prefixIcon: const Icon(Icons.translate_rounded)),
            items: [
              for (final e in answerLanguageOptions.entries)
                DropdownMenuItem(value: e.key, child: Text(e.value)),
            ],
            onChanged: (v) => setState(() => _answerLang = v ?? 'english'),
          ),
          const SizedBox(height: 20),
          Text(ref.tr('subjects'),
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final s in subjectOptions)
                FilterChip(
                  label: Text(s),
                  selected: _subjects.contains(s),
                  onSelected: (on) => setState(
                      () => on ? _subjects.add(s) : _subjects.remove(s)),
                ),
            ],
          ),
          const SizedBox(height: 28),
          LoadingButton(
              label: ref.tr('save'), onPressed: _save, loading: _saving),
        ],
      ),
    );
  }
}
