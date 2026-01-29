dart run dmg --no-sign --no-notarization
mkdir -p build/output
cp "build/macos/Build/Products/Release/Yamata Launcher.dmg" build/output/yamata-launcher-installer.dmg
echo "DMG created at build/output/yamata-launcher-installer.dmg"
    