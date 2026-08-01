# Flystarts Minecraft Launcher
# Interactive launcher with config.json persistence + mod downloads

# --- Setup base directories ---
$MinecraftDir = "$PSScriptRoot\.minecraft"
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

# --- Load or create config ---
if (Test-Path $ConfigFile) {
    $Config = Get-Content $ConfigFile | ConvertFrom-Json
    $LauncherName = $Config.LauncherName
    $LauncherDesc = $Config.LauncherDesc
    $Username = $Config.Username
    $Ram = $Config.Ram
} else {
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
    Write-Host "Saved configuration to config.json"
}

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

# --- Download version JSON, assets, libraries (same as before) ---
# [Reuse your working code for JSON/assets/libs here]

# --- Mod downloader functions ---
function Download-ModrinthMod {
    param($Slug, $ModsDir)
    $url = "https://api.modrinth.com/v2/project/$Slug/version"
    $response = Invoke-RestMethod -Uri $url
    $latest = $response[0].files[0].url
    $fileName = Split-Path $latest -Leaf
    Invoke-WebRequest -Uri $latest -OutFile "$ModsDir\$fileName"
    Write-Host "Downloaded Modrinth mod: $fileName"
}

function Download-TLMod {
    param($DirectUrl, $ModsDir)
    $fileName = Split-Path $DirectUrl -Leaf
    Invoke-WebRequest -Uri $DirectUrl -OutFile "$ModsDir\$fileName"
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

Write-Host "`nLaunching $LauncherName..."
Write-Host "$LauncherDesc"
Start-Process "java" -ArgumentList $Args -NoNewWindow -Wait
