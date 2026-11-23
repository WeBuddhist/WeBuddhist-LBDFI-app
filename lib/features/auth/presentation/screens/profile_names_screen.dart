import 'package:flutter/material.dart';
import 'package:flutter_pecha/core/extensions/context_ext.dart';
import 'package:flutter_pecha/features/auth/domain/failures/login_failure.dart';
import 'package:flutter_pecha/features/auth/presentation/providers/state_providers.dart';
import 'package:flutter_pecha/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_pecha/features/auth/presentation/utils/login_failure_text.dart';
import 'package:flutter_pecha/features/auth/presentation/widgets/login_form_widgets.dart';
import 'package:flutter_pecha/shared/domain/validators/person_name_validator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens [ProfileNamesScreen] when a sign-in starts waiting for a name. Call
/// from the `build` of the screens a login can start from (the login page and
/// the login drawer), which stay mounted underneath while it runs.
void openProfileNamesWhenNeeded(WidgetRef ref, BuildContext context) {
  ref.listen<AuthState>(authProvider, (previous, next) {
    if (!next.needsProfileNames || (previous?.needsProfileNames ?? false)) {
      return;
    }
    if (!context.mounted) return;
    ProfileNamesScreen.open(context);
  });
}

/// Asked for when the account signing in is new and the provider shared no
/// name: the backend needs a first and last name to create the profile.
/// Phone sign-ups always land here; Google and Apple rarely do.
class ProfileNamesScreen extends ConsumerStatefulWidget {
  const ProfileNamesScreen({super.key});

  /// Opens above everything, including the phone sign-in screen.
  static Future<void> open(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'login_profile_names'),
        builder: (_) => const ProfileNamesScreen(),
      ),
    );
  }

  @override
  ConsumerState<ProfileNamesScreen> createState() => _ProfileNamesScreenState();
}

class _ProfileNamesScreenState extends ConsumerState<ProfileNamesScreen>
    with CloseWhenSignedIn {
  final _firstController = TextEditingController();
  final _lastController = TextEditingController();
  final _lastFocus = FocusNode();

  bool _busy = false;
  bool _showRequired = false;
  LoginFailureReason? _error;

  /// False once the sign-in finished or expired, so leaving does not cancel
  /// a login that is already through.
  bool _waiting = true;

  @override
  void dispose() {
    _firstController.dispose();
    _lastController.dispose();
    _lastFocus.dispose();
    super.dispose();
  }

  String? _fieldError(String value) {
    final l10n = context.l10n;
    if (PersonNameValidator.sanitize(value) == null) {
      return _showRequired ? l10n.login_names_required : null;
    }
    return PersonNameValidator.validate(value) == null
        ? null
        : l10n.person_name_invalid_chars;
  }

  Future<void> _submit() async {
    if (_busy) return;
    final first = PersonNameValidator.sanitize(_firstController.text);
    final last = PersonNameValidator.sanitize(_lastController.text);
    if (first == null ||
        last == null ||
        !PersonNameValidator.isValid(first) ||
        !PersonNameValidator.isValid(last)) {
      setState(() => _showRequired = true);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    final failure = await ref
        .read(authProvider.notifier)
        .submitProfileNames(firstName: first, lastName: last);
    if (!mounted) return;
    // Signed in: the screen is closing, keep the spinner until it does.
    if (failure == null) {
      _waiting = false;
      return;
    }
    setState(() {
      _busy = false;
      _error = failure.reason;
      // Too old to finish: only starting the sign-in again helps.
      if (failure.reason == LoginFailureReason.pendingLoginExpired) {
        _waiting = false;
      }
    });
  }

  void _onLeave() {
    if (_waiting) ref.read(authProvider.notifier).cancelProfileNames();
  }

  @override
  Widget build(BuildContext context) {
    closeWhenSignedIn();
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final error = _error == null ? null : loginFailureText(l10n, _error!);
    final expired = _error == LoginFailureReason.pendingLoginExpired;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _onLeave();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LoginFormHeader(
                    title: l10n.login_names_title,
                    subtitle: l10n.login_names_subtitle,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _firstController,
                    enabled: !_busy && !expired,
                    autofocus: true,
                    maxLength: PersonNameValidator.maxLength,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.givenName],
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _lastFocus.requestFocus(),
                    decoration: loginFieldDecoration(
                      context,
                      hintText: l10n.login_first_name,
                      errorText: _fieldError(_firstController.text),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _lastController,
                    focusNode: _lastFocus,
                    enabled: !_busy && !expired,
                    maxLength: PersonNameValidator.maxLength,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.familyName],
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _submit(),
                    decoration: loginFieldDecoration(
                      context,
                      hintText: l10n.login_last_name,
                      errorText: _fieldError(_lastController.text),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      error,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  LoginFormButton(
                    label: expired ? l10n.back : l10n.onboarding_continue,
                    busy: _busy,
                    onPressed:
                        expired ? () => Navigator.of(context).pop() : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
