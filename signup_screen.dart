import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/strings.dart';
import '../../core/services/errors.dart';
import '../../core/state/providers.dart';
import '../../core/state/settings_controller.dart';
import '../../core/widgets/common_widgets.dart';
import 'auth_widgets.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});
  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final confirmTitle = ref.trRead('email_confirm_title');
    final confirmBody = ref.trRead('email_confirm_body');
    final okLabel = ref.trRead('ok');
    try {
      final signedIn = await ref
          .read(authRepoProvider)
          .signUp(_name.text, _email.text, _password.text);
      if (signedIn) await ref.read(settingsProvider.notifier).setGuest(false);
      if (!signedIn && mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(confirmTitle),
            content: Text(confirmBody),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx), child: Text(okLabel)),
            ],
          ),
        );
        if (mounted) context.go('/login');
      }
      // If signedIn is true the router redirect opens /home automatically.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(friendlyError(e))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: ref.tr('create_account'),
      tagline: ref.tr('tagline'),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                  labelText: ref.tr('full_name'),
                  prefixIcon: const Icon(Icons.person_outline_rounded)),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? ref.tr('required') : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                  labelText: ref.tr('email'),
                  prefixIcon: const Icon(Icons.mail_outline_rounded)),
              validator: (v) => (v == null || !isValidEmail(v))
                  ? ref.tr('invalid_email')
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: ref.tr('password'),
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(_obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) =>
                  (v == null || v.length < 8) ? ref.tr('short_password') : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirm,
              obscureText: _obscure,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                  labelText: ref.tr('confirm_password'),
                  prefixIcon: const Icon(Icons.lock_reset_rounded)),
              validator: (v) =>
                  v != _password.text ? ref.tr('password_mismatch') : null,
            ),
            const SizedBox(height: 22),
            LoadingButton(
                label: ref.tr('create_account'),
                onPressed: _submit,
                loading: _loading),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loading
                  ? null
                  : () => ref.read(settingsProvider.notifier).setGuest(true),
              child: Text(ref.tr('guest')),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(child: Text(ref.tr('have_account'))),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(ref.tr('sign_in')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
