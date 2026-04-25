# Flutter Setup Guide

## Installation Status ✅
- Flutter SDK: Installed di `C:\flutter_sdk\flutter`
- Dart SDK: Included dengan Flutter
- VS Code Extensions: Flutter + Dart terinstall
- Project: monthly_outcome

## How to Use Flutter

### Quick Commands
```powershell
# Navigate ke project folder
cd "c:\xampp\htdocs\monthly outcome\monthly_outcome"

# Run app
C:\flutter_sdk\flutter\bin\flutter.bat run

# Build APK
C:\flutter_sdk\flutter\bin\flutter.bat build apk

# Check status
C:\flutter_sdk\flutter\bin\flutter.bat doctor
```

### Setup PATH (Optional)
Untuk membuat `flutter` command langsung bisa diakses dari mana saja, tambahkan ke PowerShell profile:

```powershell
# Edit PowerShell profile
notepad $PROFILE

# Tambahkan baris ini:
$env:PATH += ";C:\flutter_sdk\flutter\bin"
```

## Next Steps
1. ✅ Flutter installed
2. ✅ VS Code setup
3. ⏳ Setup Android Emulator (optional for development)
4. ⏳ Start coding!

## File Structure
```
monthly_outcome/
├── lib/
│   └── main.dart          # Main app entry point
├── android/               # Android native code
├── ios/                   # iOS native code
├── pubspec.yaml          # Dependencies & project config
└── test/                 # Test files
```

## Running the App
1. Connect Android device OR setup emulator
2. Run: `flutter run`
3. Changes auto-reload during development

---
Untuk lebih detail, cek: https://flutter.dev/docs
