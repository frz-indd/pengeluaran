param(
  [string]$ImagePath = "assets/branding/intan.png"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ImagePath)) {
  throw "File tidak ditemukan: $ImagePath. Taruh gambar logo di path tersebut dulu."
}

Write-Host "Running flutter pub get..."
flutter pub get

Write-Host "Generating launcher icons..."
flutter pub run flutter_launcher_icons

Write-Host "Generating native splash..."
flutter pub run flutter_native_splash:create

Write-Host "Done."

