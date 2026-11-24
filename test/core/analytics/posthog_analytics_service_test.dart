import 'package:flutter_pecha/core/analytics/clarity_screen_observer.dart';
import 'package:flutter_pecha/core/analytics/posthog_analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('an event with a group id carries the sangha in \$groups', () {
    expect(
      PostHogAnalyticsService.withSanghaGroup({'group_id': 'g1', 'x': 1}),
      {
        'group_id': 'g1',
        'x': 1,
        r'$groups': {'sangha': 'g1'},
      },
    );
  });

  test('events without a group id are untouched', () {
    expect(PostHogAnalyticsService.withSanghaGroup({'x': 1}), {'x': 1});
    expect(PostHogAnalyticsService.withSanghaGroup({'group_id': ''}), {
      'group_id': '',
    });
    expect(PostHogAnalyticsService.withSanghaGroup(null), isNull);
  });

  test('screens come from the screen tracker, not PosthogObserver', () {
    final observers = PostHogAnalyticsService.instance.routeObservers;

    // PosthogObserver stays only for the context surveys are shown in.
    expect(observers.whereType<PosthogObserver>(), hasLength(1));
    expect(observers.whereType<ClarityScreenObserver>(), hasLength(1));
  });
}
