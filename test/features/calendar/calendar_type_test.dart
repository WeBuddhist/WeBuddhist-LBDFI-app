import 'package:dio/dio.dart';
import 'package:flutter_pecha/core/storage/storage_keys.dart';
import 'package:flutter_pecha/core/storage/storage_service.dart';
import 'package:flutter_pecha/features/calendar/data/datasource/calendar_remote_datasource.dart';
import 'package:flutter_pecha/features/calendar/domain/models/calendar_type.dart';
import 'package:flutter_pecha/features/calendar/presentation/providers/calendar_type_providers.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records each request and answers with [reply].
class _Recorder extends Interceptor {
  _Recorder(this.reply);

  final Object? reply;
  final requests = <RequestOptions>[];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requests.add(options);
    handler.resolve(
      Response(requestOptions: options, statusCode: 200, data: reply),
    );
  }
}

class _MemoryStorage implements StorageService {
  _MemoryStorage([Map<String, Object?>? values]) : values = {...?values};

  final Map<String, Object?> values;

  @override
  Future<T?> get<T>(String key) async => values[key] as T?;

  @override
  Future<bool> set<T>(String key, T value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> delete(String key) async => values.remove(key) != null;

  @override
  Future<bool> clear() async {
    values.clear();
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// `GET /calendar/types` as production serves it.
const _apiTypes = [
  {
    'tradition': 'vajrayana',
    'types': ['phugpa', 'tsurphu', 'nyingmapa'],
  },
  {
    'tradition': 'theravada',
    'types': ['sinhalese', 'thai', 'burmese', 'lao'],
  },
  {
    'tradition': 'mahayana',
    'types': ['chinese', 'vietnamese', 'korean', 'japanese'],
  },
];

Map<String, List<String>> _asMap(List<CalendarTradition> traditions) => {
  for (final t in traditions) t.code: t.types,
};

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('calendar types', () {
    test('parse by tradition, skipping malformed rows', () {
      final parsed = CalendarTradition.listFromJson([
        ..._apiTypes,
        {'tradition': '', 'types': <String>[]},
        {
          'types': <String>['x'],
        },
        'junk',
      ]);
      expect(parsed.map((t) => t.code), ['vajrayana', 'theravada', 'mahayana']);
      expect(parsed.first.types, ['phugpa', 'tsurphu', 'nyingmapa']);
    });

    test('the datasource reads GET /calendar/types', () async {
      final recorder = _Recorder(_apiTypes);
      final remote = CalendarRemoteDatasource(
        dio: Dio()..interceptors.add(recorder),
      );
      final types = await remote.fetchTypes();
      expect(recorder.requests.single.path, '/calendar/types');
      expect(types, hasLength(3));
    });

    test('month and today ask for the chosen calendar', () async {
      final recorder = _Recorder({'year': 2026, 'month': 11, 'days': []});
      final remote = CalendarRemoteDatasource(
        dio: Dio()..interceptors.add(recorder),
      );
      await remote.fetchMonthJson(2026, 11, calendarType: 'tsurphu');
      await remote.fetchMonthJson(2026, 12);
      expect(recorder.requests[0].path, '/calendar/2026/11');
      expect(recorder.requests[0].queryParameters, {
        'calendar_type': 'tsurphu',
      });
      expect(recorder.requests[1].queryParameters, {'calendar_type': 'phugpa'});
    });
  });

  group('calendar choices', () {
    final all = CalendarTradition.listFromJson(_apiTypes);

    test('only calendars the backend computes are offered', () {
      expect(_asMap(calendarChoices(all, selected: 'phugpa')), {
        'vajrayana': ['phugpa', 'tsurphu', 'nyingmapa'],
      });
    });

    test('a guest or a viewer without traditions sees every one', () {
      final guest = calendarChoices(all, selected: 'phugpa');
      final none = calendarChoices(
        all,
        selected: 'phugpa',
        userTraditions: const {},
      );
      expect(_asMap(none), _asMap(guest));
    });

    test('a viewer sees only their own traditions', () {
      final everything = [
        for (final t in all)
          CalendarTradition(code: t.code, types: [...t.types, 'phugpa']),
      ];
      // Pretend every tradition had a supported calendar.
      final choices = calendarChoices(
        everything,
        selected: 'tsurphu',
        userTraditions: const {'tibetan'},
      );
      expect(choices.map((t) => t.code), ['vajrayana']);
    });

    test('the current calendar stays listed outside the viewer traditions', () {
      final choices = calendarChoices(
        all,
        selected: 'nyingmapa',
        userTraditions: const {'pali'},
      );
      expect(_asMap(choices), {
        'vajrayana': ['phugpa', 'tsurphu', 'nyingmapa'],
      });
    });
  });

  group('selected calendar', () {
    test('defaults to Phugpa', () async {
      final notifier = SelectedCalendarTypeNotifier(_MemoryStorage());
      await _settle();
      expect(notifier.state, defaultCalendarType);
    });

    test('restores the stored calendar', () async {
      final notifier = SelectedCalendarTypeNotifier(
        _MemoryStorage({StorageKeys.calendarType: 'nyingmapa'}),
      );
      await _settle();
      expect(notifier.state, 'nyingmapa');
    });

    test('a stored calendar the app no longer supports falls back', () async {
      final notifier = SelectedCalendarTypeNotifier(
        _MemoryStorage({StorageKeys.calendarType: 'martian'}),
      );
      await _settle();
      expect(notifier.state, defaultCalendarType);
    });

    test('a pick is kept, and an unsupported one ignored', () async {
      final storage = _MemoryStorage();
      final notifier = SelectedCalendarTypeNotifier(storage);
      await notifier.select('tsurphu');
      expect(notifier.state, 'tsurphu');
      expect(storage.values[StorageKeys.calendarType], 'tsurphu');

      await notifier.select('thai');
      expect(notifier.state, 'tsurphu');
    });
  });
}
