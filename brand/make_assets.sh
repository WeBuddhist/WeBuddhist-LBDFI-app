#!/usr/bin/env bash
# Regenerates every app image that carries the brand from one emblem file.
#
#   brand/make_assets.sh            # from the repo root
#
# Inputs (brand/logo/lbdfi-mark-color.png) → outputs:
#   brand/logo/lbdfi-mark-heritage.png       gold line-art + saffron jewels, transparent fills
#   assets/launcher/app_icon.png             iOS / store icon, emblem on white (no alpha)
#   assets/launcher/app_icon_foreground.png  Android adaptive foreground (background colour is in pubspec)
#   assets/images/webuddhist_logo.png        in-app logo (file name kept so upstream code is untouched)
#   android res drawable-*/splash_logo.png   native splash logo
#   ios LaunchImage.imageset                 native splash logo
#   ios TimerWidget AppLogo.imageset         Live Activity lock-screen logo
# Then run: dart run flutter_launcher_icons && android/create_notification_icons.sh
set -euo pipefail
cd "$(dirname "$0")/.."

SRC=brand/logo/lbdfi-mark-color.png
MARK=brand/logo/lbdfi-mark-heritage.png
ICON_BG="#FFFFFF"   # white: saffron emblem on white (Theravada look, chosen 25 Nov 2026)
GOLD="#C98A1E"      # LBDFI gold, deep enough to read on white

command -v magick >/dev/null || { echo "ImageMagick (magick) is required"; exit 1; }

# White fills → transparent, yellow line-art → LBDFI gold, saffron jewels kept.
magick "$SRC" \
  -fuzz 14% -fill none -opaque "#FEFFFC" \
  -fuzz 22% -fill "$GOLD" -opaque "#FDD00D" \
  -trim +repage -resize 1024x1024 -gravity center -background none -extent 1024x1024 \
  -strip "$MARK"

# Icon: emblem at 74% on white, like the WeBuddhist icon's proportions.
magick -size 1024x1024 "xc:$ICON_BG" \( "$MARK" -resize 758x758 \) -gravity center -composite \
  -alpha off -strip assets/launcher/app_icon.png
magick "$MARK" -resize 758x758 -gravity center -background none -extent 1024x1024 \
  -strip assets/launcher/app_icon_foreground.png

# In-app logo: emblem filling the canvas.
magick "$MARK" -resize 1012x1012 -gravity center -background none -extent 1024x1024 \
  -strip assets/images/webuddhist_logo.png

# Native splash logo: 160dp / 160pt, the size BrandSplashScreen draws it.
for item in mdpi:160 hdpi:240 xhdpi:320 xxhdpi:480 xxxhdpi:640; do
  d=${item%%:*}; s=${item##*:}
  magick "$MARK" -resize "${s}x${s}" -strip "android/app/src/main/res/drawable-$d/splash_logo.png"
done

L=ios/Runner/Assets.xcassets/LaunchImage.imageset
magick "$MARK" -resize 160x160 -strip "$L/LaunchImage.png"
magick "$MARK" -resize 320x320 -strip "$L/LaunchImage@2x.png"
magick "$MARK" -resize 480x480 -strip "$L/LaunchImage@3x.png"

W=ios/TimerWidget/Assets.xcassets/AppLogo.imageset
magick "$MARK" -resize 32x32 -strip "$W/AppLogo.png"
magick "$MARK" -resize 64x64 -strip "$W/AppLogo@2x.png"
magick "$MARK" -resize 96x96 -strip "$W/AppLogo@3x.png"

echo "Brand images regenerated from $SRC"
