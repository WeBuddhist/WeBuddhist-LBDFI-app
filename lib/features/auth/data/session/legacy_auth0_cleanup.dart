import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_pecha/core/storage/storage_keys.dart';
import 'package:flutter_pecha/core/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sign-in moved from Auth0 to Firebase, and the backend's own tokens became
/// the session. A phone updated from an Auth0 build still holds an Auth0
/// session this build cannot use, so it is removed once and the person signs
/// in again. Same as the web app's `clearLegacyAuth0Session`.
///
/// This is the only use of `auth0_flutter` left. Drop the package, this class
/// and the Auth0 entries in the Android manifest, `build.gradle.kts` and
/// `Info.plist` once builds older than the switch are no longer supported.
abstract class LegacyAuth0Cleanup {
  /// Returns true when an Auth0 session was found and removed. Never throws.
  Future<bool> run();
}

class LegacyAuth0CleanupImpl implements LegacyAuth0Cleanup {
  LegacyAuth0CleanupImpl({
    Future<void> Function(String domain, String clientId)? clearAuth0Credentials,
  }) : _clearAuth0Credentials =
           clearAuth0Credentials ?? _clearWithCredentialsManager;

  /// Set once the cleanup has run, so it never runs again.
  static const doneKey = 'legacy_auth0_session_cleared';

  /// Where Auth0 builds cached the tenant config from `/props`. Present on
  /// any phone that ever opened one online, so it also tells an update from a
  /// fresh install.
  static const cachedDomainKey = 'auth0_cfg_domain';
  static const cachedClientIdKey = 'auth0_cfg_client_id';
  static const cachedAudienceKey = 'auth0_cfg_audience';

  final Future<void> Function(String domain, String clientId)
  _clearAuth0Credentials;
  final _logger = AppLogger('LegacyAuth0Cleanup');

  @override
  Future<bool> run() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(doneKey) == true) return false;

      final domain = prefs.getString(cachedDomainKey);
      final clientId = prefs.getString(cachedClientIdKey);
      final hadAuth0 = domain != null && clientId != null;
      if (hadAuth0) {
        // Local only: clears the Keychain / encrypted storage entry. It does
        // not call Auth0, so it works offline and after the tenant is gone.
        await _clearAuth0Credentials(domain, clientId);
        // Markers of the signed-in Auth0 account. The user id was the Auth0
        // subject (`google-oauth2|…`); the new one is the backend user id.
        await prefs.remove(StorageKeys.currentUserId);
        await prefs.remove(StorageKeys.userData);
        await prefs.remove(cachedDomainKey);
        await prefs.remove(cachedClientIdKey);
        await prefs.remove(cachedAudienceKey);
        _logger.info('Removed the Auth0 session left by an earlier build');
      }
      await prefs.setBool(doneKey, true);
      return hadAuth0;
    } catch (e) {
      // Not marked done, so the next launch tries again.
      _logger.warning('Could not remove the earlier Auth0 session: $e');
      return false;
    }
  }

  static Future<void> _clearWithCredentialsManager(
    String domain,
    String clientId,
  ) async {
    await Auth0(domain, clientId).credentialsManager.clearCredentials();
  }
}
