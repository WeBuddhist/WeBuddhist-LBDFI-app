import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:flutter_pecha/core/utils/app_logger.dart';
import 'package:flutter_pecha/features/mala/domain/entities/mala_image_option.dart';
import 'package:flutter_pecha/features/mala/domain/entities/mala_skin.dart';
import 'package:flutter_pecha/features/mala/domain/entities/mantra.dart';
import 'package:flutter_pecha/features/mala/domain/entities/mantra_appearance.dart';
import 'package:flutter_pecha/features/mala/domain/repositories/mala_appearance_repository.dart';
import 'package:flutter_pecha/features/mala/presentation/providers/mala_providers.dart';
import 'package:flutter_pecha/features/mala/presentation/providers/space_mantra_providers.dart';
import 'package:flutter_pecha/features/more/presentation/providers/mantra_counts_provider.dart';
import 'package:flutter_pecha/shared/domain/value_objects/responsive_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _logger = AppLogger('MalaAppearance');

/// The user's deity image and bead skin for one mantra, keyed by mantra id.
///
/// Read from the server while something shows the mantra. Saving updates the
/// state from the PATCH response, so the mala screen changes at once, then
/// refreshes the lists that carry the choice elsewhere.
class MalaAppearanceNotifier
    extends AutoDisposeFamilyAsyncNotifier<MantraAppearance, String> {
  MalaAppearanceRepository get _repository =>
      ref.read(malaAppearanceRepositoryProvider);

  @override
  Future<MantraAppearance> build(String mantraId) =>
      ref.watch(malaAppearanceRepositoryProvider).appearance(mantraId);

  /// [imageId] null restores the mantra's default. False when the save
  /// failed; nothing changed then.
  Future<bool> setDeityImage(String? imageId) =>
      _save(deityImage: (id: imageId));

  /// [skinId] null restores the default bead. False when the save failed.
  Future<bool> setMalaSkin(String? skinId) => _save(malaSkin: (id: skinId));

  Future<bool> _save({
    AppearancePick? deityImage,
    AppearancePick? malaSkin,
  }) async {
    try {
      final updated = await _repository.updateAppearance(
        arg,
        deityImage: deityImage,
        malaSkin: malaSkin,
      );
      state = AsyncData(updated);
      // Other lists carry the choice too; refresh them in the background.
      ref.invalidate(mantraCountsProvider);
      ref.invalidate(joinedSpaceMantrasProvider);
      return true;
    } catch (e, stack) {
      _logger.error('Saving the appearance of mantra $arg failed', e, stack);
      return false;
    }
  }
}

final malaAppearanceProvider = AsyncNotifierProvider.autoDispose
    .family<MalaAppearanceNotifier, MantraAppearance, String>(
      MalaAppearanceNotifier.new,
    );

/// A mantra's deity gallery, for the Change image sheet. Fetched each time
/// the sheet opens, since the image URLs expire.
final malaDeityImagesProvider = FutureProvider.autoDispose
    .family<List<MalaImageOption>, String>((ref, mantraId) {
      return ref.watch(malaAppearanceRepositoryProvider).deityImages(mantraId);
    });

/// Bead skins offered in the Bead style sheet (`GET /mala-skins`).
final malaSkinsProvider = FutureProvider.autoDispose<List<MalaSkin>>((ref) {
  return ref.watch(malaAppearanceRepositoryProvider).skins();
});

/// Fill of the drawn bead when no bead artwork is available.
const Color kMalaDefaultBeadColor = Color(0xFF8D6E63);

/// Bead artwork for the mantra [mantraId]: the user's skin when they picked
/// one, else [ownBytes] (the bead the accumulation already shows). Also
/// [ownBytes] while the pick loads or when it fails to download.
Uint8List? watchMalaBeadBytes(
  WidgetRef ref,
  String? mantraId,
  Uint8List? ownBytes,
) {
  if (mantraId == null) return ownBytes;
  final appearance = ref.watch(malaAppearanceProvider(mantraId)).valueOrNull;
  final url = appearance?.malaSkinUrl;
  if (appearance?.malaSkinId == null || url == null) return ownBytes;
  return ref.watch(malaBeadImageBytesProvider(url)).valueOrNull ?? ownBytes;
}

/// The artwork shown above [mantra]: the user's deity image when they picked
/// one, else the mantra's own.
ResponsiveImage? watchMalaMantraImage(WidgetRef ref, Mantra mantra) {
  final mantraId = mantra.mantraId;
  if (mantraId == null) return mantra.deityImage;
  final appearance = ref.watch(malaAppearanceProvider(mantraId)).valueOrNull;
  if (appearance?.deityImageId == null) return mantra.deityImage;
  return appearance?.deityImage ?? mantra.deityImage;
}
