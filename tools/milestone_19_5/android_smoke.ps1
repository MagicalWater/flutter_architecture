[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [string]$Avd = 'flutter_architecture_m18',
  [string]$PackageId = 'com.example.flutterarchitecture',
  [int]$FixturePort = 18443,
  [string]$EvidenceDir = 'build/milestone_19_5_evidence',
  [string]$ApkPath = 'apps/flutter_architecture/build/app/outputs/flutter-apk/app-release.apk',
  [ValidateSet('Plan','Prepare','Artifact','Install','ClearData','Launch','ForceStop','CaptureUi','InspectSandbox','ClearLogcat','CollectLogcat','CreateCa','InstallCa','RemoveCa','ReversePort')]
  [string]$Action = 'Plan',
  [string]$Label = 'manual'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$workspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$evidenceRoot = Join-Path $workspaceRoot $EvidenceDir
$apkFullPath = Join-Path $workspaceRoot $ApkPath
$caDir = Join-Path $evidenceRoot 'ca'
$caKey = Join-Path $caDir 'm19-local-ca.key'
$caCert = Join-Path $caDir 'm19-local-ca.crt'
$serverKey = Join-Path $caDir 'localhost.key'
$serverCsr = Join-Path $caDir 'localhost.csr'
$serverCert = Join-Path $caDir 'localhost.crt'
$serverExt = Join-Path $caDir 'localhost.ext'
$installedCaMarker = Join-Path $caDir 'installed-ca-name.txt'
$caBeforePath = Join-Path $caDir 'system-ca-before.txt'
$caAfterPath = Join-Path $caDir 'system-ca-after.txt'

function Write-Step([string]$message) {
  Write-Host "[m19-5] $message"
}

function Require-Command([string]$name) {
  if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
    throw "Required command not found: $name"
  }
}

function Get-Sha256([string]$path) {
  $stream = [IO.File]::OpenRead($path)
  try {
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
      return (($sha.ComputeHash($stream) | ForEach-Object { $_.ToString('x2') }) -join '')
    } finally {
      $sha.Dispose()
    }
  } finally {
    $stream.Dispose()
  }
}

function Invoke-Checked {
  param(
    [Parameter(Mandatory = $true)][string]$FilePath,
    [Parameter(Mandatory = $true)][string[]]$Arguments,
    [switch]$Capture
  )

  if ($Capture) {
    $output = & $FilePath @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
      throw "$FilePath failed with exit code $LASTEXITCODE`n$($output -join [Environment]::NewLine)"
    }
    return ($output -join [Environment]::NewLine).Trim()
  }

  & $FilePath @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "$FilePath failed with exit code $LASTEXITCODE"
  }
}

function Ensure-EvidenceDirectory {
  if ($PSCmdlet.ShouldProcess($evidenceRoot, 'Create evidence directory')) {
    New-Item -ItemType Directory -Force -Path $evidenceRoot | Out-Null
  }
}

