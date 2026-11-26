import 'package:dio/dio.dart';
import 'package:flutter_pecha/brand/brand.dart';
import 'package:flutter_pecha/core/di/core_providers.dart';
import 'package:flutter_pecha/env.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Finds the library tag that marks chants, so no build has to carry its id.
///
/// The library's `GET /v2/tags` lists every tag with a localized title; the
/// chants tag is the one whose English title is [chantsTitle]. A build that
/// sets `LIBRARY_CHANTS_TAG_ID` skips the lookup and uses that id.
///
/// A found id is kept for the life of the object (one app session). A failed
/// request is not kept, so the next chant list load asks again.
class ChantsTagLookup {
  ChantsTagLookup({required Dio dio, String? configuredId})
    : _dio = dio,
      _configuredId = configuredId;

  /// English title of the chants tag in the library.
  static const String chantsTitle = 'Chants';

  final Dio _dio;
  final String? _configuredId;
  String? _found;
  Future<String?>? _pending;

  /// The chants tag id, or null when the library has no tag of that title.
  /// Throws when the tag list cannot be read.
  Future<String?> resolve() {
    final configured = _configuredId;
    if (configured != null) return Future.value(configured);
    final found = _found;
    if (found != null) return Future.value(found);
    return _pending ??= _fetch().whenComplete(() => _pending = null);
  }

  Future<String?> _fetch() async {
    final response = await _dio.get<List<dynamic>>(
      '/v2/tags',
      // The library requires the application on this endpoint. LBDFI reads
      // the shared WeBuddhist library, so it names WeBuddhist here.
      options: Options(headers: {'X-Application': Brand.libraryApplicationId}),
    );
    for (final tag in response.data ?? const []) {
      if (tag is! Map) continue;
      final title = tag['title'];
      final english = title is Map ? title['en'] : null;
      if (english is String &&
          english.trim().toLowerCase() == chantsTitle.toLowerCase()) {
        final id = tag['id'];
        if (id is String && id.isNotEmpty) return _found = id;
      }
    }
    return null;
  }
}

/// One lookup per app session, shared by every chant list.
final chantsTagLookupProvider = Provider<ChantsTagLookup>((ref) {
  return ChantsTagLookup(
    dio: ref.watch(libraryDioProvider),
    configuredId: Env.libraryChantsTagId,
  );
});
