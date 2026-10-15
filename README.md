# pet_game

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Build via GitHub Actions (tanpa Android Studio)

1. Buat repo GitHub, push code ini:
   ```bash
   git init
   git add .
   git commit -m "Petku v1"
   git branch -M main
   git remote add origin https://github.com/KAMU/petku.git
   git push -u origin main
   ```

2. Buka Actions tab di GitHub → workflow `Build Petku APK & AAB` akan jalan otomatis.
   Atau trigger manual: Actions → Run workflow.

3. Setelah selesai (~6 menit), download artifact:
   - `petku-apk` → `app-release.apk` (install langsung, share)
   - `petku-aab` → `app-release.aab` (upload Play Console)

4. Tanpa keystore: build pakai debug signing (bisa install, tapi Play Store butuh upload key sendiri).
   Dengan keystore (Play Store release):
   ```bash
   keytool -genkey -v -keystore petku.jks -keyalg RSA -keysize 2048 -validity 10000 -alias petku
   base64 -w0 petku.jks   # copy output
   ```
   GitHub → Settings → Secrets and variables → Actions → New repository secret:
   - `KEYSTORE_BASE64` = output base64
   - `KEYSTORE_PASSWORD` = password store
   - `KEY_ALIAS` = petku
   - `KEY_PASSWORD` = password key
   Lalu re-run workflow — AAB akan signed release.

## Build lokal
```bash
flutter pub get
flutter build apk --release
flutter build appbundle --release
```

Privacy: https://petku-web.vercel.app/privacy
Package: com.petku.game
