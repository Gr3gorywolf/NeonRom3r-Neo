dart run dmg --no-sign --no-notarization
mkdir -p build/output
cp "build/macos/Build/Products/Release/Yamata Launcher.dmg" build/output/yamata_launcher_macos.dmg
echo "DMG created at build/output/yamata_launcher_macos.dmg"
