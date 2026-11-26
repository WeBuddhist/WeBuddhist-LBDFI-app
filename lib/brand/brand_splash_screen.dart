import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pecha/brand/brand.dart';
import 'package:flutter_pecha/core/constants/app_assets.dart';

/// LBDFI's launch screen, used in place of WeBuddhist's animated one.
///
/// The emblem sits still at the centre of a white screen, exactly where and
/// as large as the native launch screen drew it, with the organisation's full
/// name under it. Nothing moves. After [holdDuration] it reports
/// [onIntroComplete] and the router moves on.
///
/// Always white, in dark mode too, to match the native launch screens.
class BrandSplashScreen extends StatefulWidget {
  const BrandSplashScreen({
    super.key,
    this.playIntro = true,
    this.onIntroComplete,
  });

  /// Hold the screen for [holdDuration]. False reports completion at once,
  /// for the splashes shown after launch (e.g. while a login runs).
  final bool playIntro;

  /// Called once, after the hold or straight away when there is none. Also
  /// fires if the screen goes away first, so a hold on it never sticks.
  final VoidCallback? onIntroComplete;

  static const Duration holdDuration = Duration(seconds: 3);

  /// Keep in sync with the native launch screens (LaunchScreen.storyboard,
  /// android launch_background.xml and splash_icon.xml), so the first frame
  /// matches what they drew. 152, not more: Android 12+ masks its launch icon
  /// to a 192dp circle, and the emblem's cloud base would poke out of it.
  static const double logoSize = 152;

  @override
  State<BrandSplashScreen> createState() => _BrandSplashScreenState();
}

class _BrandSplashScreenState extends State<BrandSplashScreen> {
  static const double _nameGap = 24;
  static const double _horizontalPadding = 32;
  static const Color _nameColor = BrandColors.primary;

  Timer? _hold;
  bool _notified = false;

  @override
  void initState() {
    super.initState();
    if (widget.playIntro) {
      _hold = Timer(BrandSplashScreen.holdDuration, _notify);
    } else {
      _notify();
    }
  }

  @override
  void dispose() {
    _hold?.cancel();
    _notify();
    super.dispose();
  }

  void _notify() {
    if (_notified) return;
    _notified = true;
    final onIntroComplete = widget.onIntroComplete;
    if (onIntroComplete == null) return;
    // May run during a build and the callback changes router state, so run
    // it after the current frame.
    scheduleMicrotask(onIntroComplete);
  }

  @override
  Widget build(BuildContext context) {
    // The platform font, so the name is drawn in the first frame with no
    // font download swapping it afterwards.
    final nameStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.3,
      color: _nameColor,
      decoration: TextDecoration.none,
    );
    // Dark status bar icons: the screen is white in dark mode too, where the
    // app's theme would otherwise draw them white on white.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final nameTop =
                constraints.maxHeight / 2 +
                BrandSplashScreen.logoSize / 2 +
                _nameGap;
            return Stack(
              children: [
                Center(
                  child: Image.asset(
                    AppAssets.weBuddhistLogo,
                    width: BrandSplashScreen.logoSize,
                    height: BrandSplashScreen.logoSize,
                    semanticLabel: Brand.appName,
                  ),
                ),
                Positioned(
                  top: nameTop,
                  left: _horizontalPadding,
                  right: _horizontalPadding,
                  child: Text(
                    Brand.fullName,
                    textAlign: TextAlign.center,
                    style: nameStyle,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
