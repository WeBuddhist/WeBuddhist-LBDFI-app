import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_pecha/core/cache/screen_cache/screen_cache_key.dart';
import 'package:flutter_pecha/core/cache/screen_cache/screen_cache_providers.dart';
import 'package:flutter_pecha/core/cache/screen_cache/screen_cache_store.dart';
import 'package:flutter_pecha/core/utils/app_logger.dart';
import 'package:flutter_pecha/features/auth/presentation/providers/state_providers.dart';
import 'package:flutter_pecha/features/onboarding/data/datasource/onboarding_remote_datasource.dart';
import 'package:flutter_pecha/features/onboarding/presentation/providers/onboarding_datasource_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _logger = AppLogger('UserTraditionCodes');

/// Sorted tradition codes (`pali`, `chinese`, `tibetan`) the signed-in user
/// follows. Empty for guests, signed-out users, and a failed lookup with
/// nothing stored.
///
/// Feeds the backend narrows by the caller's saved traditions (poems) key
/// their stored pages by these codes and re-fetch when they change.
///
/// Same lifecycle as `traditionTagFilterProvider`: loading only while auth is
/// unknown or on a user's first resolution; after that the stored codes are
/// the first value and the server's replace them if they changed. Kept alive
/// so the lookup runs once per session. Invalidate it after the user's
/// traditions change.
final userTraditionCodesProvider =
    AsyncNotifierProvider<UserTraditionCodesNotifier, List<String>>(
      UserTraditionCodesNotifier.new,
    );

class UserTraditionCodesNotifier extends AsyncNotifier<List<String>> {
  // Bumped per build so a resolution finishing after a rebuild is dropped.
  int _epoch = 0;

  @override
  FutureOr<List<String>> build() {
    final epoch = ++_epoch;
    final (isAuthLoading, isLoggedIn, isGuest) = ref.watch(
      authProvider.select(
        (auth) => (auth.isLoading, auth.isLoggedIn, auth.isGuest),
      ),
    );
    if (isAuthLoading) return Completer<List<String>>().future;
    if (!isLoggedIn || isGuest) return const [];

    final store = ref.watch(screenCacheStoreProvider);
    final datasource = ref.watch(onboardingRemoteDatasourceProvider);
    final key = storageKey(store);
    final stored = _readStored(store, key);
    final fresh = _resolve(datasource, store, key, fallback: stored);
    if (stored == null) return fresh;

    fresh.then((codes) {
      if (epoch == _epoch && !listEquals(codes, stored)) {
        state = AsyncData(codes);
      }
    });
    return stored;
  }

  static String storageKey(ScreenCacheStore store) => ScreenCacheKey.user(
    'tradition_codes',
    userId: store.currentUserIdSync,
    language: 'all',
  );

  static List<String>? _readStored(ScreenCacheStore store, String key) {
    final json = store.read(key);
    if (json == null) return null;
    try {
      return (jsonDecode(json) as List<dynamic>).cast<String>();
    } catch (e) {
      _logger.warning('Discarding unreadable stored tradition codes', e);
      return null;
    }
  }

  /// Never throws: a failed lookup keeps [fallback], or no traditions.
  static Future<List<String>> _resolve(
    OnboardingRemoteDatasource datasource,
    ScreenCacheStore store,
    String key, {
    required List<String>? fallback,
  }) async {
    try {
      // Codes don't depend on the language; names aren't used here.
      final selected = await datasource.fetchUserTraditions(language: 'en');
      final codes =
          selected.map((t) => t.traditionCode).toSet().toList()..sort();
      await store.save(key, jsonEncode(codes));
      return codes;
    } catch (e, stackTrace) {
      _logger.error('Resolving tradition codes failed', e, stackTrace);
      return fallback ?? const [];
    }
  }
}
