import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The backend's own tokens: the app session since sign-in moved to Firebase.
class SessionTokens {
  const SessionTokens({required this.accessToken, required this.refreshToken});

  /// API bearer. A JWT whose `sub` is the backend user id.
  final String accessToken;

  /// Sent to `POST /auth/refresh-token` for a new [accessToken].
  final String refreshToken;

  SessionTokens withAccessToken(String accessToken) =>
      SessionTokens(accessToken: accessToken, refreshToken: refreshToken);
}

/// Where the session tokens are kept on the device.
abstract class SessionTokenStore {
  /// null when nothing is stored. Throws when the store could not be read,
  /// which says nothing about whether a session exists.
  Future<SessionTokens?> read();

  Future<void> write(SessionTokens tokens);

  Future<void> clear();
}

/// Keychain (iOS) / encrypted storage (Android), with the tokens held in
/// memory after the first read so requests do not hit the keystore each time.
///
/// The pair is kept as **one** value. Two separate entries could be left half
/// replaced by a failed or interrupted write: one account's access token
/// beside another's refresh token, which the next refresh would turn into a
/// silent switch of account.
class SecureSessionTokenStore implements SessionTokenStore {
  SecureSessionTokenStore([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            // Readable by background work (push handling) on a locked phone.
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  static const sessionKey = 'session_tokens';
  static const _accessField = 'access_token';
  static const _refreshField = 'refresh_token';

  final FlutterSecureStorage _storage;

  SessionTokens? _cached;
  bool _loaded = false;

  @override
  Future<SessionTokens?> read() async {
    if (_loaded) return _cached;
    _cached = _decode(await _storage.read(key: sessionKey));
    _loaded = true;
    return _cached;
  }

  @override
  Future<void> write(SessionTokens tokens) async {
    // Memory first: the session is usable even if the keystore write fails,
    // and then only the next launch asks for a sign-in.
    _cached = tokens;
    _loaded = true;
    await _storage.write(
      key: sessionKey,
      value: jsonEncode({
        _accessField: tokens.accessToken,
        _refreshField: tokens.refreshToken,
      }),
    );
  }

  @override
  Future<void> clear() async {
    _cached = null;
    _loaded = true;
    await _storage.delete(key: sessionKey);
  }

  /// null for nothing stored, or a value that is not a complete pair.
  static SessionTokens? _decode(String? stored) {
    if (stored == null || stored.isEmpty) return null;
    try {
      final json = jsonDecode(stored);
      if (json is! Map) return null;
      final accessToken = json[_accessField];
      final refreshToken = json[_refreshField];
      if (accessToken is! String ||
          accessToken.isEmpty ||
          refreshToken is! String ||
          refreshToken.isEmpty) {
        return null;
      }
      return SessionTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } catch (_) {
      return null;
    }
  }
}
