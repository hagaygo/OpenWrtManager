call flutter clean
call flutter build apk --release  --target-platform android-arm,android-arm64 --dart-define=COMPRESS_APK=true
move build\app\outputs\apk\release\app-release.apk build\app\outputs\apk\release\openwrt_manager.apk
