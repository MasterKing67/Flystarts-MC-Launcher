# Flystarts Minecraft Launcher
# Creates .minecraft folder, shows paginated menu of all versions, downloads assets/libs, and launches Minecraft

# --- Setup base directories ---
$MinecraftDir = "$PSScriptRoot\.minecraft"

# Ensure folder structure exists
$folders = @(
    $MinecraftDir,
    "$MinecraftDir\versions",
    "$MinecraftDir\assets\indexes",
    "$MinecraftDir\assets\objects",
    "$MinecraftDir\libraries",
    "$MinecraftDir\natives"
)
foreach ($f in $folders) {
    if (-not (Test-Path $f)) {
        New-Item -ItemType Directory -Path $f | Out-Null
    }
}

# --- Fetch Mojang manifest ---
$ManifestUrl = "https://launchermeta.mojang.com/mc/game/version_manifest.json"
$Manifest = Invoke-RestMethod -Uri $ManifestUrl
$Versions = $Manifest.versions

# --- Paginated menu ---
$PageSize = 10
$Page = 0
$TotalPages = [math]::Ceiling($Versions.Count / $PageSize)

function Show-Page {
    param($Page)
    Clear-Host
    Write-Host "Minecraft Versions (Page $($Page+1)/$TotalPages)" -ForegroundColor Cyan
    $start = $Page * $PageSize
    $end = [math]::Min($start + $PageSize, $Versions.Count)
    for ($i=$start; $i -lt $end; $i++) {
        Write-Host "$i) $($Versions[$i].id)"
    }
    Write-Host "`nN = Next page, P = Previous page, Q = Quit"
}

do {
    Show-Page $Page
    $choice = Read-Host "Enter number of version or command"
    switch ($choice.ToUpper()) {
        "N" { if ($Page -lt $TotalPages-1) { $Page++ } }
        "P" { if ($Page -gt 0) { $Page-- } }
        "Q" { exit }
        default {
            if ($choice -match '^\d+$' -and [int]$choice -lt $Versions.Count) {
                $Version = $Versions[$choice].id
                break
            }
        }
    }
} while (-not $Version)

# --- Setup version paths ---
$VersionDir = "$MinecraftDir\versions\$Version"
$VersionJsonPath = "$VersionDir\$Version.json"
if (-not (Test-Path $VersionDir)) { New-Item -ItemType Directory -Path $VersionDir | Out-Null }

# --- Download version JSON ---
$VersionInfo = $Versions | Where-Object { $_.id -eq $Version }
if (-not (Test-Path $VersionJsonPath)) {
    Invoke-WebRequest -Uri $VersionInfo.url -OutFile $VersionJsonPath
    Write-Host "Downloaded $Version version JSON."
}
$VersionJson = Get-Content $VersionJsonPath | ConvertFrom-Json

# --- Download asset index ---
$AssetIndexUrl = $VersionJson.assetIndex.url
$AssetIndexPath = "$MinecraftDir\assets\indexes\$Version.json"
if (-not (Test-Path $AssetIndexPath)) {
    Invoke-WebRequest -Uri $AssetIndexUrl -OutFile $AssetIndexPath
    Write-Host "Downloaded asset index for $Version."
}
$Index = Get-Content $AssetIndexPath | ConvertFrom-Json

# --- Download assets ---
foreach ($obj in $Index.objects.GetEnumerator()) {
    $hash = $obj.Value.hash
    $subdir = $hash.Substring(0,2)
    $AssetPath = "$MinecraftDir\assets\objects\$subdir\$hash"
    if (-not (Test-Path $AssetPath)) {
        $url = "https://resources.download.minecraft.net/$subdir/$hash"
        Invoke-WebRequest -Uri $url -OutFile $AssetPath
    }
}

# --- Download libraries + build classpath ---
$Classpath = ""
foreach ($lib in $VersionJson.libraries) {
    if ($lib.downloads.artifact.url) {
        $libPath = "$MinecraftDir\libraries\$($lib.downloads.artifact.path)"
        $libDir = Split-Path $libPath
        if (-not (Test-Path $libPath)) {
            if (-not (Test-Path $libDir)) { New-Item -ItemType Directory -Path $libDir | Out-Null }
            Invoke-WebRequest -Uri $lib.downloads.artifact.url -OutFile $libPath
        }
        $Classpath += "$libPath;"
    }
}
$Classpath += "$VersionDir\$Version.jar"

# --- Launch Minecraft ---
$Args = @(
    "-Xmx2G"
    "-cp", $Classpath
    "net.minecraft.client.main.Main"
    "--username", "TestUser"
    "--version", $Version
    "--gameDir", $MinecraftDir
    "--assetsDir", "$MinecraftDir\assets"
    "--assetIndex", $Version
)

Start-Process "java" -ArgumentList $Args -NoNewWindow -Wait
