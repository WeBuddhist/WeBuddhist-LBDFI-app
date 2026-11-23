import 'package:equatable/equatable.dart';
import 'package:flutter_pecha/features/auth/domain/entities/auth_credentials.dart';

/// What happened after a phone number was submitted for sign-in.
class PhoneCodeStart extends Equatable {
  /// An SMS code went out; finish with it and [verificationId].
  const PhoneCodeStart.codeSent({
    required String this.verificationId,
    this.resendToken,
  }) : credentials = null;

  /// The number was verified without a code (Android can do this), so the
  /// sign-in is already complete.
  const PhoneCodeStart.signedIn(AuthCredentials this.credentials)
    : verificationId = null,
      resendToken = null;

  final String? verificationId;

  /// Pass back when asking for the code again.
  final int? resendToken;

  final AuthCredentials? credentials;

  bool get isSignedIn => credentials != null;

  @override
  List<Object?> get props => [verificationId, resendToken, credentials];
}
