import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_config.dart';
import '../../core/l10n/strings.dart';
import '../../core/services/errors.dart';
import '../../core/state/providers.dart';
import '../../core/state/settings_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _checkingAi = false;

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _testAi() async {
    setState(() => _checkingAi = true);
    try {
      _snack(await ref.read(aiServiceProvider).ping());
    } catch (e) {
      _snack(friendlyError(e));
    } finally {
      if (mounted) setState(() => _checkingAi = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await ref.read(authRepoProvider).signOut();
    } catch (e) {
      _snack(friendlyError(e));
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ref.trRead('delete_title')),
        content: Text(ref.trRead('delete_body')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(ref.trRead('cancel'))),
          TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(ctx).colorScheme.error),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(ref.trRead('delete'))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(authRepoProvider).deleteAccount();
      // Router redirect sends the user to the login screen.
    } catch (e) {
      _snack(friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final guest = settings.guest;
    final profileAsync = ref.watch(profileProvider);
    final scheme = Theme.of(context).colorScheme;

    final profile = guest ? null : profileAsync.valueOrNull;
    final displayName = guest
        ? ref.tr('guest_name')
        : (profile?.fullName.isNotEmpty == true
            ? profile!.fullName
            : ref.tr('student'));

    return Scaffold(
      appBar: AppBar(title: Text(ref.tr('profile'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          // Header
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.royalBlue,
                  child: Text(guest ? 'G' : (profile?.initials ?? 'S'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      if (!guest && profile?.email != null)
                        Text(profile!.email!,
                            style: TextStyle(
                                color: scheme.onSurface.withAlpha(160))),
                      if (!guest && profile?.grade != null)
                        Text(profile!.grade!,
                            style: TextStyle(color: scheme.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!guest && profileAsync.hasError && profile == null) ...[
            const SizedBox(height: 12),
            AppCard(
              child: Row(children: [
                const Icon(Icons.error_outline_rounded),
                const SizedBox(width: 12),
                Expanded(child: Text(friendlyError(profileAsync.error!))),
                TextButton(
                    onPressed: () => ref.invalidate(profileProvider),
                    child: const Text('Retry')),
              ]),
            ),
          ],
          if (guest) ...[
            const SizedBox(height: 12),
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
          ],
          const SizedBox(height: 20),

          // Appearance
          _SectionTitle(ref.tr('appearance')),
          AppCard(
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(ref.tr('theme_system'))),
                  ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(ref.tr('theme_light'))),
                  ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(ref.tr('theme_dark'))),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (s) =>
                    ref.read(settingsProvider.notifier).setThemeMode(s.first),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Language
          _SectionTitle(ref.tr('language')),
          AppCard(
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<AppLang>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: AppLang.english, label: Text('English')),
                  ButtonSegment(value: AppLang.urdu, label: Text('اردو')),
                  ButtonSegment(
                      value: AppLang.romanUrdu, label: Text('Roman Urdu')),
                ],
                selected: {settings.lang},
                onSelectionChanged: (s) =>
                    ref.read(settingsProvider.notifier).setLang(s.first),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Account
          _SectionTitle(ref.tr('account')),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                if (!guest)
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: Text(ref.tr('edit_profile')),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.go('/profile/edit'),
                  ),
                ListTile(
                  leading: _checkingAi
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.4))
                      : const Icon(Icons.auto_awesome_outlined),
                  title: Text(ref.tr('ai_check')),
                  subtitle: Text(guest
                      ? ref.tr('ai_needs_account')
                      : ref.tr('ai_check_sub')),
                  enabled: !guest && !_checkingAi,
                  onTap: _testAi,
                ),
                if (!guest)
                  ListTile(
                    leading: const Icon(Icons.logout_rounded),
                    title: Text(ref.tr('sign_out')),
                    onTap: _signOut,
                  ),
                if (!guest)
                  ListTile(
                    leading: Icon(Icons.delete_forever_outlined,
                        color: scheme.error),
                    title: Text(ref.tr('delete_account'),
                        style: TextStyle(color: scheme.error)),
                    onTap: _deleteAccount,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text('${AppConfig.appName} v${AppConfig.version}',
                style: TextStyle(color: scheme.onSurface.withAlpha(120))),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(text,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: .4,
                color: Theme.of(context).colorScheme.primary)),
      );
}
