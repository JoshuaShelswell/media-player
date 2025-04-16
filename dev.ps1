# dev.ps1
Write-Host "Starting development workflow..."

# Step 0: Kill any running instance of media-player-core-bin.exe
Write-Host "Killing any running media-player-core-bin.exe process..."
taskkill /F /IM "media-player-core-bin.exe" 2>$null
Start-Sleep -Seconds 2

# Step 1: Clean the workspace
Write-Host "Running 'cargo clean'..."
cargo clean
if ($LASTEXITCODE -ne 0) {
    Write-Error "cargo clean failed."
    exit $LASTEXITCODE
}

# Step 2: Build the release package for media-player-core (both lib and bin targets)
Write-Host "Building release version for media-player-core (lib and bin targets)..."
cargo build --release -p media-player-core
if ($LASTEXITCODE -ne 0) {
    Write-Error "cargo build --release -p media-player-core failed."
    exit $LASTEXITCODE
}

# Step 3: Copy the DLL to flutter_app
# On Windows with MSVC the cdylib output file is placed in the workspace's target\release folder.
$sourceDll = "target\release\media_player_core.dll"
$destDll   = "flutter_app\media_player_core.dll"

Write-Host "Copying DLL from '$sourceDll' to '$destDll'..."
try {
    Copy-Item $sourceDll $destDll -Force
} catch {
    Write-Error "Failed to copy DLL: $_"
    exit 1
}
if (-Not (Test-Path $destDll)) {
    Write-Error "DLL copy failed: file not found at destination"
    exit 1
}

# Step 3.1: Copy the executable to flutter_app (rename it to media-player-core.exe)
# The binary target is built as "media-player-core-bin.exe" but we want to rename it.
$sourceExe = "target\release\media-player-core-bin.exe"
$destExe   = "flutter_app\media-player-core.exe"

Write-Host "Copying EXE from '$sourceExe' to '$destExe'..."
try {
    Copy-Item $sourceExe $destExe -Force
} catch {
    Write-Error "Failed to copy EXE: $_"
    exit 1
}
if (-Not (Test-Path $destExe)) {
    Write-Error "EXE copy failed: file not found at destination"
    exit 1
}

# Step 4: Launch the Rust core in the background
Write-Host "Launching Rust core (media-player-core-bin) in background..."
Start-Process cargo -ArgumentList "run", "--release", "-p", "media-player-core", "--bin", "media-player-core-bin" -NoNewWindow
Start-Sleep -Seconds 2

# Step 5: Launch the Flutter app
Write-Host "Launching Flutter app (flutter run -d windows)..."
Push-Location "flutter_app"

# If flutter is not on your PATH, specify its full path (e.g., "C:\flutter\bin\flutter.bat")
$flutterResult = & flutter run -d windows
Pop-Location

if ($LASTEXITCODE -ne 0) {
    Write-Error "flutter run failed."
    exit $LASTEXITCODE
}

Write-Host "Development workflow complete."
