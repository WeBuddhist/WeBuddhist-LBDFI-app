import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  testWidgets('stays white with dark status bar icons in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        home: const BrandSplashScreen(playIntro: false),
      ),
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, Colors.white);
    final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.byType(AnnotatedRegion<SystemUiOverlayStyle>).first,
    );
    expect(region.value.statusBarIconBrightness, Brightness.dark);
    expect(region.value.statusBarBrightness, Brightness.light);
  });

  testWidgets('hands the status bar back to dark mode when it goes', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        home: const BrandSplashScreen(playIntro: false),
      ),
    );
    await tester.pump();
    expect(SystemChrome.latestStyle?.statusBarIconBrightness, Brightness.dark);

    // Like the router leaving the splash: the app itself does not rebuild,
    // and the next screen has no app bar, so it sets no style of its own.
    navigator.currentState!.pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const Scaffold()),
    );
    await tester.pumpAndSettle();
    expect(find.byType(BrandSplashScreen), findsNothing);
    expect(SystemChrome.latestStyle?.statusBarIconBrightness, Brightness.light);
    expect(SystemChrome.latestStyle?.statusBarBrightness, Brightness.dark);
  });
}
