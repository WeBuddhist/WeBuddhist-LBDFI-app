import 'package:flutter/material.dart';
import 'package:flutter_pecha/core/l10n/generated/app_localizations.dart';
import 'package:flutter_pecha/features/auth/domain/failures/login_failure.dart';
import 'package:flutter_pecha/features/auth/presentation/providers/auth_notifier.dart';
import 'package:flutter_pecha/features/auth/presentation/providers/state_providers.dart';
import 'package:flutter_pecha/features/auth/presentation/screens/profile_names_screen.dart';
import 'package:flutter_pecha/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for the auth notifier: a sign-in that is waiting for a name.
class _Auth extends StateNotifier<AuthState> implements AuthNotifier {
  _Auth() : super(const AuthState(isLoggedIn: false));

  LoginFailure? submitResult;
  final List<({String first, String last})> submitted = [];
  int cancels = 0;

  /// What `AuthNotifier` does when the exchange asks for a name.
  void askForNames() => state = state.copyWith(needsProfileNames: true);

  @override
  Future<LoginFailure?> submitProfileNames({
    required String firstName,
    required String lastName,
  }) async {
    submitted.add((first: firstName, last: lastName));
    if (submitResult == null) {
      state = state.copyWith(isLoggedIn: true, needsProfileNames: false);
    }
    return submitResult;
  }

  @override
  void cancelProfileNames() {
    cancels++;
    state = state.copyWith(needsProfileNames: false);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A screen a login starts from, as the login page and drawer are.
class _LoginHost extends ConsumerWidget {
  const _LoginHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    openProfileNamesWhenNeeded(ref, context);
    return const Scaffold(body: Text('login'));
  }
}

void main() {
  late _Auth auth;

  /// Shows the host and lets a sign-in start waiting for a name.
  Future<AppLocalizations> askForNames(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith((ref) => auth)],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: _LoginHost(),
        ),
      ),
    );
    expect(find.byType(ProfileNamesScreen), findsNothing);
    auth.askForNames();
    await tester.pumpAndSettle();
    return AppLocalizations.of(
      tester.element(find.byType(ProfileNamesScreen)),
    )!;
  }

  Future<void> enterNames(
    WidgetTester tester,
    AppLocalizations l10n, {
    required String first,
    required String last,
  }) async {
    await tester.enterText(find.byType(TextField).at(0), first);
    await tester.enterText(find.byType(TextField).at(1), last);
    await tester.tap(find.text(l10n.onboarding_continue));
    await tester.pumpAndSettle();
  }

  setUp(() => auth = _Auth());

  testWidgets('opens when a sign-in starts waiting for a name', (tester) async {
    final l10n = await askForNames(tester);

    expect(find.text(l10n.login_names_title), findsOneWidget);
  });

  testWidgets('sends tidy names, and signing in closes the form', (
    tester,
  ) async {
    final l10n = await askForNames(tester);

    await enterNames(tester, l10n, first: '  Pema ', last: 'Lhamo   Dolkar');

    expect(auth.submitted.single, (first: 'Pema', last: 'Lhamo Dolkar'));
    expect(find.byType(ProfileNamesScreen), findsNothing);
    expect(find.text('login'), findsOneWidget);
    // Closed by the sign-in, not by the person: nothing to cancel.
    expect(auth.cancels, 0);
  });

  testWidgets('both names are required', (tester) async {
    final l10n = await askForNames(tester);

    await enterNames(tester, l10n, first: 'Pema', last: '');

    expect(auth.submitted, isEmpty);
    expect(find.text(l10n.login_names_required), findsOneWidget);
  });

  testWidgets('a name with digits or symbols is not sent', (tester) async {
    final l10n = await askForNames(tester);

    await enterNames(tester, l10n, first: 'Pema', last: 'Lhamo99');

    expect(auth.submitted, isEmpty);
    expect(find.text(l10n.person_name_invalid_chars), findsOneWidget);
  });

  testWidgets('a failure worth retrying keeps the form open', (tester) async {
    auth.submitResult = const LoginFailure('x', LoginFailureReason.network);
    final l10n = await askForNames(tester);

    await enterNames(tester, l10n, first: 'Pema', last: 'Lhamo');

    expect(find.text(l10n.login_error_network), findsOneWidget);
    expect(find.text(l10n.onboarding_continue), findsOneWidget);
  });

  testWidgets('a sign-in too old to finish can only go back', (tester) async {
    auth.submitResult = const LoginFailure(
      'x',
      LoginFailureReason.pendingLoginExpired,
    );
    final l10n = await askForNames(tester);

    await enterNames(tester, l10n, first: 'Pema', last: 'Lhamo');

    expect(find.text(l10n.login_error_session_expired), findsOneWidget);
    expect(find.text(l10n.onboarding_continue), findsNothing);

    await tester.tap(find.text(l10n.back));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileNamesScreen), findsNothing);
    // Already over: there is no waiting sign-in left to cancel.
    expect(auth.cancels, 0);
  });

  testWidgets('going back drops the waiting sign-in', (tester) async {
    await askForNames(tester);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(ProfileNamesScreen), findsNothing);
    expect(auth.cancels, 1);
    expect(auth.state.needsProfileNames, isFalse);
  });
}
