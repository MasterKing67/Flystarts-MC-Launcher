# 🎮 Flystarts Minecraft Launcher

[![PowerShell](https://img.shields.io/badge/PowerShell-5%2B-5391FE?style=for-the-badge&logo=powershell)](https://learn.microsoft.com/powershell/)
[![Minecraft](https://img.shields.io/badge/Minecraft-Launcher-62B74A?style=for-the-badge&logo=minecraft)](https://www.minecraft.net/)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)
[![GitHub](https://img.shields.io/badge/GitHub-Project-181717?style=for-the-badge&logo=github)](https://github.com/yourusername/Flystarts-MC-Launcher)

A lightweight, open-source **PowerShell Minecraft Launcher** featuring automatic downloads, persistent settings, online version support, and a simple offline launcher experience.

---

# ✨ Features

- 🎮 Launch Minecraft with a custom PowerShell launcher
- 💾 Persistent settings stored in `launcher.json`
- 🌐 Always up-to-date Minecraft versions from the online piston-data table
- 🔄 Automatic retry logic for failed downloads
- 📝 Built-in logging (`launcher.log`)
- ⚙️ Custom launcher settings
- 📂 Portable or AppData installation

---

# 📂 Project Structure

```text
Flystarts-MC-Launcher/
│
├── launcher.ps1          # Main launcher script
├── launcher.json         # User configuration
├── launcher.log          # Launcher logs
├── README.md
└── LICENSE
```

> **Note**
>
> Minecraft versions are downloaded dynamically from the online piston-data source, so no local `versiontable.json` is required.

---

# 🚀 Getting Started

## 1. Clone the Repository

```powershell
git clone https://github.com/MasterKing67/Flystarts-MC-Launcher.git
cd Flystarts-MC-Launcher
```

## 2. Launch Flystarts

```powershell
.\launcher.ps1
```

---

# ⚙️ First-Time Setup

On the first launch, Flystarts will ask you to configure:

- 👤 Minecraft username
- 💾 RAM allocation
- 🎨 Launcher name
- 📝 Launcher description
- 📂 Minecraft installation location

Your preferences are automatically saved in:

```text
launcher.json
```

---

# 🎮 Selecting a Minecraft Version

Minecraft versions are fetched automatically from the online piston-data version list.

Simply:

1. Open the version selector.
2. Choose a version.
3. Flystarts downloads the required files.
4. Minecraft launches automatically.

---

# 📥 Downloads

Flystarts automatically downloads:

- Client JAR
- Server JAR
- Required metadata
- Missing dependencies

If a download fails, the launcher automatically retries.

---

# 📝 Logging

Launcher activity is saved to:

```text
launcher.log
```

The log includes:

- Download progress
- Errors
- Launch commands
- Configuration changes

---

# 📌 Requirements

| Requirement | Version |
|-------------|---------|
| 🪟 Windows | Windows 10 / 11 |
| 💻 PowerShell | 5.1 or newer |
| ☕ Java | Installed and added to `PATH` |
| 🌐 Internet | Required for downloading Minecraft files |

---

# 📸 Screenshots

### 🖥️ Launcher Menu

_Add a screenshot here_

---

### 🎮 Minecraft Integration

_Add a screenshot here_

---

### 📦 GitHub Project

_Add a repository screenshot here_

---

# 🤝 Contributing

Contributions are welcome!

You can help by:

- 🐞 Fixing bugs
- ✨ Adding new features
- 📖 Improving documentation
- 🖼️ Adding screenshots
- 🎨 Improving the launcher interface

Please open an Issue or Pull Request before making major changes.

---

# 📜 License

This project is licensed under the **MIT License**.

You are free to use, modify, distribute, and fork this project under the terms of the MIT License.

See the **LICENSE** file for details.
