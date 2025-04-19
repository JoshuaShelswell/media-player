<#
.SYNOPSIS
  Production build script for Windows.
.DESCRIPTION
  Builds Rust engine & Flutter frontend in release mode,
  then stages all binaries & DLLs into .\production.
#>
$ErrorActionPreference = "Stop"

# --- 1) Prepare production folder ---
$ProductionDir = Join-Path $PSScriptRoot "production"
Write-Host "→ Resetting production folder..."
if (Test-Path $ProductionDir) { Remove-Item -Recurse -Force $ProductionDir }
New-Item -ItemType Directory -Path $ProductionDir | Out-Null

# --- 2) Build Rust engine (release) ---
Write-Host "→ Building Rust engine (release)..."
Push-Location "$PSScriptRoot\rust-engine"
cargo clean
cargo build --release
Pop-Location

# --- 3) Build Flutter Windows app (release) ---
Write-Host "→ Building Flutter Windows app (release)..."
Push-Location "$PSScriptRoot\flutter-media-player"

# ensure Windows desktop support exists
if (!(Test-Path "$PSScriptRoot\flutter-media-player\windows")) {
    Write-Host "   Configuring Windows desktop support..."
    flutter create .
}

flutter clean
flutter pub get
flutter build windows --release
Pop-Location

# --- 4) Copy Flutter Release output ---
$ReleaseDir = "$PSScriptRoot\flutter-media-player\build\windows\x64\runner\Release"
Write-Host "→ Copying Flutter build to production..."
Copy-Item "$ReleaseDir\*" -Destination $ProductionDir -Recurse -Force

# --- 5) Copy rust_engine.dll ---
Write-Host "→ Locating rust_engine.dll…"
$DllCandidates = @(
    "$PSScriptRoot\rust-engine\target\release\rust_engine.dll",
    "$PSScriptRoot\target\release\rust_engine.dll"
)
$RustDll = $DllCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $RustDll) {
    Write-Error "❌ rust_engine.dll not found under:`n  $($DllCandidates -join "`n  ")"
    exit 1
}
Write-Host "   Found: $RustDll"
Copy-Item -Path $RustDll -Destination $ProductionDir -Force

# --- 6) Copy FFmpeg DLLs ---
Write-Host "→ Copying FFmpeg dependencies…"
$vcpkgBin = "C:\vcpkg\packages\ffmpeg_x64-windows\bin"
if (Test-Path $vcpkgBin) {
    Get-ChildItem -Path $vcpkgBin -Filter '*.dll' -File |
      Where-Object { $_.Name -match '^(av|sw)' } |
      ForEach-Object {
        Copy-Item -Path $_.FullName -Destination $ProductionDir -Force
        Write-Host "   Copied $($_.Name)"
      }
    Write-Host "   FFmpeg DLLs copied."
} else {
    Write-Warning "FFmpeg bin folder not found at $vcpkgBin"
}

Write-Host "`n✅ Production build complete!"
Write-Host "   Artifacts ready in: $ProductionDir"
