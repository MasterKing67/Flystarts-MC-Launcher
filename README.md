# 🎮 Flystarts Minecraft Launcher

![PowerShell](https://img.shields.io/badge/Built%20with-PowerShell-blue?logo=powershell)
![Minecraft Versions](https://img.shields.io/badge/Supports-Classic%20%E2%86%92%20Latest-green?logo=minecraft)
![Offline](https://img.shields.io/badge/Mode-Offline-lightgrey)
![License](https://img.shields.io/badge/License-MIT-yellow)

A lightweight **PowerShell-based offline Minecraft launcher** that automatically downloads the required Minecraft files directly from Mojang and launches any supported version.

Inspired by the simplicity of launchers like TLauncher while remaining **offline-only**.

---

## ✨ Features

- 🎮 Supports Minecraft versions from **Classic (2009)** to the **latest release**
- 📦 Automatically downloads Mojang libraries
- 🎵 Downloads assets (sounds, textures, language files)
- 📂 Builds the correct Java classpath automatically
- 🧩 Extracts native DLLs automatically
- ⚡ One-click PowerShell launcher
- 👤 Offline mode using dummy credentials (`TestUser`)
- 🔄 JSON-driven version handling

---

## 📂 How It Works

```mermaid
graph TD

A[Minecraft Version] --> B[Download Version JSON]
B --> C[Download Libraries]
C --> D[Build Classpath]
D --> E[Extract Natives]
E --> F[Launch Minecraft]

B --> G[Download Asset Index]
G --> H[Download Assets]
H --> F
```

---

## 📅 Supported Minecraft Versions

```mermaid
timeline
    title Minecraft Version Support

    2009 : Classic
    2010 : Alpha
    2011 : Beta → Minecraft 1.0
    2013 : 1.6 • 1.7
    2014 : 1.8
    2015 : 1.9
    2016 : 1.10 • 1.11
    2017 : 1.12
    2018 : 1.13
    2019 : 1.14 • 1.15
    2020 : 1.16
    2021 : 1.17 • 1.18
    2022 : 1.19
    2023 : 1.20
    2024 : 1.21
    Latest : Always Supported
```

---

## ⚙️ Requirements

- Windows 10 or Windows 11
- Windows PowerShell
- Java 8 or newer
  - Recommended: Java 17 or Java 21
- Internet connection (first launch only)

After the first launch, downloaded libraries and assets are stored locally.

---

## 🚀 Installation

Clone the repository:

```bash
git clone https://github.com/MasterKing67/Flystarts-Minecraft-Launcher.git
cd Flystarts-Minecraft-Launcher
```

Run the launcher:

```powershell
.\launcher.ps1
```

The launcher will automatically:

1. Detect the selected Minecraft version
2. Download missing libraries
3. Download required assets
4. Extract native files
5. Build the Java classpath
6. Launch Minecraft

---

## 📁 Project Structure

```
Flystarts-Minecraft-Launcher/
│
├── launcher.ps1
└── README.md
└── launcher.json
```

---

## 🌐 Downloads From

The launcher downloads official files directly from Mojang:

- Version manifests
- Version JSON files
- Libraries
- Assets
- Native files

No third-party download servers are used.

---

## ⚠️ Limitations

- Offline mode only
- Uses dummy credentials (`TestUser`)
- Multiplayer servers that require Microsoft authentication will not work.
- Microsoft account login is **not included**.

---

## 📜 License

This project is licensed under the **MIT License**.

Feel free to use, modify, and distribute it.

---

## ❤️ Credits

- Mojang Studios — Minecraft
- Microsoft
- PowerShell
- Minecraft community

---

## ⭐ Support

If you enjoy this project, consider giving it a ⭐ on GitHub!

Contributions, issues, and pull requests are always welcome.
