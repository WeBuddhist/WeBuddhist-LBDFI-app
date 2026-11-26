import 'package:flutter_pecha/brand/brand.dart';
import 'package:flutter_pecha/core/l10n/tolgee/tolgee_bridge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Brand.text', () {
    test('renames the app', () {
      expect(Brand.text('en', 'appTitle', 'WeBuddhist'), 'LBDFI');
      expect(
        Brand.text('en', 'profile_default_bio', 'Welcome to WeBuddhist'),
        'Welcome to LBDFI',
      );
    });

    test('rewrites English share phrasing', () {
      expect(
        Brand.text(
          'en',
          'share_quote_message',
          'I liked this quote from WeBuddhist. Read more on the WeBuddhist app.',
        ),
        'I liked this quote from LBDFI. Read more on the LBDFI app.',
      );
      expect(
        Brand.text('en', 'share_plan_subject', 'Join me on WeBuddhist'),
        'Join me on the LBDFI app',
      );
      expect(
        Brand.text(
          'en',
          'group_event_live_link_custom_help',
          'Custom link. Viewers open it outside WeBuddhist.',
        ),
        'Custom link. Viewers open it outside the app.',
      );
    });

    test('leaves no WeBuddhist name, platform strings included', () {
      expect(
        Brand.text(
          'en',
          'help_contact_footer',
          'Replies come from the WeBuddhist Team in your Chats.',
        ),
        'Replies come from the LBDFI Team in your Chats.',
      );
      expect(
        Brand.text(
          'en',
          'delete_account_confirm_message',
          'Are you sure you want to delete your WeBuddhist account?',
        ),
        'Are you sure you want to delete your LBDFI account?',
      );
    });

    test('swaps the name in other languages without English phrasing', () {
      expect(
        Brand.text('th', 'profile_default_bio', 'ยินดีต้อนรับสู่ WeBuddhist'),
        'ยินดีต้อนรับสู่ LBDFI',
      );
      expect(Brand.text('zh_Hant', 'appTitle', 'WeBuddhist'), 'LBDFI');
    });

    test('uses LBDFI taglines in English only', () {
      expect(
        Brand.text('en', 'splash_tagline_1', 'We Buddhists practice together'),
        'One collective voice of the Buddha',
      );
      expect(Brand.text('bo', 'splash_tagline_1', 'x'), 'x');
    });

    test('leaves strings without the brand untouched', () {
      expect(Brand.text('en', 'sign_in', 'Sign in'), 'Sign in');
    });
  });

  group('TolgeeBridge with the brand overlay', () {
    tearDown(TolgeeBridge.reset);

    test('rebrands bundled fallbacks', () {
      expect(TolgeeBridge.get('en', 'appTitle', () => 'WeBuddhist'), 'LBDFI');
    });

    test('rebrands live Tolgee strings', () {
      TolgeeBridge.load(
        languageCode: 'en',
        strings: {'profile_default_bio': 'Welcome to WeBuddhist'},
      );
      expect(
        TolgeeBridge.get('en', 'profile_default_bio', () => 'unused'),
        'Welcome to LBDFI',
      );
    });

    test('rebrands the template, not the values filled into it', () {
      TolgeeBridge.load(
        languageCode: 'en',
        strings: {
          'group_accumulator_share_message':
              'I am taking part in "{accumulation}", an accumulation by {group} on WeBuddhist.',
        },
      );
      expect(
        TolgeeBridge.format('en', 'group_accumulator_share_message', {
          'accumulation': 'Tara',
          'group': 'WeBuddhist Friends',
        }, () => 'unused'),
        'I am taking part in "Tara", an accumulation by WeBuddhist Friends on the LBDFI app.',
      );
    });
  });
}
