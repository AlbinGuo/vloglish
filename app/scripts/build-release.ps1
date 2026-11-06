#Requires -Version 5.1
<#
.SYNOPSIS
  Build a signed Release APK for Vloglish (Capacitor + Android).

.DESCRIPTION
  - Optional one-time setup of the release keystore (-Init).
  - Builds frontend app assets, syncs Capacitor, runs gradlew assembleRelease.
  - Verifies the produced APK is signed via apksigner.
  - Optionally bumps versionCode / versionName in android/app/build.gradle.

  Passwords are read in this order:
    command line (-StorePassword / -KeyPassword)
    -> environment (VLOG_ANDROID_STORE_PASSWORD / VLOG_ANDROID_KEY_PASSWORD)
    -> android/keystore.properties (storePassword / keyPassword)
    -> interactive prompt (when needed)

.EXAMPLES
  # First time: create keystore + keystore.properties, then build.
  .\scripts\build-release.ps1 -Init

  # Normal build (passwords from env vars are recommended).
  $env:VLOG_ANDROID_STORE_PASSWORD = "***"
  $env:VLOG_ANDROID_KEY_PASSWORD = "***"
  .\scripts\build-release.ps1

  # Build with a version bump.
  .\scripts\build-release.ps1 -VersionCode 13 -VersionName "1.2.0"
#>
[CmdletBinding()]
param(
  [switch]$Init,
  [switch]$InitOnly,
  [string]$StorePassword = '',
  [string]$KeyPassword = '',
  [string]$KeyAlias = 'vloglish',
  [string]$StoreFile = 'vloglish-release.jks',
  [int]$VersionCode = 0,
  [string]$VersionName = '',
  [switch]$SkipVerify,
  [switch]$RequireVersionBump,
  [switch]$OpenOutput
)

$ErrorActionPreference = 'Stop'

$ScriptDir    = Split-Path -Parent $MyInvocation.MyCommand.Path
$AppRoot      = (Resolve-Path (Join-Path $ScriptDir '..')).Path
$AndroidRoot  = Join-Path $AppRoot 'android'
$BuildGradle  = Join-Path $AndroidRoot 'app\build.gradle'
$PropsPath    = Join-Path $AndroidRoot 'keystore.properties'
$ExamplePath  = Join-Path $AndroidRoot 'keystore.properties.example'
$ReleaseDir   = Join-Path $AndroidRoot 'app\build\outputs\apk\release'
$SignedApk    = Join-Path $ReleaseDir 'app-release.apk'
$UnsignedApk  = Join-Path $ReleaseDir 'app-release-unsigned.apk'
$DistApk      = Join-Path $AppRoot 'dist\vloglish-release.apk'

function Info($m) { Write-Host "==> $m" -ForegroundColor Cyan }
function Ok($m)   { Write-Host "OK  $m" -ForegroundColor Green }
function Warn($m) { Write-Host "WARN $m" -ForegroundColor Yellow }
function Fail($m) { Write-Host "ERROR $m" -ForegroundColor Red; exit 1 }

function Write-Utf8NoBom([string]$path, [string]$text) {
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($path, $text, $enc)
}

function Read-Props([string]$path) {
  $h = @{}
  if (-not (Test-Path $path)) { return $h }
  foreach ($line in [System.IO.File]::ReadAllLines($path)) {
    $t = $line.Trim()
    if (-not $t -or $t.StartsWith('#')) { continue }
    $i = $t.IndexOf('=')
    if ($i -le 0) { continue }
    $h[$t.Substring(0, $i).Trim()] = $t.Substring($i + 1).Trim()
  }
  return $h
}

function Set-PropLine([string]$text, [string]$key, [string]$value) {
  $pattern = '(?m)^\s*' + [regex]::Escape($key) + '\s*=.*$'
  $replacement = ("$key=$value").Replace('$', '$$')
  if ([regex]::IsMatch($text, $pattern)) {
    return [regex]::Replace($text, $pattern, $replacement)
  }
  return ($text.TrimEnd() + "`r`n$key=$value`r`n")
}

