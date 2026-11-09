import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/strings.dart';
import '../../core/services/errors.dart';
import '../../core/state/providers.dart';
import '../../core/state/settings_controller.dart';
import '../../core/widgets/common_widgets.dart';
import 'auth_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepoProvider).signIn(_email.text, _password.text);
      await ref.read(settingsProvider.notifier).setGuest(false);
      // Router redirect moves to /home when the session appears.
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
      title: ref.tr('welcome_back'),
      tagline: ref.tr('tagline'),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
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
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _submit(),
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
                  (v == null || v.isEmpty) ? ref.tr('required') : null,
            ),
            const SizedBox(height: 22),
            LoadingButton(
                label: ref.tr('sign_in'), onPressed: _submit, loading: _loading),
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
                Flexible(child: Text(ref.tr('no_account'))),
                TextButton(
                  onPressed: () => context.go('/signup'),
                  child: Text(ref.tr('sign_up')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
