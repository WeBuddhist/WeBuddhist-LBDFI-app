import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_pecha/core/error/exceptions.dart';
import 'package:flutter_pecha/features/home/data/datasource/home_local_datasource.dart';
import 'package:flutter_pecha/features/home/data/datasource/verse_of_day_remote_datasource.dart';
import 'package:flutter_pecha/features/home/data/models/verse_of_day_model.dart';
import 'package:flutter_pecha/features/home/data/repositories/verse_of_day_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory stand-in for the Hive-backed store.
class _FakeLocal extends HomeLocalDatasource {
  final entries = <String, VerseOfDayCacheEntry>{};
  final today = <String, VerseOfDayModel>{};
  List<String>? dates;
  final _changes = StreamController<void>.broadcast();

  @override
  Stream<void> watchKey(String key) => _changes.stream;

  @override
  VerseOfDayModel? readVerseOfDay(String language) => today[language];

  @override
  Future<void> saveVerseOfDay(String language, VerseOfDayModel verse) async {
    today[language] = verse;
  }

  @override
  VerseOfDayCacheEntry? readVerseOfDayEntry(String language, String date) =>
      entries['$language:$date'];

  @override
  Future<void> saveVerseOfDayEntry(
    String language,
    String date,
    VerseOfDayCacheEntry entry,
  ) async {
    entries['$language:$date'] = entry;
  }

  @override
  List<String>? readRecentVerseDates(String language) => dates;

  @override
  Future<void> saveRecentVerseDates(String language, List<String> dates) async {
    this.dates = [...dates];
    _changes.add(null);
  }
}

class _FakeRemote extends VerseOfDayRemoteDatasource {
  _FakeRemote() : super(dio: Dio());

  VerseOfDayModel? todayVerse;
  Exception? todayError;
  final byDate = <String, VerseOfDayModel>{};
  final dateErrors = <String, Exception>{};
  final dateCalls = <String>[];

  @override
  Future<VerseOfDayModel?> fetchVerseOfDay({required String language}) async {
    if (todayError != null) throw todayError!;
    return todayVerse;
  }

  @override
  Future<VerseOfDayModel?> fetchVerseOfDayByDate({
    required String language,
    required String date,
  }) async {
    dateCalls.add(date);
    final error = dateErrors[date];
    if (error != null) throw error;
    return byDate[date];
  }
}

VerseOfDayModel _verse(String date) => VerseOfDayModel(
  id: 'id-$date',
  verse: 'Verse for $date',
  imageUrl: 'https://example.com/$date.webp',
  refId: '',
  refType: '',
  date: date,
);

void main() {
  late _FakeLocal local;
  late _FakeRemote remote;
  late DateTime now;
  late VerseOfDayRepository repository;

  setUp(() {
    local = _FakeLocal();
    remote = _FakeRemote();
    now = DateTime(2026, 11, 10, 9);
    repository = VerseOfDayRepository(
      remote: remote,
      local: local,
      now: () => now,
    );
  });

  test('anchors on the server\'s date and skips days with no verse', () async {
    // Server is already on the 11th while the device is on the 10th.
    remote.todayVerse = _verse('2026-11-11');
    for (final date in ['2026-11-10', '2026-11-08', '2026-11-05']) {
      remote.byDate[date] = _verse(date);
    }

    final result = await repository.refreshRecentVerses(language: 'en');

    expect(result.isRight(), isTrue);
    expect(remote.dateCalls.toSet(), {
      '2026-11-10',
      '2026-11-09',
      '2026-11-08',
      '2026-11-07',
      '2026-11-06',
      '2026-11-05',
    });
    expect(local.readRecentVerses('en')!.map((v) => v.date), [
      '2026-11-11',
      '2026-11-10',
      '2026-11-08',
      '2026-11-05',
    ]);
    expect(local.today['en']?.date, '2026-11-11');
  });

  test('uses the device date when nothing is published today', () async {
    remote.byDate['2026-11-09'] = _verse('2026-11-09');

    await repository.refreshRecentVerses(language: 'en');

    expect(local.dates!.first, '2026-11-10');
    expect(local.readRecentVerses('en')!.map((v) => v.date), ['2026-11-09']);
  });

  test('does not re-fetch past days fetched within 23 hours', () async {
    remote.todayVerse = _verse('2026-11-10');
    remote.byDate['2026-11-09'] = _verse('2026-11-09');
    await repository.refreshRecentVerses(language: 'en');
    remote.dateCalls.clear();

    now = now.add(const Duration(hours: 22));
    await repository.refreshRecentVerses(language: 'en');
    expect(remote.dateCalls, isEmpty);

    // A day later the presigned image links are about to expire.
    now = now.add(const Duration(hours: 2));
    await repository.refreshRecentVerses(language: 'en');
    expect(remote.dateCalls, hasLength(6));
  });

  test('a failed past day keeps its old entry', () async {
    remote.todayVerse = _verse('2026-11-10');
    remote.byDate['2026-11-09'] = _verse('2026-11-09');
    await repository.refreshRecentVerses(language: 'en');

    now = now.add(const Duration(days: 1));
    remote.dateErrors['2026-11-09'] = const NetworkException('offline');
    final result = await repository.refreshRecentVerses(language: 'en');

    expect(result.isRight(), isTrue);
    expect(
      local.readRecentVerses('en')!.map((v) => v.date),
      contains('2026-11-09'),
    );
  });

  test('a failed today call fails the refresh and stores nothing', () async {
    remote.todayError = const NetworkException('offline');

    final result = await repository.refreshRecentVerses(language: 'en');

    expect(result.isLeft(), isTrue);
    expect(local.dates, isNull);
  });

  test('watch yields the cached week, then the refreshed one', () async {
    local.dates = ['2026-11-09'];
    local.entries['en:2026-11-09'] = VerseOfDayCacheEntry(
      fetchedAt: now,
      verse: _verse('2026-11-09'),
    );
    remote.todayVerse = _verse('2026-11-10');

    final first = await repository
        .watchRecentVerses(language: 'en')
        .take(2)
        .toList();

    expect(
      first.map((r) => r.getOrElse((_) => []).map((v) => v.date).toList()),
      [
        ['2026-11-09'],
        ['2026-11-10', '2026-11-09'],
      ],
    );
  });

  test('watch with no cache reports a failed refresh', () async {
    remote.todayError = const NetworkException('offline');

    final first =
        await repository.watchRecentVerses(language: 'en').first;

    expect(first.isLeft(), isTrue);
  });
}
