# Flystarts Minecraft Launcher
# Creates .minecraft folder, downloads chosen version JSON + assets, and launches Minecraft

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

# --- Ask user for version ---
Write-Host "Enter Minecraft version (e.g., 1.12.2, 1.8.9, 1.20.1):"
$Version = Read-Host
$VersionDir = "$MinecraftDir\versions\$Version"
$VersionJsonPath = "$VersionDir\$Version.json"

if (-not (Test-Path $VersionDir)) {
    New-Item -ItemType Directory -Path $VersionDir | Out-Null
}

# --- Download version manifest + JSON ---
$ManifestUrl = "https://launchermeta.mojang.com/mc/game/version_manifest.json"
$Manifest = Invoke-RestMethod -Uri $ManifestUrl
$VersionInfo = $Manifest.versions | Where-Object { $_.id -eq $Version }

if (-not (Test-Path $VersionJsonPath)) {
    if ($VersionInfo) {
        Invoke-WebRequest -Uri $VersionInfo.url -OutFile $VersionJsonPath
        Write-Host "Downloaded $Version version JSON."
    } else {
        Write-Error "Version $Version not found in Mojang manifest."
        exit
    }
}

# --- Parse version JSON ---
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
