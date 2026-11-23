import 'package:flutter_pecha/core/l10n/generated/app_localizations.dart';
import 'package:flutter_pecha/features/auth/domain/failures/login_failure.dart';

/// What to tell the person about a failed sign-in step, or null when there
/// is nothing to say: they cancelled, or the name form is taking over.
String? loginFailureText(AppLocalizations l10n, LoginFailureReason reason) {
  return switch (reason) {
    LoginFailureReason.cancelled ||
    LoginFailureReason.profileNamesRequired => null,
    LoginFailureReason.invalidPhoneNumber => l10n.login_error_invalid_phone,
    LoginFailureReason.invalidCode => l10n.login_error_invalid_code,
    LoginFailureReason.codeExpired => l10n.login_error_code_expired,
    LoginFailureReason.tooManyRequests => l10n.login_error_too_many_requests,
    LoginFailureReason.network => l10n.login_error_network,
    LoginFailureReason.emailNotVerified => l10n.login_error_email_not_verified,
    LoginFailureReason.pendingLoginExpired => l10n.login_error_session_expired,
    LoginFailureReason.notConfigured ||
    LoginFailureReason.unknown => l10n.login_error_generic,
  };
}
