# Flystarts Minecraft Launcher
# Config persistence + mod downloads + retry logic + progress bar + logging + settings menu

# --- Setup base directories ---
Write-Host "`nChoose Minecraft folder location:"
Write-Host "1) Portable (next to script)"
Write-Host "2) AppData (like official launcher)"
$pathChoice = Read-Host "Enter choice (1-2)"

# If $PSScriptRoot is empty (when running via irm | iex), fallback to current directory
if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    $ScriptDir = Get-Location
} else {
    $ScriptDir = $PSScriptRoot
}

switch ($pathChoice) {
    "1" { $MinecraftDir = Join-Path $ScriptDir ".minecraft" }
    "2" { $MinecraftDir = "$env:APPDATA\.minecraft" }
    default {
        Write-Host "⚠️ Invalid choice, defaulting to portable mode."
        $MinecraftDir = Join-Path $ScriptDir ".minecraft"
    }
}

$ModsDir = "$MinecraftDir\mods"
$ConfigFile = "$MinecraftDir\config.json"

$folders = @(
    $MinecraftDir,
    "$MinecraftDir\versions",
    "$MinecraftDir\assets\indexes",
    "$MinecraftDir\assets\objects",
    "$MinecraftDir\libraries",
    "$MinecraftDir\natives",
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

# --- Load config with settings menu ---
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

# --- Fetch Mojang manifest + version selection ---
$ManifestUrl = "https://launchermeta.mojang.com/mc/game/version_manifest.json"
$Manifest = Invoke-RestMethod -Uri $ManifestUrl
$Versions = $Manifest.versions

Write-Host "`nAvailable versions (first 10):"
for ($i=0; $i -lt 10; $i++) {
    Write-Host "$i) $($Versions[$i].id)"
}
$choice = Read-Host "Enter number of version"
$Version = $Versions[$choice].id

# --- Setup version paths ---
$VersionDir = "$MinecraftDir\versions\$Version"
$VersionJsonPath = "$VersionDir\$Version.json"
$VersionJarPath = "$VersionDir\$Version.jar"

if (-not (Test-Path $VersionDir)) { New-Item -ItemType Directory -Path $VersionDir | Out-Null }

# --- Download version JSON ---
$VersionInfo = $Versions | Where-Object { $_.id -eq $Version }
Safe-Download $VersionInfo.url $VersionJsonPath | Out-Null
$VersionJson = Get-Content $VersionJsonPath | ConvertFrom-Json

# --- Download client JAR ---
Safe-Download $VersionJson.downloads.client.url $VersionJarPath | Out-Null

# --- Download asset index ---
$AssetIndexUrl = $VersionJson.assetIndex.url
$AssetIndexPath = "$MinecraftDir\assets\indexes\$Version.json"
Safe-Download $AssetIndexUrl $AssetIndexPath | Out-Null
$Index = Get-Content $AssetIndexPath | ConvertFrom-Json

# --- Download assets with progress bar ---
$objects = $Index.objects.PSObject.Properties
$total = $objects.Count
$count = 0
foreach ($obj in $objects) {
    $hash = $obj.Value.hash
    $subdir = $hash.Substring(0,2)
    $AssetPath = "$MinecraftDir\assets\objects\$subdir\$hash"
    Safe-Download "https://resources.download.minecraft.net/$subdir/$hash" $AssetPath | Out-Null
    $count++
    $percent = [math]::Round(($count / $total) * 100, 2)
    Write-Progress -Activity "Downloading assets" -Status "$percent% complete" -PercentComplete $percent
}

# --- Download libraries with progress bar ---
$Classpath = ""
$totalLibs = $VersionJson.libraries.Count
$countLibs = 0
foreach ($lib in $VersionJson.libraries) {
    if ($lib.downloads.artifact.url) {
        $libPath = "$MinecraftDir\libraries\$($lib.downloads.artifact.path)"
        $libDir = Split-Path $libPath
        if (-not (Test-Path $libDir)) { New-Item -ItemType Directory -Path $libDir | Out-Null }
        Safe-Download $lib.downloads.artifact.url $libPath | Out-Null
        $Classpath += "$libPath;"
    }
    $countLibs++
    $percentLibs = [math]::Round(($countLibs / $totalLibs) * 100, 2)
    Write-Progress -Activity "Downloading libraries" -Status "$percentLibs% complete" -PercentComplete $percentLibs
}
$Classpath += "$VersionJarPath"

# --- Validate classpath ---
if ([string]::IsNullOrWhiteSpace($Classpath)) {
    Write-Host "❌ Error: Classpath is empty. Libraries or JAR missing." -ForegroundColor Red
    exit
}

# --- Extra Feature: Log file ---
$LogFile = "$MinecraftDir\launcher.log"
"Launching $LauncherName at $(Get-Date)" | Out-File $LogFile -Append

# --- Mod downloader functions ---
function Download-ModrinthMod {
    param($Slug, $ModsDir)
    try {
        $url = "https://api.modrinth.com/v2/project/$Slug/version"
        $response = Invoke-RestMethod -Uri $url
        $latest = $response[0].files[0].url
        $fileName = Split-Path $latest -Leaf
        Safe-Download $latest "$ModsDir\$fileName" | Out-Null
        Write-Host "Downloaded Modrinth mod: $fileName"
    } catch {
        Write-Host "❌ Failed to download Modrinth mod $Slug" -ForegroundColor Red
    }
}

function Download-TLMod {
    param($DirectUrl, $ModsDir)
    $fileName = Split-Path $DirectUrl -Leaf
    Safe-Download $DirectUrl "$ModsDir\$fileName" | Out-Null
    Write-Host "Downloaded TLMods mod: $fileName"
}

# --- Ask user about mods ---
Write-Host "`nDo you want to download mods? (Y/N)"
$modChoice = Read-Host
if ($modChoice -eq "Y") {
    Write-Host "Choose mod source:"
    Write-Host "1) Modrinth"
    Write-Host "2) TLMods (direct link)"
    $sourceChoice = Read-Host

    switch ($sourceChoice) {
        "1" {
            $Slug = Read-Host "Enter Modrinth slug (e.g. sodium)"
            Download-ModrinthMod -Slug $Slug -ModsDir $ModsDir
        }
        "2" {
            $DirectUrl = Read-Host "Enter TLMods direct download URL"
            Download-TLMod -DirectUrl $DirectUrl -ModsDir $ModsDir
        }
    }
}

# --- Launch Minecraft ---
$Args = @(
    "-Xmx$Ram"
    "-cp", $Classpath
    "net.minecraft.client.main.Main"
    "--username", $Username
    "--version", $Version
    "--gameDir", $MinecraftDir
    "--assetsDir", "$MinecraftDir\assets"
    "--assetIndex", $Version
)

Write-Host "`n🚀 Launching $LauncherName..."
Write-Host "$LauncherDesc"

# --- Log + Error Handling ---
$LogFile = "$MinecraftDir\launcher.log"
"Launching $LauncherName at $(Get-Date)" | Out-File $LogFile -Append

try {
    Start-Process "java" -ArgumentList $Args -NoNewWindow -Wait
    Write-Host "✅ Minecraft launched successfully!"
    "Minecraft launched successfully." | Out-File $LogFile -Append
} catch {
    Write-Host "❌ Failed to launch Java. Ensure Java is installed and added to PATH." -ForegroundColor Red
    "Launch failed: $_" | Out-File $LogFile -Append
}
