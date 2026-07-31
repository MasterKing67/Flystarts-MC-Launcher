Flystarts Minecraft Launcher
https://img.shields.io/badge/Built%20with-PowerShell-blue?logo=powershell  
https://img.shields.io/badge/Supports-Classic%20%E2%86%92%20Latest-green?logo=minecraft  
https://img.shields.io/badge/Mode-Offline-lightgrey  
https://img.shields.io/badge/License-MIT-yellow

A PowerShell‑based offline Minecraft launcher that mimics TLauncher‑style behavior.
It automatically downloads Mojang libraries, assets, and builds the correct classpath to launch any version of Minecraft — from Classic to the latest release.

✨ Features
Supports all versions → from Minecraft Classic (2009) to the newest release.

JSON‑driven classpath → avoids LWJGL sealing violations.

Automatic asset downloads → fetches sounds, textures, and indexes from Mojang servers.

Native extraction → unpacks DLLs into the natives folder.

Offline mode → launches with dummy credentials (TestUser).

Plug‑and‑play PowerShell script → one‑click run for Windows users.

📂 Project Flow 
graph TD
    A[Minecraft Versions: Classic → Latest] --> B[Version JSON]
    B --> C[Download Libraries]
    C --> D[Build Classpath]
    D --> E[Launch Minecraft]

    B --> F[Asset Index (launchermeta)]
    F --> G[Download Objects (resources.download.minecraft.net)]
    G --> H[assets/objects]

    C --> I[Natives DLL extraction]
    I --> J[natives folder]

    E --> K[MainClass: net.minecraft.client.main.Main]
Minecraft Version That The MC Launcher Supports

timeline
    title Minecraft Evolution (2009 → Latest)
    2009 : Classic released
    2011 : Beta → Official 1.0
    2013 : 1.6 (Horses), 1.7 (Biome Update)
    2014 : 1.8 (Bountiful Update)
    2016 : 1.9 (Combat Update), 1.10
    2017 : 1.12 (World of Color Update)
    2019 : 1.14 (Village & Pillage)
    2020 : 1.16 (Nether Update)
    2021 : 1.17–1.18 (Caves & Cliffs)
    2022 : 1.19 (Wild Update)
    2023 : 1.20 (Trails & Tales)
    2024 : 1.21 (Endless possibilities…)
    2026 : Latest release supported
⚙️ Requirements
Java 8+ (tested with Java 17 and 21).

Windows PowerShell (preinstalled on Windows 10/11).

Internet connection (for first‑time asset/library download).

🚀 Usage
Clone the repo:
git clone https://github.com/YourUsername/Flystarts-Minecraft-Launcher.git
cd Flystarts-Minecraft-Launcher
Run the PowerShell script:
./launcher.ps1
Minecraft (any version) will launch with assets, libraries, and natives automatically set up.
📜 License
MIT License — free to use, modify, and distribute.

🧩 Notes
This launcher is offline‑only (dummy credentials).

For online play, you must use Mojang’s official launcher.

Assets and libraries are downloaded directly from Mojang’s CDN.
