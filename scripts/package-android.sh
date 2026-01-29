echo "Compiling application..."
flutter build apk --release
echo "Application compiled successfully!"
mkdir -p build/output
cp "build/app/outputs/flutter-apk/app-release.apk" build/output/yamata-launcher.apk
echo "APK created at build/output/yamata-launcher.apk"