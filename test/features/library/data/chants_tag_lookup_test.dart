import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_pecha/features/library/data/datasource/chants_tag_lookup.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._onFetch);

  final Future<ResponseBody> Function(RequestOptions options) _onFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => _onFetch(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object data, {int statusCode = 200}) =>
    ResponseBody.fromString(
      jsonEncode(data),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

// The testing library's tags, trimmed.
const _tags = [
  {
    'id': 'reYrCR4TFKpHbU8V2wH6d',
    'title': {'bo': 'བཀའ་འགྱུར།', 'en': 'Kangyur'},
  },
  {
    'id': '296WZOr8MXWteSqBBI7pl',
    'title': {'en': 'Theravāda'},
  },
  {
    'id': 'FZ5STsdU0eLvo7Nb2CpvH',
    'title': {'bo': 'ཞལ་འདོན།', 'en': 'Chants', 'zh': '課誦'},
  },
];

void main() {
  late List<RequestOptions> requests;

  ChantsTagLookup lookup(
    Future<ResponseBody> Function(RequestOptions) onFetch, {
    String? configuredId,
  }) {
    requests = [];
    final dio = Dio(BaseOptions(baseUrl: 'https://library.test/api'));
    dio.httpClientAdapter = _FakeAdapter((options) {
      requests.add(options);
      return onFetch(options);
    });
    return ChantsTagLookup(dio: dio, configuredId: configuredId);
  }

  test('finds the tag titled Chants and asks only once', () async {
    final l = lookup((_) async => _json(_tags));

    expect(await l.resolve(), 'FZ5STsdU0eLvo7Nb2CpvH');
    expect(await l.resolve(), 'FZ5STsdU0eLvo7Nb2CpvH');
    expect(requests, hasLength(1));
    expect(requests.single.path, '/v2/tags');
    expect(requests.single.headers['X-Application'], 'webuddhist');
  });

  test('concurrent callers share one request', () async {
    final l = lookup((_) async => _json(_tags));

    final ids = await Future.wait([l.resolve(), l.resolve()]);
    expect(ids, ['FZ5STsdU0eLvo7Nb2CpvH', 'FZ5STsdU0eLvo7Nb2CpvH']);
    expect(requests, hasLength(1));
  });

  test('a configured id skips the lookup', () async {
    final l = lookup((_) async => _json(_tags), configuredId: 'configured');

    expect(await l.resolve(), 'configured');
    expect(requests, isEmpty);
  });

  test('null when no tag is titled Chants', () async {
    final l = lookup((_) async => _json(_tags.take(2).toList()));

    expect(await l.resolve(), isNull);
  });

  test('a failed request is retried on the next call', () async {
    var calls = 0;
    final l = lookup((_) async {
      calls++;
      return calls == 1
          ? _json({'detail': 'down'}, statusCode: 503)
          : _json(_tags);
    });

    await expectLater(l.resolve(), throwsA(isA<DioException>()));
    expect(await l.resolve(), 'FZ5STsdU0eLvo7Nb2CpvH');
    expect(requests, hasLength(2));
  });
}
