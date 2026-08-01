# Flystarts Minecraft Launcher
# Uses launcher.json for config and versiontable.json for piston-data links

# --- Setup base directories ---
Write-Host "`nChoose Minecraft folder location:"
Write-Host "1) Portable (next to script or current folder)"
Write-Host "2) AppData (like official launcher)"
$pathChoice = Read-Host "Enter choice (1-2)"

if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    $ScriptDir = (Get-Location).Path
} else {
    $ScriptDir = $PSScriptRoot
}

switch ($pathChoice) {
    "1" { $MinecraftDir = Join-Path $ScriptDir ".minecraft" }
    "2" { $MinecraftDir = Join-Path $env:APPDATA ".minecraft" }
    default {
        Write-Host "⚠️ Invalid choice, defaulting to portable mode."
        $MinecraftDir = Join-Path $ScriptDir ".minecraft"
    }
}

$ModsDir = Join-Path $MinecraftDir "mods"
$ConfigFile = Join-Path $MinecraftDir "launcher.json"
$VersionTablePath = Join-Path $MinecraftDir "versiontable.json"

$folders = @(
    $MinecraftDir,
    (Join-Path $MinecraftDir "versions"),
    (Join-Path $MinecraftDir "assets"),
    (Join-Path $MinecraftDir "libraries"),
    $ModsDir
)
foreach ($f in $folders) {
    if (-not (Test-Path $f)) {
        New-Item -ItemType Directory -Path $f | Out-Null
    }
}

# --- Safe download with retry ---
function Safe-Download {
    param($Url, $OutFile, $Retries = 3)
    $attempt = 0
    while ($attempt -lt $Retries) {
        try {
            if (-not (Test-Path $OutFile)) {
                Invoke-WebRequest -Uri $Url -OutFile $OutFile -ErrorAction Stop
            }
            return $true
        } catch {
            $attempt++
            Write-Host "⚠️ Attempt $attempt failed for $Url" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
    }
    Write-Host "❌ Failed to download $Url after $Retries attempts" -ForegroundColor Red
    return $false
}

# --- Config creation ---
function Create-Config {
    $LauncherName = Read-Host "Enter launcher name"
    $LauncherDesc = Read-Host "Enter launcher description"
    $Username = Read-Host "Enter your Minecraft username"

    Write-Host "`nChoose RAM allocation:"
    Write-Host "1) 2GB"
    Write-Host "2) 4GB"
    Write-Host "3) 8GB"
    $ramChoice = Read-Host "Enter choice (1-3)"
    switch ($ramChoice) {
        "1" { $Ram = "2G" }
        "2" { $Ram = "4G" }
        "3" { $Ram = "8G" }
        default { $Ram = "2G" }
    }

    $Config = @{
        LauncherName = $LauncherName
        LauncherDesc = $LauncherDesc
        Username = $Username
        Ram = $Ram
    }
    $Config | ConvertTo-Json | Set-Content $ConfigFile
    Write-Host "💾 Saved configuration: $LauncherName ($LauncherDesc), User: $Username, RAM: $Ram"
    return $Config
}

# --- Load config ---
if (Test-Path $ConfigFile) {
    $Config = Get-Content $ConfigFile | ConvertFrom-Json
    Write-Host "✅ Loaded config: $($Config.LauncherName) ($($Config.LauncherDesc)), User: $($Config.Username), RAM: $($Config.Ram)"
    Write-Host "`nDo you want to change settings? (Y/N)"
    $change = Read-Host
    if ($change -eq "Y") {
        $Config = Create-Config
    }
} else {
    $Config = Create-Config
}

$LauncherName = $Config.LauncherName
$LauncherDesc = $Config.LauncherDesc
$Username = $Config.Username
$Ram = $Config.Ram

# --- Load VersionsTable from JSON ---
if (Test-Path $VersionTablePath) {
    $VersionsTable = Get-Content $VersionTablePath | ConvertFrom-Json
    Write-Host "✅ Loaded version table from versiontable.json"
} else {
    Write-Host "❌ versiontable.json not found. Please place it in $MinecraftDir"
    exit
}

# --- Show available versions ---
Write-Host "`nAvailable versions:"
$i = 0
foreach ($v in $VersionsTable.PSObject.Properties.Name) {
    Write-Host "$i) $v"
    $i++
}
$choice = Read-Host "Enter number of version"
$Version = ($VersionsTable.PSObject.Properties.Name)[$choice]

$VersionDir = "$MinecraftDir\versions\$Version"
if (-not (Test-Path $VersionDir)) { New-Item -ItemType Directory -Path $VersionDir | Out-Null }

$ServerJarPath = "$VersionDir\server.jar"
$ClientJarPath = "$VersionDir\client.jar"

Safe-Download $VersionsTable.$Version.Server $ServerJarPath | Out-Null
Safe-Download $VersionsTable.$Version.Client $ClientJarPath | Out-Null

# --- Log file ---
$LogFile = "$MinecraftDir\launcher.log"
"Launching $LauncherName at $(Get-Date)" | Out-File $LogFile -Append

# --- Launch Minecraft ---
$Args = @(
    "-Xmx$Ram"
    "-cp", $ClientJarPath
    "net.minecraft.client.main.Main"
    "--username", $Username
    "--version", $Version
    "--gameDir", $MinecraftDir
)

Write-Host "`n🚀 Launching $LauncherName..."
Write-Host "$LauncherDesc"
try {
    Start-Process "java" -ArgumentList $Args -NoNewWindow -Wait
    Write-Host "✅ Minecraft launched successfully!"
    "Minecraft launched successfully." | Out-File $LogFile -Append
} catch {
    Write-Host "❌ Failed to launch Java. Ensure Java is installed and added to PATH." -ForegroundColor Red
    "Launch failed: $_" | Out-File $LogFile -Append
}
