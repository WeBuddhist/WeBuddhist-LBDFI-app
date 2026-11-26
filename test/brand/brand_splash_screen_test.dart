import 'package:flutter/material.dart';
import 'package:flutter_pecha/brand/brand.dart';
import 'package:flutter_pecha/brand/brand_splash_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget splash) =>
      tester.pumpWidget(MaterialApp(home: splash));

  testWidgets('shows the emblem and full name, still, for 3 seconds', (
    tester,
  ) async {
    var done = 0;
    await pump(tester, BrandSplashScreen(onIntroComplete: () => done++));

    expect(find.text(Brand.fullName), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    // Nothing animates: once the first frames are drawn, none is scheduled
    // while it waits.
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.binding.hasScheduledFrame, isFalse);

    await tester.pump(const Duration(milliseconds: 2800));
    expect(done, 0);
    await tester.pump(const Duration(milliseconds: 200));
    expect(done, 1);
  });

  testWidgets('without the intro it completes at once', (tester) async {
    var done = 0;
    await pump(
      tester,
      BrandSplashScreen(playIntro: false, onIntroComplete: () => done++),
    );
    await tester.pump();
    expect(done, 1);
  });

  testWidgets('completes once if it goes away early', (tester) async {
    var done = 0;
    await pump(tester, BrandSplashScreen(onIntroComplete: () => done++));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 4));
    expect(done, 1);
  });
}
