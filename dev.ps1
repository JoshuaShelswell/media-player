# dev.ps1
$ErrorActionPreference = "Stop"

function Kill-ExistingFlutterRemote {
    Write-Host "Checking for running flutter_remote.exe..."
    $processes = Get-Process -Name flutter_remote -ErrorAction SilentlyContinue
    if ($processes) {
        Write-Host "Found running flutter_remote.exe, terminating..."
        $processes | Stop-Process -Force
        Start-Sleep -Seconds 3
    }
    else {
        Write-Host "No existing flutter_remote.exe process found."
    }
}

function Build-RustEngine {
    Write-Host "Building Rust engine..."
    Push-Location "$PSScriptRoot\rust-engine"
    cargo build --release
    Pop-Location
    Write-Host "Rust engine build completed."
}

function Copy-RustEngineDll {
    Write-Host "Locating rust_engine.dll..."

    # look in both possible target folders
    $candidates = @(
        "$PSScriptRoot\rust-engine\target\release\rust_engine.dll",
        "$PSScriptRoot\target\release\rust_engine.dll"
    )
    $src = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $src) {
        Write-Error "❌ rust_engine.dll not found in:`n  $($candidates -join "`n  ")"
        exit 1
    }
    Write-Host "  Found: $src"

    $destDir = "$PSScriptRoot\flutter-media-player\build\windows\x64\runner\Debug"
    if (-not (Test-Path $destDir)) {
        Write-Host "  Creating destination folder: $destDir"
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    Write-Host "Copying to Flutter runner…"
    Copy-Item -Path $src -Destination "$destDir\rust_engine.dll" -Force
    Write-Host "  → $destDir\rust_engine.dll"
}

function Run-FlutterMediaPlayer {
    Write-Host "Launching Flutter Media Player for Windows in Debug mode..."
    Push-Location "$PSScriptRoot\flutter-media-player"

    if (!(Test-Path "$PSScriptRoot\flutter-media-player\windows")) {
        Write-Host "Windows desktop support not configured. Creating Windows project..."
        flutter create .
    }

    flutter pub get
    Kill-ExistingFlutterRemote

    Write-Host "Starting 'flutter run -d windows --debug'…"
    $flutterProcess = Start-Process flutter -ArgumentList "run -d windows --debug" -NoNewWindow -PassThru

    Write-Host "Waiting for flutter_remote.exe to appear…"
    $found = $false
    for ($i = 0; $i -lt 20; $i++) {
        if (Get-Process -Name "flutter_remote" -ErrorAction SilentlyContinue) {
            $found = $true; break
        }
        Start-Sleep -Seconds 1
    }

    if ($found) {
        Write-Host "flutter_remote.exe is running. Close it to exit."
        Wait-Process -Name "flutter_remote"
    }
    else {
        Write-Host "flutter_remote.exe never appeared. Press Enter to exit."
        Read-Host
    }

    if (-not $flutterProcess.HasExited) {
        Write-Host "Terminating flutter run (PID = $($flutterProcess.Id))…"
        Stop-Process -Id $flutterProcess.Id -Force
    }

    Pop-Location
}

function Run-FlutterRemote {
    Write-Host "Launching Flutter Remote (Android)…"
    Push-Location "$PSScriptRoot\flutter-remote"
    flutter pub get
    # flutter run -d android --debug
    Pop-Location
}

# --- Main Script Execution ---
Build-RustEngine
Copy-RustEngineDll
Run-FlutterMediaPlayer
# Run-FlutterRemote   # Uncomment if you wish to launch the remote app.