function Assert-EvidenceDirectoryUntracked {
  $relative = $EvidenceDir.Replace('\', '/')
  $tracked = & git -C $workspaceRoot ls-files -- $relative
  if ($LASTEXITCODE -ne 0) { throw 'git ls-files failed' }
  if ($tracked) { throw "Evidence directory must not be Git tracked: $relative" }
}

function Assert-AvdExists {
  $emulators = Invoke-Checked flutter @('emulators') -Capture
  if ($emulators -notmatch [regex]::Escape($Avd)) {
    throw "AVD not found: $Avd"
  }
}

function Get-DeviceSerial {
  $lines = Invoke-Checked adb @('devices') -Capture
  $devices = @($lines -split "`r?`n" | Where-Object { $_ -match "\tdevice$" })
  if ($devices.Count -ne 1) {
    throw "Exactly one online adb device is required; found $($devices.Count)."
  }
  return ($devices[0] -split "\t")[0]
}

function Assert-RootDevice {
  $serial = Get-DeviceSerial
  $currentUid = Invoke-Checked adb @('-s', $serial, 'shell', 'id', '-u') -Capture
  if ($currentUid.Trim() -eq '0') { return }
  if (-not $PSCmdlet.ShouldProcess($serial, 'Restart adbd as root')) {
    throw 'Root-required action skipped by WhatIf or confirmation policy.'
  }
  $rootOutput = Invoke-Checked adb @('-s', $serial, 'root') -Capture
  if ($rootOutput -notmatch 'already running as root|restarting adbd as root') {
    throw "adb root did not succeed: $rootOutput"
  }
  Start-Sleep -Seconds 2
  Invoke-Checked adb @('-s', $serial, 'wait-for-device')
  $uid = Invoke-Checked adb @('-s', $serial, 'shell', 'id', '-u') -Capture
  if ($uid.Trim() -ne '0') { throw "Device is not root; uid=$uid" }
}

function Get-AaptPath {
  $androidHome = $env:ANDROID_HOME
  if (-not $androidHome) { $androidHome = $env:ANDROID_SDK_ROOT }
  if (-not $androidHome) { $androidHome = Join-Path $env:LOCALAPPDATA 'Android\Sdk' }
  $candidate = Get-ChildItem (Join-Path $androidHome 'build-tools') -Directory |
    Sort-Object Name -Descending |
    ForEach-Object { Join-Path $_.FullName 'aapt.exe' } |
    Where-Object { Test-Path $_ } |
    Select-Object -First 1
  if (-not $candidate) { throw 'aapt.exe not found in Android build-tools.' }
  return $candidate
}

function Write-ArtifactMetadata {
  if (-not (Test-Path $apkFullPath)) { throw "APK not found: $apkFullPath" }
  Ensure-EvidenceDirectory
  $badging = Invoke-Checked (Get-AaptPath) @('dump', 'badging', $apkFullPath) -Capture
  $permissions = Invoke-Checked (Get-AaptPath) @('dump', 'permissions', $apkFullPath) -Capture
  $manifestTree = Invoke-Checked (Get-AaptPath) @('dump', 'xmltree', $apkFullPath, 'AndroidManifest.xml') -Capture
  $item = Get-Item $apkFullPath
  $mergedManifest = Join-Path $workspaceRoot 'apps/flutter_architecture/build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml'
  $metadata = [ordered]@{
    apk_path = $ApkPath.Replace('\', '/')
    sha256 = Get-Sha256 $apkFullPath
    size_bytes = $item.Length
    package = ($badging -split "`r?`n" | Where-Object { $_ -like 'package:*' } | Select-Object -First 1)
    min_sdk = ($badging -split "`r?`n" | Where-Object { $_ -like 'sdkVersion:*' } | Select-Object -First 1)
    target_sdk = ($badging -split "`r?`n" | Where-Object { $_ -like 'targetSdkVersion:*' } | Select-Object -First 1)
    allow_backup = ($manifestTree -split "`r?`n" | Where-Object { $_ -match 'android:allowBackup' } | Select-Object -First 1)
    permissions = @($permissions -split "`r?`n" | Where-Object { $_ -match "uses-permission" })
    merged_manifest_path = if (Test-Path $mergedManifest) { $mergedManifest.Replace($workspaceRoot + '\', '').Replace('\', '/') } else { $null }
    collected_at_utc = [DateTime]::UtcNow.ToString('o')
  }
  $path = Join-Path $evidenceRoot 'artifact-metadata.json'
  if ($PSCmdlet.ShouldProcess($path, 'Write artifact metadata')) {
    $metadata | ConvertTo-Json | Set-Content -Encoding UTF8 $path
  }
  $metadata | ConvertTo-Json
}

function Write-DeviceMetadata {
  Assert-RootDevice
  Ensure-EvidenceDirectory
  $serial = Get-DeviceSerial
  $metadata = [ordered]@{
    serial = $serial
    api_level = Invoke-Checked adb @('-s', $serial, 'shell', 'getprop', 'ro.build.version.sdk') -Capture
    abi = Invoke-Checked adb @('-s', $serial, 'shell', 'getprop', 'ro.product.cpu.abi') -Capture
    avd_name = Invoke-Checked adb @('-s', $serial, 'shell', 'getprop', 'ro.boot.qemu.avd_name') -Capture
    boot_completed = Invoke-Checked adb @('-s', $serial, 'shell', 'getprop', 'sys.boot_completed') -Capture
    root_uid = Invoke-Checked adb @('-s', $serial, 'shell', 'id', '-u') -Capture
    collected_at_utc = [DateTime]::UtcNow.ToString('o')
  }
  if ($metadata.boot_completed -ne '1') { throw "Device boot is incomplete: $($metadata.boot_completed)" }
  $path = Join-Path $evidenceRoot 'device-metadata.json'
  if ($PSCmdlet.ShouldProcess($path, 'Write device metadata')) {
    $metadata | ConvertTo-Json | Set-Content -Encoding UTF8 $path
  }
  $metadata | ConvertTo-Json
}

function Install-Apk {
  if (-not (Test-Path $apkFullPath)) { throw "APK not found: $apkFullPath" }
  $serial = Get-DeviceSerial
  if ($PSCmdlet.ShouldProcess("$serial/$PackageId", "Install APK $apkFullPath")) {
    Invoke-Checked adb @('-s', $serial, 'install', '-r', $apkFullPath)
  }
}

function Clear-AppData {
  $serial = Get-DeviceSerial
  if ($PSCmdlet.ShouldProcess("$serial/$PackageId", 'Clear app data')) {
    Invoke-Checked adb @('-s', $serial, 'shell', 'pm', 'clear', $PackageId)
  }
}

function Start-App {
  $serial = Get-DeviceSerial
  if ($PSCmdlet.ShouldProcess("$serial/$PackageId", 'Launch app')) {
    Invoke-Checked adb @('-s', $serial, 'shell', 'monkey', '-p', $PackageId, '-c', 'android.intent.category.LAUNCHER', '1')
  }
}

function Stop-App {
  $serial = Get-DeviceSerial
  if ($PSCmdlet.ShouldProcess("$serial/$PackageId", 'Force-stop app')) {
    Invoke-Checked adb @('-s', $serial, 'shell', 'am', 'force-stop', $PackageId)
  }
}

function Assert-NoSecret([string]$text, [string]$channel) {
  foreach ($needle in @('M19_ACCESS_SECRET', 'M19_REFRESH_SECRET', 'M19_PASSWORD_SECRET', 'Authorization:', 'Bearer m19-')) {
    if ($text -match [regex]::Escape($needle)) { throw "$channel contains forbidden sentinel: $needle" }
  }
}

function Capture-UiEvidence {
  Assert-RootDevice
  Ensure-EvidenceDirectory
  $serial = Get-DeviceSerial
  $safeLabel = ($Label -replace '[^A-Za-z0-9._-]', '_')
  $activityPath = Join-Path $evidenceRoot "$safeLabel-activity.txt"
  $uiPath = Join-Path $evidenceRoot "$safeLabel-ui.xml"
  $pngPath = Join-Path $evidenceRoot "$safeLabel.png"
  if ($PSCmdlet.ShouldProcess($evidenceRoot, "Capture UI evidence: $safeLabel")) {
    Invoke-Checked adb @('-s', $serial, 'shell', 'dumpsys', 'activity', 'activities') -Capture | Set-Content -Encoding UTF8 $activityPath
    Invoke-Checked adb @('-s', $serial, 'shell', 'uiautomator', 'dump', '/sdcard/window_dump.xml') | Out-Null
    Invoke-Checked adb @('-s', $serial, 'pull', '/sdcard/window_dump.xml', $uiPath) | Out-Null
    $adbPath = (Get-Command adb).Source
    $screencap = Start-Process -FilePath $adbPath -ArgumentList @('-s', $serial, 'exec-out', 'screencap', '-p') -RedirectStandardOutput $pngPath -NoNewWindow -PassThru -Wait
    if ($screencap.ExitCode -ne 0) { throw 'screencap failed' }
    Assert-NoSecret (Get-Content $uiPath -Raw) 'UI hierarchy'
    (Get-Sha256 $pngPath) |
      Set-Content -Encoding ASCII (Join-Path $evidenceRoot "$safeLabel-screenshot-sha256.txt")
  }
}

function Inspect-Sandbox {
  Assert-RootDevice
  Ensure-EvidenceDirectory
  $serial = Get-DeviceSerial
  $base = "/data/data/$PackageId"
  $shell = @(
    "echo '[shared_preferences_files]'",
    ('find {0}/shared_prefs -maxdepth 1 -type f -printf ''%f\n'' 2>/dev/null | sort' -f $base),
    "echo '[shared_preferences_keys]'",
    ('grep -rho ''name="[^"]*"'' {0}/shared_prefs 2>/dev/null | sed ''s/^name="//;s/"$//'' | sort -u' -f $base),
    "echo '[legacy_key_files]'",
    ('grep -rl ''name="auth.tokens"\|name="auth.accessToken"'' {0}/shared_prefs 2>/dev/null | sed ''s#.*/##'' | sort' -f $base),
    "echo '[secure_artifacts]'",
    ('find {0}/shared_prefs -maxdepth 1 -type f \( -iname ''*secure*'' -o -iname ''*encrypted*'' \) -printf ''%f|%s|%TY-%Tm-%TdT%TH:%TM:%TS\n'' 2>/dev/null | sort' -f $base),
    "echo '[auth_user]'",
    ('if command -v sqlite3 >/dev/null 2>&1; then find {0}/databases -maxdepth 1 -type f | head -n 1 | xargs -r sqlite3 ''SELECT slot,id,name FROM auth_user;''; else echo ''sqlite3 unavailable on device''; fi' -f $base)
  ) -join '; '
  if ($PSCmdlet.ShouldProcess("$serial/$PackageId", 'Collect root-only read-only sandbox evidence')) {
    $result = Invoke-Checked adb @('-s', $serial, 'shell', 'sh', '-c', $shell) -Capture
    Assert-NoSecret $result 'Sandbox evidence'
    $result | Set-Content -Encoding UTF8 (Join-Path $evidenceRoot "$Label-sandbox.txt")
  }
}

function Clear-Logcat {
  $serial = Get-DeviceSerial
  if ($PSCmdlet.ShouldProcess($serial, 'Clear logcat')) {
    Invoke-Checked adb @('-s', $serial, 'logcat', '-c')
  }
}

function Collect-Logcat {
  Ensure-EvidenceDirectory
  $serial = Get-DeviceSerial
  $pidText = & adb -s $serial shell pidof $PackageId 2>$null
  $args = @('-s', $serial, 'logcat', '-d')
  if ($LASTEXITCODE -eq 0 -and $pidText) { $args += @('--pid', $pidText.Trim()) }
  $log = Invoke-Checked adb $args -Capture
  Assert-NoSecret $log 'Logcat'
  if ($log -match 'FATAL EXCEPTION') { throw 'Logcat contains FATAL EXCEPTION' }
  $path = Join-Path $evidenceRoot "$Label-logcat.txt"
  if ($PSCmdlet.ShouldProcess($path, 'Write filtered logcat evidence')) {
    $log | Set-Content -Encoding UTF8 $path
  }
}

function Create-TemporaryCa {
  Ensure-EvidenceDirectory
  if (-not $PSCmdlet.ShouldProcess($caDir, 'Create temporary local CA and localhost certificate')) { return }
  New-Item -ItemType Directory -Force -Path $caDir | Out-Null
  'subjectAltName=DNS:localhost,IP:127.0.0.1' | Set-Content -Encoding ASCII $serverExt
  Invoke-Checked openssl @('req', '-x509', '-newkey', 'rsa:2048', '-sha256', '-days', '2', '-nodes', '-subj', '/CN=M19 Local Test CA', '-keyout', $caKey, '-out', $caCert)
  Invoke-Checked openssl @('req', '-newkey', 'rsa:2048', '-nodes', '-subj', '/CN=localhost', '-keyout', $serverKey, '-out', $serverCsr)
  Invoke-Checked openssl @('x509', '-req', '-in', $serverCsr, '-CA', $caCert, '-CAkey', $caKey, '-CAcreateserial', '-days', '2', '-sha256', '-extfile', $serverExt, '-out', $serverCert)
  (Get-Sha256 $caCert) |
    Set-Content -Encoding ASCII (Join-Path $caDir 'ca-sha256.txt')
}

function Install-TemporaryCa {
  Assert-RootDevice
  if (-not (Test-Path $caCert)) { throw "CA certificate not found: $caCert" }
  $serial = Get-DeviceSerial
  $subjectHash = Invoke-Checked openssl @('x509', '-inform', 'PEM', '-subject_hash_old', '-in', $caCert, '-noout') -Capture
  $remoteName = "$($subjectHash.Trim()).0"
  $remoteTmp = "/data/local/tmp/$remoteName"
  $remoteStore = "/system/etc/security/cacerts/$remoteName"
  if ($PSCmdlet.ShouldProcess("$serial/$remoteStore", 'Install temporary test CA')) {
    Invoke-Checked adb @('-s', $serial, 'shell', 'find', '/system/etc/security/cacerts', '-maxdepth', '1', '-type', 'f', '-printf', '%f\n') -Capture |
      Set-Content -Encoding ASCII $caBeforePath
    Invoke-Checked adb @('-s', $serial, 'push', $caCert, $remoteTmp) | Out-Null
    Invoke-Checked adb @('-s', $serial, 'remount') | Out-Null
    Invoke-Checked adb @('-s', $serial, 'shell', 'cp', $remoteTmp, $remoteStore)
    Invoke-Checked adb @('-s', $serial, 'shell', 'chmod', '644', $remoteStore)
    $remoteName | Set-Content -Encoding ASCII $installedCaMarker
    Invoke-Checked adb @('-s', $serial, 'shell', 'stop')
    Invoke-Checked adb @('-s', $serial, 'shell', 'start')
    Invoke-Checked adb @('-s', $serial, 'wait-for-device')
  }
}

function Remove-TemporaryCa {
  Assert-RootDevice
  if (-not (Test-Path $installedCaMarker)) { throw 'Installed CA marker is missing; wipe the AVD before continuing.' }
  $serial = Get-DeviceSerial
  $remoteName = (Get-Content $installedCaMarker -Raw).Trim()
  $remoteStore = "/system/etc/security/cacerts/$remoteName"
  if ($PSCmdlet.ShouldProcess("$serial/$remoteStore", 'Remove temporary test CA')) {
    Invoke-Checked adb @('-s', $serial, 'remount') | Out-Null
    Invoke-Checked adb @('-s', $serial, 'shell', 'rm', '-f', $remoteStore)
    $remaining = & adb -s $serial shell "if [ -e '$remoteStore' ]; then echo present; else echo absent; fi"
    if ($LASTEXITCODE -ne 0 -or ($remaining -join '').Trim() -ne 'absent') {
      throw 'Temporary CA cleanup failed; wipe the AVD.'
    }
    Invoke-Checked adb @('-s', $serial, 'shell', 'find', '/system/etc/security/cacerts', '-maxdepth', '1', '-type', 'f', '-printf', '%f\n') -Capture |
      Set-Content -Encoding ASCII $caAfterPath
    if (-not (Test-Path $caBeforePath)) { throw 'Original system CA evidence is missing; wipe the AVD.' }
    $before = @(Get-Content $caBeforePath | Sort-Object)
    $after = @(Get-Content $caAfterPath | Sort-Object)
    if (Compare-Object $before $after) { throw 'System CA set was not restored exactly; wipe the AVD.' }
    Remove-Item -Force $installedCaMarker
    Invoke-Checked adb @('-s', $serial, 'shell', 'stop')
    Invoke-Checked adb @('-s', $serial, 'shell', 'start')
    Invoke-Checked adb @('-s', $serial, 'wait-for-device')
  }
}

function Reverse-FixturePort {
  $serial = Get-DeviceSerial
  if ($PSCmdlet.ShouldProcess("$serial/tcp:$FixturePort", 'Configure adb reverse')) {
    Invoke-Checked adb @('-s', $serial, 'reverse', "tcp:$FixturePort", "tcp:$FixturePort")
  }
}

function Show-Plan {
  Write-Step "Workspace: $workspaceRoot"
  Write-Step "Evidence: $evidenceRoot (must remain untracked)"
  Write-Step "AVD: $Avd; package: $PackageId; fixture port: $FixturePort"
  Write-Step 'Capabilities: root/device metadata, artifact metadata, install/clear/launch/force-stop, UI evidence, read-only sandbox inspection, temporary CA lifecycle, adb reverse, logcat gate.'
  Write-Step 'No helper writes credential, SQLite user, SharedPreferences values, Session state, App manifest, network security config, or Dio trust policy.'
}

Require-Command flutter
Require-Command adb
Require-Command python
Require-Command git
Require-Command openssl
Assert-AvdExists
Assert-EvidenceDirectoryUntracked

switch ($Action) {
  'Plan' { Show-Plan }
  'Prepare' { Write-DeviceMetadata }
  'Artifact' { Write-ArtifactMetadata }
  'Install' { Install-Apk }
  'ClearData' { Clear-AppData }
  'Launch' { Start-App }
  'ForceStop' { Stop-App }
  'CaptureUi' { Capture-UiEvidence }
  'InspectSandbox' { Inspect-Sandbox }
  'ClearLogcat' { Clear-Logcat }
  'CollectLogcat' { Collect-Logcat }
  'CreateCa' { Create-TemporaryCa }
  'InstallCa' { Install-TemporaryCa }
  'RemoveCa' { Remove-TemporaryCa }
  'ReversePort' { Reverse-FixturePort }
  default { throw "Unsupported action: $Action" }
}
