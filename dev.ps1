# media-player-project/dev.ps1
$ErrorActionPreference = "Stop"

function Build-RustEngine {
    Write-Host "Building Rust engine..."
    Push-Location "$PSScriptRoot\rust-engine"
    # Build the Rust project in release mode. (Ensure no main.rs exists if you intend only to build a library.)
    cargo build --release
    Pop-Location
    Write-Host "Rust engine build completed."
}

function Run-FlutterMediaPlayer {
    Write-Host "Launching Flutter Media Player for Windows in Debug mode..."
    Push-Location "$PSScriptRoot\flutter-media-player"
    
    # Check if the Windows desktop project is configured. If not, create it.
    if (!(Test-Path "$PSScriptRoot\flutter-media-player\windows")) {
        Write-Host "Windows desktop support not configured. Creating Windows project..."
        flutter create .
    }
    
    flutter pub get
    # Launch the Windows desktop version in debug mode
    flutter run -d windows --debug
    Pop-Location
}

function Run-FlutterRemote {
    Write-Host "Launching Flutter Remote (Android)..."
    Push-Location "$PSScriptRoot\flutter-remote"
    flutter pub get
    # Uncomment the following to run on an Android device/emulator
    # flutter run -d android --debug
    Pop-Location
}

# --- Main Script Execution ---
Build-RustEngine
Run-FlutterMediaPlayer
# Run-FlutterRemote   # Uncomment to also launch the remote control app during development
