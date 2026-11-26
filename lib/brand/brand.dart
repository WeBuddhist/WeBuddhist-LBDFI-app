import 'package:flutter/material.dart';

/// White-label brand overlay for the LBDFI app.
///
/// This fork stays as close to WeBuddhist-app as possible so upstream releases
/// merge cleanly. Everything that makes the app LBDFI's lives here and in
/// `brand/` (artwork, palette, brief), and the shared code reads from it.
///
/// Direction A, "Heritage": Robe Maroon and LBDFI gold. See
/// `brand/BRAND_BRIEF.md` and `brand/palette.json`.
class Brand {
  Brand._();

  /// Name under the icon, on the welcome screen and in share messages.
  static const String appName = 'LBDFI';

  /// The organisation's full name, as lbdfi.org writes it. Shown under the
  /// emblem on the launch screen and the About page.
  static const String fullName = 'Light of Buddhadharma Foundation International';

  static const String websiteUrl = 'https://www.lbdfi.org/';
  static const String websiteLabel = 'www.lbdfi.org';
  static const String email = 'lbdfiorg@gmail.com';
  static const String facebookUrl = 'https://www.facebook.com/LBDFI';
  static const String youtubeUrl = 'https://www.youtube.com/@LBDFIOnline';

  /// About page text, in LBDFI's own words (lbdfi.org home and About pages,
  /// trimmed). English only: the site has no translations.
  static const List<String> aboutParagraphs = [
    'Since its founding in 2002 and the commencement of its activities in '
        '2006, LBDFI has worked to restore the Buddha Sasana in India. Starting '
        'with the first chanting of the words of the Buddha in Pali in 2006 '
        'under the sacred Bodhi Tree, LBDFI has worked to restore and '
        'revitalize the Buddhist culture of India, the Motherland of Āryadeśa.',
    'LBDFI works through four main activities: the sponsorship of '
        'international prayer ceremonies and pilgrimages at the ancient '
        'pilgrimage centers of the Āryadeśa; the improvement of amenities for '
        'pilgrims and visitors; the distribution of Dharma books; and the '
        'training and education of a new generation of Indian monks. Over '
        '100,000 Dharma books have been distributed without charge.',
    'In 2006, LBDFI became the primary sponsor for the International Tipitaka '
        'Chanting Ceremony, which has grown to become the most important '
        'international gathering of Theravadin monks in India. From December '
        '2-13th each year, over 10,000 monks and their followers from ten South '
        'East Asian Countries gather in Bodhgaya to chant the teachings of the '
        'Buddha, as recorded in the Pali Canon.',
  ];

  /// The app is built on the WeBuddhist platform (backend, accounts,
  /// library). This name is shown once, as "Powered by WeBuddhist" at the
  /// foot of the About page; everywhere else it is replaced by [appName].
  static const String platformName = 'WeBuddhist';

  /// Sent as `X-Application` on every WeBuddhist API call, so the backend
  /// returns LBDFI's content (spaces and so on). The library API is shared
  /// and does not get it.
  static const String applicationId = 'lbdfi';

  /// Keys that keep the word "WeBuddhist". None: LBDFI asked for the name
  /// to appear only in the About page's "Powered by" line.
  static const Set<String> platformKeys = {};

  /// Whole-string replacements, per language. Taken from LBDFI's own words
  /// (21st ITCC poster and invitation).
  static const Map<String, Map<String, String>> overrides = {
    'en': {
      'splash_tagline_1': 'One collective voice of the Buddha',
      'splash_tagline_2': 'We become one, under the Bodhi Tree',
    },
  };

  // English phrasing that reads better than a bare name swap.
  static const List<(String, String)> _phrases = [
    ('the WeBuddhist app', 'the $appName app'),
    ('inside WeBuddhist', 'inside the app'),
    ('outside WeBuddhist', 'outside the app'),
    ('make WeBuddhist more helpful', 'make the $appName app more helpful'),
    ('on WeBuddhist', 'on the $appName app'),
    ('from WeBuddhist', 'from $appName'),
  ];

  /// Rebrands one UI string. Every string in the app, from Tolgee or from the
  /// bundled ARB files, passes through here (see `TolgeeBridge`), so the
  /// WeBuddhist name can't come back through live translation updates.
  static String text(String localeName, String key, String value) {
    final String language = localeName.split(RegExp('[-_]')).first;
    final String? override = overrides[language]?[key];
    if (override != null) return override;
    if (platformKeys.contains(key) || !value.contains(platformName)) {
      return value;
    }
    String out = value;
    if (language == 'en') {
      for (final (from, to) in _phrases) {
        out = out.replaceAll(from, to);
      }
    }
    return out.replaceAll(platformName, appName);
  }
}

/// Heritage palette. Light-mode values from `brand/palette.json`
/// (`light.appColorTokens`); contrast checked there.
class BrandColors {
  BrandColors._();

  /// Robe Maroon, from lbdfi.org. White on it is 8.9:1.
  static const Color primary = Color(0xFF980404);

  /// Lighter maroon. Used as text and outline colour in dark mode, so it is
  /// lighter than a plain 20% tint to stay readable on black (5.8:1).
  static const Color primaryLight = Color(0xFFD9605A);
  static const Color primaryDark = Color(0xFF720303);
  static const Color primaryDarkest = Color(0xFF580202);
  static const Color primaryContainer = Color(0xFFF5E6E6);
  static const Color primarySurface = Color(0xFFFAF2F2);

  /// Deep saffron for calls to action (white on it is 5.5:1).
  static const Color saffron = Color(0xFFB34810);

  /// LBDFI gold, from the official logo. Decoration and icons only: on cream
  /// it is 2.2:1, too faint for text.
  static const Color gold = Color(0xFFD9A534);
  static const Color goldDark = Color(0xFFB0832A);
  static const Color goldDarkest = Color(0xFF7A5A1C);

  /// Temple Cream, lbdfi.org page background.
  static const Color cream = Color(0xFFFFFAF7);

  /// Onboarding rings, outer to inner.
  static const Color ringOuter = Color(0xFF980404);
  static const Color ringMiddle = Color(0xFF720303);
  static const Color ringInner = Color(0xFF580202);
}
