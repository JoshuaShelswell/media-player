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
    Write-Host "Locating rust_engine.dll…"
    $candidates = @(
        "$PSScriptRoot\rust-engine\target\release\rust_engine.dll",
        "$PSScriptRoot\target\release\rust_engine.dll"
    )
    $src = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $src) {
        Write-Error "❌ rust_engine.dll not found under:`n  $($candidates -join "`n  ")"
        exit 1
    }
    Write-Host "  Found: $src"

    $dest = "$PSScriptRoot\flutter-media-player\build\windows\x64\runner\Debug"
    if (-not (Test-Path $dest)) {
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
    }
    Copy-Item -Path $src -Destination (Join-Path $dest "rust_engine.dll") -Force
    Write-Host "Copied rust_engine.dll → $dest"
}

function Copy-FFmpegDlls {
    Write-Host "Copying FFmpeg dependencies…"
    $vcpkgBin = "C:\vcpkg\packages\ffmpeg_x64-windows\bin"
    if (-not (Test-Path $vcpkgBin)) {
        Write-Error "FFmpeg bin folder not found at $vcpkgBin"
        exit 1
    }

    $dest = "$PSScriptRoot\flutter-media-player\build\windows\x64\runner\Debug"
    if (-not (Test-Path $dest)) {
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
    }

    # Copy all .dll files whose names start with av* or sw*
    Get-ChildItem -Path $vcpkgBin -Filter '*.dll' -File |
      Where-Object { $_.Name -match '^(av|sw)' } |
      ForEach-Object {
        Copy-Item -Path $_.FullName -Destination $dest -Force
        Write-Host "  Copied $($_.Name) → $dest"
      }

    Write-Host "FFmpeg DLLs copied."
}

function Run-FlutterMediaPlayer {
    Write-Host "Launching Flutter Media Player for Windows…"
    Push-Location "$PSScriptRoot\flutter-media-player"

    if (!(Test-Path "$PSScriptRoot\flutter-media-player\windows")) {
        Write-Host "Configuring Windows desktop support…"
        flutter create .
    }

    flutter pub get
    Kill-ExistingFlutterRemote

    Write-Host "Starting flutter run -d windows --debug…"
    $flutterProcess = Start-Process flutter -ArgumentList "run -d windows --debug" -NoNewWindow -PassThru

    Write-Host "Waiting for flutter_remote.exe…"
    for ($i = 0; $i -lt 20; $i++) {
        if (Get-Process -Name "flutter_remote" -ErrorAction SilentlyContinue) {
            Write-Host "flutter_remote.exe is running."
            Wait-Process -Name "flutter_remote"
            break
        }
        Start-Sleep -Seconds 1
    }

    if (-not $flutterProcess.HasExited) {
        Write-Host "Terminating flutter run (PID = $($flutterProcess.Id))…"
        Stop-Process -Id $flutterProcess.Id -Force
    }

    Pop-Location
}

# --- Main Script Execution ---
Build-RustEngine
Copy-RustEngineDll
Copy-FFmpegDlls
Run-FlutterMediaPlayer
