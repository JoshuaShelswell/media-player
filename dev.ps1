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

function Run-FlutterMediaPlayer {
    Write-Host "Launching Flutter Media Player for Windows in Debug mode..."
    Push-Location "$PSScriptRoot\flutter-media-player"

    if (!(Test-Path "$PSScriptRoot\flutter-media-player\windows")) {
        Write-Host "Windows desktop support not configured. Creating Windows project..."
        flutter create .
    }

    flutter pub get
    Kill-ExistingFlutterRemote

    Write-Host "Starting 'flutter run -d windows --debug' in the current console..."
    $flutterProcess = Start-Process -FilePath "flutter" -ArgumentList "run -d windows --debug" -NoNewWindow -PassThru

    Write-Host "Waiting for flutter_remote.exe to appear..."
    $found = $false
    for ($i = 0; $i -lt 20; $i++) {
        $proc = Get-Process -Name "flutter_remote" -ErrorAction SilentlyContinue
        if ($proc) {
            $found = $true
            break
        }
        Start-Sleep -Seconds 1
    }

    if ($found) {
        Write-Host "flutter_remote.exe is running."
        Write-Host "Close the app window (using the X button) to exit gracefully."
        # Wait indefinitely until the flutter_remote.exe process terminates.
        Wait-Process -Name "flutter_remote"
        Write-Host "flutter_remote.exe has closed gracefully."
    }
    else {
        Write-Host "flutter_remote.exe did not appear. Check for build errors, then press Enter to terminate."
        Read-Host
    }

    # Ensure the flutter run process is terminated (if it still exists).
    if (-not $flutterProcess.HasExited) {
        Write-Host "Terminating flutter run process (PID = $($flutterProcess.Id))..."
        Stop-Process -Id $flutterProcess.Id -Force
    }

    Pop-Location
}

function Run-FlutterRemote {
    Write-Host "Launching Flutter Remote (Android)..."
    Push-Location "$PSScriptRoot\flutter-remote"
    flutter pub get
    # Uncomment the following line to launch on an Android device/emulator:
    # flutter run -d android --debug
    Pop-Location
}

# --- Main Script Execution ---
Build-RustEngine
Run-FlutterMediaPlayer
# Run-FlutterRemote   # Uncomment if you wish to launch the remote app.
