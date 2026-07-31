# ================================
# Flystarts Minecraft Launcher (TLauncher-style)
# ================================

$GameDir    = "D:\Flystarts Launcher\.minecraft"
$Version    = "1.12.2"
$VersionJsonPath = "$GameDir\versions\$Version\$Version.json"
$AssetsDir  = "$GameDir\assets"
$Libraries  = "$GameDir\libraries"
$NativesDir = "$GameDir\natives"

# Ensure directories exist
New-Item -ItemType Directory -Force -Path $AssetsDir | Out-Null
New-Item -ItemType Directory -Force -Path "$AssetsDir\indexes" | Out-Null
New-Item -ItemType Directory -Force -Path "$AssetsDir\objects" | Out-Null
New-Item -ItemType Directory -Force -Path $NativesDir | Out-Null

# Load version JSON
$VersionJson = Get-Content $VersionJsonPath | ConvertFrom-Json
$MainClass   = $VersionJson.mainClass

# Download libraries listed in JSON
foreach ($lib in $VersionJson.libraries) {
    if ($lib.downloads.artifact) {
        $path = $lib.downloads.artifact.path
        $url  = $lib.downloads.artifact.url
        $target = Join-Path $Libraries $path
        if (!(Test-Path $target)) {
            New-Item -ItemType Directory -Force -Path (Split-Path $target -Parent) | Out-Null
            Invoke-WebRequest -Uri $url -OutFile $target
        }
    }
}

# Download asset index from Mojang launchermeta
$AssetIndexUrl = $VersionJson.assetIndex.url
$AssetIndexPath = "$AssetsDir\indexes\$($VersionJson.assetIndex.id).json"
if (!(Test-Path $AssetIndexPath)) {
    Invoke-WebRequest -Uri $AssetIndexUrl -OutFile $AssetIndexPath
}
$Index = Get-Content $AssetIndexPath | ConvertFrom-Json

# Download missing asset objects
foreach ($obj in $Index.objects.GetEnumerator()) {
    $hash = $obj.Value.hash
    $subDir = $hash.Substring(0,2)
    $targetPath = "$AssetsDir\objects\$subDir\$hash"
    if (!(Test-Path $targetPath)) {
        New-Item -ItemType Directory -Force -Path "$AssetsDir\objects\$subDir" | Out-Null
        $url = "https://resources.download.minecraft.net/$subDir/$hash"
        Invoke-WebRequest -Uri $url -OutFile $targetPath
    }
}

# Build classpath from JSON libraries + version jar
$Libs = foreach ($lib in $VersionJson.libraries) {
    if ($lib.downloads.artifact) {
        Join-Path $Libraries $lib.downloads.artifact.path
    }
}
$Classpath = ($Libs -join ";") + ";$GameDir\versions\$Version\$Version.jar"

# Launch Minecraft
java "-Djava.library.path=$NativesDir" -cp "$Classpath" $MainClass `
--username TestUser `
--version $Version `
--gameDir $GameDir `
--assetsDir $AssetsDir `
--assetIndex $($VersionJson.assetIndex.id) `
--uuid 00000000-0000-0000-0000-000000000000 `
--accessToken 0 `
--userType mojang `
--versionType release
