# Build csound-vst3-opcodes on Windows with MSVC (Visual Studio 2022, x64).
# Requires an MSVC-built Csound 7 install: set CSOUND_ROOT or CSOUND_INSTALL_PREFIX.
param(
    [string]$Config = "Release"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$buildDir = Join-Path $repoRoot "build-windows"
$installDir = Join-Path $repoRoot "dist"

$csoundPrefix = $env:CSOUND_ROOT
if (-not $csoundPrefix) { $csoundPrefix = $env:CSOUND_INSTALL_PREFIX }
if (-not $csoundPrefix) {
    throw "Set CSOUND_ROOT or CSOUND_INSTALL_PREFIX to an MSVC Csound 7 install prefix."
}

Write-Host "Cleaning and building csound-vst3-opcodes for Windows (MSVC)..."
if (Test-Path $buildDir) { Remove-Item -Recurse -Force $buildDir }
if (Test-Path $installDir) { Remove-Item -Recurse -Force $installDir }

$csoundExe = @(
    (Join-Path $csoundPrefix "bin\csound64.exe"),
    (Join-Path $csoundPrefix "bin\csound.exe")
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $csoundExe) {
    throw "Could not find csound.exe under $csoundPrefix\bin"
}

$csoundLib = Get-ChildItem -Path $csoundPrefix -Recurse -Include @(
    "csound64.lib", "libcsound64.lib"
) -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $csoundLib) {
    throw "Could not find csound64.lib under $csoundPrefix"
}

$prefixPath = $csoundPrefix
$vcpkgInstalled = Join-Path $csoundPrefix "..\vcpkg_installed\x64-windows"
if (Test-Path $vcpkgInstalled) { $prefixPath = "$csoundPrefix;$vcpkgInstalled" }

cmake -S (Join-Path $repoRoot "vst3-opcodes") -B $buildDir `
    -G "Visual Studio 17 2022" -A x64 `
    -DCMAKE_INSTALL_PREFIX="$installDir" `
    -DCMAKE_PREFIX_PATH="$prefixPath" `
    -DCSOUND_ROOT_HINT="$csoundPrefix" `
    -DCSOUND_EXECUTABLE="$csoundExe" `
    -DCSOUND_LIBRARY="$($csoundLib.FullName)" `
    -DCSOUND_LIBRARIES="$($csoundLib.FullName)" `
    -DSMTG_USE_STDATOMIC_H=OFF
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

cmake --build $buildDir --config $Config --parallel --target stage_dist
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

cmake --build $buildDir --config $Config --target archive_dist
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Get-ChildItem -Path $installDir -Recurse -File | ForEach-Object { $_.FullName }
Write-Host "Archive: $buildDir\csound-vst3-opcodes-2.0.0-windows.zip"
Write-Host "Completed clean MSVC build. Artifacts are in dist/."