function Get-PlainPassword([string]$value, [string]$prompt) {
  if ($value) { return $value }
  $sec = Read-Host -AsSecureString $prompt
  $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
  try { return [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
  finally { [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
}

function Resolve-KeystorePath([string]$storeFileValue) {
  if ([System.IO.Path]::IsPathRooted($storeFileValue)) { return $storeFileValue }
  return (Join-Path $AndroidRoot $storeFileValue)
}

function Find-Keytool {
  $candidates = @()
  if ($env:GRADLE_JAVA_HOME) { $candidates += (Join-Path $env:GRADLE_JAVA_HOME 'bin\keytool.exe') }
  if ($env:JAVA_HOME)        { $candidates += (Join-Path $env:JAVA_HOME 'bin\keytool.exe') }
  $candidates += @(
    'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe',
    'C:\Program Files\Eclipse Adoptium\jdk-21*\bin\keytool.exe',
    'C:\Program Files\Java\jdk-21*\bin\keytool.exe',
    'C:\Program Files\Microsoft\jdk-21*\bin\keytool.exe'
  )
  foreach ($c in $candidates) {
    $resolved = @(Resolve-Path -Path $c -ErrorAction SilentlyContinue)
    if ($resolved.Count -gt 0) { return $resolved[0].Path }
  }
  $cmd = Get-Command keytool -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  return $null
}

function Find-Apksigner {
  $sdk = $env:ANDROID_HOME
  if (-not $sdk) { $sdk = $env:ANDROID_SDK_ROOT }
  $localProps = Join-Path $AndroidRoot 'local.properties'
  if (-not $sdk -and (Test-Path $localProps)) {
    foreach ($line in [System.IO.File]::ReadAllLines($localProps)) {
      if ($line -match '^\s*sdk\.dir\s*=\s*(.+)$') {
        $sdk = $matches[1].Replace('\\\\', '\').Replace('\\', '\')
        break
      }
    }
  }
  if (-not $sdk) { $sdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk' }
  $bt = Join-Path $sdk 'build-tools'
  if (-not (Test-Path $bt)) { return $null }
  $dirs = Get-ChildItem -Path $bt -Directory | Sort-Object {
    try { [version]($_.Name -replace '[^0-9.].*$', '') } catch { [version]'0.0.0' }
  } -Descending
  foreach ($d in $dirs) {
    $p = Join-Path $d.FullName 'apksigner.bat'
    if (Test-Path $p) { return $p }
  }
  return $null
}

function Find-Aapt2 {
  $sdk = $env:ANDROID_HOME
  if (-not $sdk) { $sdk = $env:ANDROID_SDK_ROOT }
  $localProps = Join-Path $AndroidRoot 'local.properties'
  if (-not $sdk -and (Test-Path $localProps)) {
    foreach ($line in [System.IO.File]::ReadAllLines($localProps)) {
      if ($line -match '^\s*sdk\.dir\s*=\s*(.+)$') {
        $sdk = $matches[1].Replace('\\\\', '\').Replace('\\', '\')
        break
      }
    }
  }
  if (-not $sdk) { $sdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk' }
  $bt = Join-Path $sdk 'build-tools'
  if (-not (Test-Path $bt)) { return $null }
  $dirs = Get-ChildItem -Path $bt -Directory | Sort-Object {
    try { [version]($_.Name -replace '[^0-9.].*$', '') } catch { [version]'0.0.0' }
  } -Descending
  foreach ($d in $dirs) {
    $p = Join-Path $d.FullName 'aapt2.exe'
    if (Test-Path $p) { return $p }
    $p = Join-Path $d.FullName 'aapt.exe'
    if (Test-Path $p) { return $p }
  }
  return $null
}

function Get-ApkVersion([string]$apkPath) {
  $result = [pscustomobject]@{ Code = 0; Name = '' }
  $aapt = Find-Aapt2
  if (-not $aapt) { return $result }
  try {
    $out = & $aapt dump badging $apkPath 2>$null
  } catch {
    return $result
  }
  foreach ($line in @($out)) {
    if ($line -match "versionCode='([0-9]+)'") { $result.Code = [int]$matches[1] }
    if ($line -match "versionName='([^']*)'") { $result.Name = $matches[1] }
  }
  return $result
}

function Initialize-Signing {
  $props = Read-Props $PropsPath
  $storeFileProp = if ($props.ContainsKey('storeFile') -and $props['storeFile']) { $props['storeFile'] } else { $StoreFile }
  $alias = if ($props.ContainsKey('keyAlias') -and $props['keyAlias']) { $props['keyAlias'] } else { $KeyAlias }
  $ksPath = Resolve-KeystorePath $storeFileProp

  if (-not (Test-Path $ksPath)) {
    Info "Keystore not found, generating: $ksPath"
    $keytool = Find-Keytool
    if (-not $keytool) {
      Fail "keytool not found. Install JDK 21 or set JAVA_HOME / GRADLE_JAVA_HOME."
    }
    $storePass = Get-PlainPassword $StorePassword 'Keystore password'
    if (-not $storePass) { Fail 'Keystore password is required.' }
    $keyPass = Get-PlainPassword $KeyPassword 'Key password (press Enter to reuse keystore password)'
    if (-not $keyPass) { $keyPass = $storePass }

    & $keytool -genkeypair -v -keystore $ksPath -keyalg RSA -keysize 2048 -validity 10000 `
      -alias $alias -storepass $storePass -keypass $keyPass `
      -dname 'CN=Vloglish, OU=Mobile, O=Vloglish, C=CN' -noprompt
    if ($LASTEXITCODE -ne 0) { Fail 'keytool failed to generate the keystore.' }
    $script:StorePassword = $storePass
    $script:KeyPassword = $keyPass
    Ok "Keystore created: $ksPath"
    Warn 'Back up this .jks file. Losing it prevents updating existing installations.'
  } else {
    Ok "Keystore found: $ksPath"
  }

  if (-not (Test-Path $PropsPath)) {
    if (Test-Path $ExamplePath) {
      Copy-Item $ExamplePath $PropsPath
    } else {
      Write-Utf8NoBom $PropsPath "storeFile=$storeFileProp`r`nkeyAlias=$alias`r`n"
    }
  }

  $text = [System.IO.File]::ReadAllText($PropsPath, [System.Text.Encoding]::UTF8)
  $text = Set-PropLine $text 'storeFile' $storeFileProp
  $text = Set-PropLine $text 'keyAlias' $alias
  Write-Utf8NoBom $PropsPath $text
  Ok "Signing config ready: $PropsPath"
}

# ---------------------------------------------------------------------------
if (-not (Test-Path $BuildGradle)) { Fail "Android project not found: $AndroidRoot" }
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { Fail 'Node.js was not found in PATH.' }
if (-not (Get-Command npm.cmd -ErrorAction SilentlyContinue) -and -not (Get-Command npm -ErrorAction SilentlyContinue)) {
  Fail 'npm was not found in PATH.'
}

if ($Init) { Initialize-Signing }
if ($InitOnly) { Ok 'Init done.'; exit 0 }

# ---------------------------------------------------------------------------
# Validate signing config
$props = Read-Props $PropsPath
$storeFileProp = if ($props.ContainsKey('storeFile') -and $props['storeFile']) { $props['storeFile'] } else { $StoreFile }
$alias = if ($props.ContainsKey('keyAlias') -and $props['keyAlias']) { $props['keyAlias'] } else { $KeyAlias }
$ksPath = Resolve-KeystorePath $storeFileProp

if (-not (Test-Path $PropsPath)) {
  Fail "Missing $PropsPath. Run: .\scripts\build-release.ps1 -Init"
}
if (-not (Test-Path $ksPath)) {
  Fail "Keystore not found: $ksPath. Run: .\scripts\build-release.ps1 -Init"
}

if (-not $StorePassword) { $StorePassword = $env:VLOG_ANDROID_STORE_PASSWORD }
if (-not $StorePassword -and $props['storePassword']) { $StorePassword = $props['storePassword'] }
if (-not $KeyPassword) { $KeyPassword = $env:VLOG_ANDROID_KEY_PASSWORD }
if (-not $KeyPassword -and $props['keyPassword']) { $KeyPassword = $props['keyPassword'] }
if (-not $StorePassword) { $StorePassword = Get-PlainPassword '' 'Keystore password' }
if (-not $KeyPassword) { $KeyPassword = Get-PlainPassword '' 'Key password (press Enter to reuse keystore password)' }
if (-not $StorePassword) { Fail 'Keystore password is required.' }
if (-not $KeyPassword) { $KeyPassword = $StorePassword }

# Export for the Gradle child process.
$env:VLOG_ANDROID_STORE_PASSWORD = $StorePassword
$env:VLOG_ANDROID_KEY_PASSWORD = $KeyPassword
$env:VLOG_ANDROID_KEY_ALIAS = $alias

Ok "Signing key: $ksPath (alias: $alias)"

# ---------------------------------------------------------------------------
# Optional version bump
if ($VersionCode -gt 0 -or $VersionName) {
  $text = [System.IO.File]::ReadAllText($BuildGradle, [System.Text.Encoding]::UTF8)
  if ($VersionCode -gt 0) {
    $text = [regex]::Replace($text, '(?m)^(\s*versionCode\s+)\d+', ('${1}' + $VersionCode))
    Ok "versionCode -> $VersionCode"
  }
  if ($VersionName) {
    $text = [regex]::Replace($text, '(?m)^(\s*versionName\s+)"[^"]*"', ('${1}"' + $VersionName + '"'))
    Ok "versionName -> $VersionName"
  }
  Write-Utf8NoBom $BuildGradle $text
}

# ---------------------------------------------------------------------------
# Build (frontend app assets -> cap sync -> gradlew assembleRelease)
Info 'Building web assets, syncing Capacitor, assembling Release APK...'
$npm = Get-Command npm.cmd -ErrorAction SilentlyContinue
if (-not $npm) { $npm = Get-Command npm -ErrorAction SilentlyContinue }
Push-Location $AppRoot
try {
  & $npm.Source run build:apk
  $exitCode = $LASTEXITCODE
} finally {
  Pop-Location
}
if ($exitCode -ne 0) { Fail "Build failed (exit code $exitCode)." }

# ---------------------------------------------------------------------------
# Verify output
if (-not (Test-Path $SignedApk)) {
  if (Test-Path $UnsignedApk) {
    Fail "Only unsigned APK was produced ($UnsignedApk). Check signing config and rebuild."
  }
  Fail "Release APK not found: $SignedApk"
}

$sizeMb = [math]::Round((Get-Item $SignedApk).Length / 1MB, 2)
Ok "Signed Release APK: $SignedApk ($sizeMb MB)"

# ---------------------------------------------------------------------------
# Verify real versionCode / versionName inside the APK to avoid mismatch with the admin release config
$apkVersion = Get-ApkVersion $SignedApk
if ($apkVersion.Code -gt 0) {
  Write-Host ("APK versionCode = {0}, versionName = {1}" -f $apkVersion.Code, $apkVersion.Name) -ForegroundColor Cyan
  if ($VersionCode -gt 0 -and $apkVersion.Code -ne $VersionCode) {
    Fail "APK versionCode ($($apkVersion.Code)) does not match -VersionCode ($VersionCode). Check build.gradle."
  }
  $marker = Join-Path $AppRoot 'dist\.last-build-version.json'
  $lastCode = 0
  if (Test-Path $marker) {
    try { $lastCode = [int]((Get-Content $marker -Raw | ConvertFrom-Json).versionCode) } catch { $lastCode = 0 }
  }
  if ($RequireVersionBump -and $apkVersion.Code -le $lastCode) {
    Fail "APK versionCode ($($apkVersion.Code)) is not greater than last build ($lastCode). Release builds must increase versionCode."
  }
  if ($lastCode -gt 0 -and $apkVersion.Code -le $lastCode) {
    Warn "This versionCode ($($apkVersion.Code)) is not greater than last build ($lastCode): users will keep seeing the update prompt if this is published."
  }
  try {
    New-Item -ItemType Directory -Force -Path (Split-Path $marker) | Out-Null
    @{ versionCode = $apkVersion.Code; versionName = $apkVersion.Name; builtAt = (Get-Date).ToString('s') } |
      ConvertTo-Json | Set-Content -Path $marker -Encoding UTF8
  } catch { Warn "Failed to write build version marker: $marker" }
  Write-Host ("Release reminder: set admin app versionCode to {0} and versionName to {1} (must match the APK exactly)." -f $apkVersion.Code, $apkVersion.Name) -ForegroundColor Yellow
} else {
  Warn "Could not read APK versionCode (aapt/aapt2 not found). Make sure build.gradle versionCode matches the admin config."
}

if (-not $SkipVerify) {
  $apksigner = Find-Apksigner
  if ($apksigner) {
    Info 'Verifying signature...'
    & $apksigner verify --print-certs $SignedApk
    if ($LASTEXITCODE -ne 0) { Fail 'apksigner verification failed.' }
    Ok 'Signature verified.'
  } else {
    Warn 'apksigner not found; skipped signature verification.'
  }
}

if (Test-Path $DistApk) {
  $sha = (Get-FileHash -Algorithm SHA256 $DistApk).Hash
  Ok "Copied to: $DistApk"
  Write-Host "SHA256: $sha" -ForegroundColor DarkGray
  if ($OpenOutput) { Invoke-Item (Split-Path $DistApk) }
} else {
  Warn "Convenience copy not found at $DistApk (build script may have skipped copying)."
}

Write-Host ''
Ok 'Done.'
