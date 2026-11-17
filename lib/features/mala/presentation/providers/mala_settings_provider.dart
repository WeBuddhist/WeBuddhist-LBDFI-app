import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_pecha/core/storage/storage_keys.dart';

/// The speeds offered for the mantra marquee, slowest first.
const List<double> kMalaMantraSpeedPresets = [0.5, 0.75, 1.0, 1.25, 1.5];
const double kMalaMantraSpeedDefault = 1.0;

class MalaSettingsState {
  const MalaSettingsState({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.leftHanded = false,
    this.playAnimation = true,
    this.mantraSpeed = kMalaMantraSpeedDefault,
  });

  final bool soundEnabled;
  final bool vibrationEnabled;

  /// Counter sits on the right (thumb-side for a left hand) when true.
  final bool leftHanded;

  /// Whether the mantra lines scroll. When false they stand still.
  final bool playAnimation;

  /// Marquee speed multiplier, always one of [kMalaMantraSpeedPresets].
  final double mantraSpeed;

  MalaSettingsState copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? leftHanded,
    bool? playAnimation,
    double? mantraSpeed,
  }) => MalaSettingsState(
    soundEnabled: soundEnabled ?? this.soundEnabled,
    vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    leftHanded: leftHanded ?? this.leftHanded,
    playAnimation: playAnimation ?? this.playAnimation,
    mantraSpeed: mantraSpeed ?? this.mantraSpeed,
  );
}

/// The preset closest to [speed], so a value saved by an older build (the
/// slider allowed anything from 0.5x to 2x) lands on a chip.
double snapMalaMantraSpeed(double speed) {
  var best = kMalaMantraSpeedPresets.first;
  for (final preset in kMalaMantraSpeedPresets) {
    if ((preset - speed).abs() < (best - speed).abs()) best = preset;
  }
  return best;
}

class MalaSettingsNotifier extends StateNotifier<MalaSettingsState> {
  MalaSettingsNotifier() : super(const MalaSettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = MalaSettingsState(
      soundEnabled: prefs.getBool(StorageKeys.malaSoundEnabled) ?? true,
      vibrationEnabled: prefs.getBool(StorageKeys.malaVibrationEnabled) ?? true,
      leftHanded: prefs.getBool(StorageKeys.malaLeftHanded) ?? false,
      playAnimation: prefs.getBool(StorageKeys.malaPlayAnimation) ?? true,
      mantraSpeed: snapMalaMantraSpeed(
        prefs.getDouble(StorageKeys.malaMantraSpeed) ?? kMalaMantraSpeedDefault,
      ),
    );
  }

  Future<void> setSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.malaSoundEnabled, enabled);
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    state = state.copyWith(vibrationEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.malaVibrationEnabled, enabled);
  }

  Future<void> setLeftHanded(bool leftHanded) async {
    state = state.copyWith(leftHanded: leftHanded);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.malaLeftHanded, leftHanded);
  }

  Future<void> setPlayAnimation(bool play) async {
    state = state.copyWith(playAnimation: play);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.malaPlayAnimation, play);
  }

  Future<void> setMantraSpeed(double speed) async {
    final snapped = snapMalaMantraSpeed(speed);
    state = state.copyWith(mantraSpeed: snapped);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(StorageKeys.malaMantraSpeed, snapped);
  }
}

final malaSettingsProvider =
    StateNotifierProvider<MalaSettingsNotifier, MalaSettingsState>((ref) {
      return MalaSettingsNotifier();
    });
