import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_pecha/features/mala/domain/entities/mala_image_option.dart';
import 'package:flutter_pecha/features/mala/domain/entities/mala_skin.dart';
import 'package:flutter_pecha/features/mala/domain/entities/mantra.dart';
import 'package:flutter_pecha/features/mala/presentation/providers/mala_appearance_provider.dart';
import 'package:flutter_pecha/features/mala/presentation/providers/mala_providers.dart';
import 'package:flutter_pecha/features/mala/presentation/providers/space_mantra_providers.dart';
import 'package:flutter_pecha/shared/domain/value_objects/responsive_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mala_fakes.dart';

const _own = ResponsiveImage(thumbnail: 'https://s3/own.jpg');
const _other = ResponsiveImage(thumbnail: 'https://s3/other.jpg');

const _mantra = Mantra(
  presetId: 'tara',
  mantra: MantraText(id: 'm1', text: 'om', deityImage: _own),
);

final _ownBead = Uint8List.fromList([1]);
final _skinBead = Uint8List.fromList([2]);

FakeMalaAppearanceRepository _server({String? deity, String? skin}) =>
    FakeMalaAppearanceRepository(
      deityOptions: const [
        MalaImageOption(id: 'own', image: _own, isDefault: true),
        MalaImageOption(id: 'other', image: _other),
      ],
      skinList: const [
        MalaSkin(id: 'bodhi', name: 'bodhi_seed', url: 'https://s3/bodhi'),
      ],
      deityImageId: deity,
      malaSkinId: skin,
    );

/// What the mala screen would draw for [_mantra].
typedef _Shown = ({ResponsiveImage? image, Uint8List? bead});

Future<_Shown Function()> _pump(
  WidgetTester tester,
  FakeMalaAppearanceRepository server,
) async {
  late _Shown shown;
  late WidgetRef widgetRef;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        malaAppearanceRepositoryProvider.overrideWithValue(server),
        malaBeadImageBytesProvider.overrideWith(
          (ref, url) async => url == 'https://s3/bodhi' ? _skinBead : null,
        ),
        // Saving refreshes this list; keep it off the network.
        joinedSpaceMantrasProvider.overrideWith((ref) async => const []),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          widgetRef = ref;
          shown = (
            image: watchMalaMantraImage(ref, _mantra),
            bead: watchMalaBeadBytes(ref, _mantra.mantraId, _ownBead),
          );
          return const SizedBox();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  _ref = widgetRef;
  return () => shown;
}

late WidgetRef _ref;

void main() {
  testWidgets('without a pick, the mantra shows its own image and bead', (
    tester,
  ) async {
    final shown = await _pump(tester, _server());

    expect(shown().image, _own);
    expect(shown().bead, _ownBead);
  });

  testWidgets('a saved pick replaces the image and bead', (tester) async {
    final shown = await _pump(tester, _server(deity: 'other', skin: 'bodhi'));

    expect(shown().image, _other);
    expect(shown().bead, _skinBead);
  });

  testWidgets('saving updates what is shown at once', (tester) async {
    final server = _server();
    final shown = await _pump(tester, server);

    final notifier = _ref.read(malaAppearanceProvider('m1').notifier);
    expect(await notifier.setDeityImage('other'), isTrue);
    expect(await notifier.setMalaSkin('bodhi'), isTrue);
    await tester.pumpAndSettle();

    expect(shown().image, _other);
    expect(shown().bead, _skinBead);
  });

  testWidgets('a failed save returns false and changes nothing', (
    tester,
  ) async {
    final server = _server()..failSaves = true;
    final shown = await _pump(tester, server);

    final saved = await _ref
        .read(malaAppearanceProvider('m1').notifier)
        .setDeityImage('other');
    await tester.pumpAndSettle();

    expect(saved, isFalse);
    expect(shown().image, _own);
  });
}
