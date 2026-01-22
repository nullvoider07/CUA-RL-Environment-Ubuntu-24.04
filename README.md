# CUA Ubuntu 24.04

**AI Agent GUI Control Base**  
**Version:** 0.1  
**Base Image:** Ubuntu 24.04 LTS  
**Architecture:** x86_64  
**Last Updated:** January 2026  
**Developer:** Kartik (NullVoider)

---

## Table of Contents

1. [Overview](#overview)
2. [Key Features](#key-features)
3. [Container Capabilities](#container-capabilities)
   - [Desktop Environment](#desktop-environment)
   - [Development Tools](#development-tools)
   - [System Services](#system-services)
   - [Remote Access](#remote-access)
4. [Technical Specifications](#technical-specifications)
   - [System Requirements](#system-requirements)
   - [Container Architecture](#container-architecture)
   - [Performance Metrics](#performance-metrics)
5. [Installation & Deployment](#installation--deployment)
   - [Prerequisites](#prerequisites)
   - [Building the Image](#building-the-image)
   - [Running the Container](#running-the-container)
6. [Configuration](#configuration)
   - [Environment Variables](#environment-variables)
   - [Volume Mounts](#volume-mounts)
   - [Port Mappings](#port-mappings)
7. [Installed Software](#installed-software)
8. [Development Environments](#development-environments)
9. [Services & Daemons](#services--daemons)
10. [The Eye Integration](#the-eye-integration)
11. [Remote Access Methods](#remote-access-methods)
12. [Troubleshooting](#troubleshooting)
13. [Advanced Usage](#advanced-usage)
14. [Security Considerations](#security-considerations)
15. [About This Project](#about-this-project)

---

## Overview

The **CUA Ubuntu 24.04 GPU Container** is a complete AI-ready development and automation environment designed for Computer Use Agents (CUA). It provides a full Ubuntu desktop experience with GPU acceleration, pre-configured development tools, and integrated monitoring capabilities.

### Purpose

This container is designed for:

- **AI Agent Development**: Pre-configured environment for building and testing computer use agents
- **Remote Development**: Full-featured desktop accessible via NoMachine, web terminal, and SSH
- **GPU-Accelerated Workloads**: NVIDIA GPU support with proper isolation and X11 configuration
- **Multi-Language Development**: Support for 10+ programming languages out of the box
- **Visual Monitoring**: Integrated Eye tool for screen capture and agent training data collection

### What Makes This Unique

- **Systemd Inside Docker**: Runs a full systemd init system for proper service management
- **Full GNOME Desktop**: Complete Ubuntu desktop experience with GPU acceleration
- **Zero-Configuration GPU**: Automatic NVIDIA GPU detection and configuration
- **Developer-Ready**: Pre-installed IDEs, tools, and language runtimes
- **Production Monitoring**: Built-in screen capture for AI training and debugging
- **Scale-Safe**: Dynamic username generation for running multiple containers

---

## Key Features

### Desktop & GUI
✅ **Full GNOME Desktop** - Ubuntu 24.04 with GNOME Shell (X11 mode)  
✅ **GPU Acceleration** - NVIDIA GPU support with automatic configuration  
✅ **Auto-Login** - Passwordless automatic login to desktop  
✅ **Dark Theme** - Pre-configured Yaru dark theme  
✅ **Virtual Display** - 1920x1080 @ 60Hz virtual monitor

### Development Tools
✅ **10+ Languages** - Python, Go, Rust, Java, C#, C++, Node.js, TypeScript, Kotlin, Scala  
✅ **VS Code** - Pre-installed with 15+ extensions  
✅ **Git & Git LFS** - Latest version with LFS support  
✅ **Docker-in-Docker** - Docker tools pre-installed  
✅ **Terminal Tools** - zsh, tmux, ranger, fzf, bat, eza, and more

### Remote Access
✅ **NoMachine** - High-performance remote desktop (4000/TCP)  
✅ **Web Terminal** - Browser-based terminal via ttyd (7681/TCP)  
✅ **Eye Server** - Screen capture endpoint (8080/TCP)  
✅ **SSH Ready** - SSH server support (2222/TCP)

### System Services
✅ **Systemd** - Full init system for proper service management  
✅ **Supervisor** - Process management for critical services  
✅ **Avahi** - mDNS/DNS-SD service discovery  
✅ **NetworkManager** - Network configuration  
✅ **PulseAudio** - Audio subsystem

### Monitoring & Automation
✅ **Eye Agent** - Automatic screen capture for AI training  
✅ **Persistent Storage** - 64GB virtual disk at `/mnt/data`  
✅ **Health Checks** - Built-in container health monitoring  
✅ **Log Management** - Centralized logging with rotation

---

## Container Capabilities

### Desktop Environment

**GNOME Shell 46** (X11 Mode)
- Full Ubuntu desktop experience
- Dark theme by default (Yaru)
- Disabled animations for performance
- Auto-login enabled
- Screen lock disabled
- Power management disabled (always-on)

**Pre-installed Applications**:
- **Browser**: Brave (default)
- **Editor**: VS Code, GNOME Text Editor
- **File Manager**: Nautilus with extensions
- **Terminal**: GNOME Terminal
- **Office**: LibreOffice (full suite)
- **Media**: VLC Media Player, Shotwell
- **PDF Viewer**: Evince
- **System Monitor**: GNOME System Monitor

**Desktop Customization**:
- Night light permanently enabled (2400K)
- Touchpad disabled by default
- No screensaver/lock screen
- Composition enabled (for smooth rendering)
- Dynamic workspaces disabled

### Development Tools

#### Programming Languages & Runtimes

| Language | Version | Package Manager | Notes |
|----------|---------|----------------|-------|
| **Python** | 3.14.2 | pip 25.3 | Default `python` command |
| **Go** | 1.25.5 | go modules | Workspace at `/usr/local/go-workspace` |
| **Rust** | stable | cargo | System-wide installation |
| **Node.js** | 25.2.1 | npm 11.7.0 | TypeScript & tsx included |
| **Java** | 25 (latest) | - | Oracle JDK |
| **C#/.NET** | 10.0 SDK | dotnet | LTS version |
| **C/C++** | clang/gcc | - | Both compilers available |
| **Kotlin** | 2.3.0 | - | Compiler installed |
| **Scala** | 3.7.4 | coursier | Latest stable |
| **PowerShell** | latest | - | Cross-platform shell |

#### IDEs & Editors

**Visual Studio Code** (latest)

Pre-installed extensions:
- C++ Tools Extension Pack
- Docker Extension
- Java Extension Pack
- Oracle Java Extension
- .NET Runtime & C# DevKit
- GitLab Workflow & GitLens
- Go Extension
- Python Extension Pack (Pylance, debugpy, environment manager)
- Rust Analyzer
- Scala Language Server

**Extension Management**:
- System-wide extensions at `/usr/share/code-extensions`
- User symlink: `~/.vscode/extensions` → system location
- Shared across all container instances

#### Build Tools & Utilities

- **CMake** & **Ninja** - Modern C++ build systems
- **GDB** & **LLDB** - Debuggers
- **Valgrind** - Memory debugging
- **cppcheck** - Static analysis
- **Git** (latest) - Version control with LFS
- **Docker tools** - For container development

### System Services

#### Core Services (Systemd)

1. **create-disk.service**
   - Creates 64GB virtual disk at `/var/lib/cua/disk.img`
   - Mounts at `/mnt/data` with ext4 filesystem
   - Auto-mounts on container start
   - User-owned (UID 1001)

2. **gpu-setup.service**
   - Detects and configures NVIDIA GPU
   - Injects PCI Bus ID into Xorg configuration
   - Applies GPU performance settings (PowerMizer)
   - Starts before GDM

3. **supervisord.service**
   - Manages Avahi and ttyd processes
   - Auto-restart on failures
   - Centralized logging

#### User Services (Systemd User)

1. **eye-agent.service**
   - Automatic screen capture service
   - Auto-discovers Eye server
   - Captures at 1.5s intervals (configurable)
   - Runs as user (UID 1001)

#### Managed Processes (Supervisor)

1. **avahi-daemon**
   - mDNS/DNS-SD service
   - Priority: 200 (high)
   - Auto-restart enabled

2. **ttyd**
   - Web-based terminal on port 7681
   - Runs as user (UID 1001)
   - Priority: 400

### Remote Access

#### NoMachine (Port 4000)

**Configuration**:
- Password authentication disabled
- Clipboard sharing enabled (both directions)
- Desktop sharing enabled
- Max concurrent sessions: 2
- Audio enabled (both directions)
- H.264 video codec
- 60 FPS frame rate limit
- Quality: High (level 2)
- Physical display: `:0` (no virtual desktop)

**Features**:
- Hardware-accelerated video
- Low-latency input
- Full desktop experience
- Multi-monitor support (if configured)

#### Web Terminal (Port 7681)

**ttyd Configuration**:
- Accessible at `http://<container-ip>:7681`
- Shell: bash
- User: UID 1001 (dynamic username)
- Environment: Full desktop environment variables

**Use Cases**:
- Quick terminal access
- Browser-based development
- Debugging without full desktop

#### Eye Server (Port 8080)

**Endpoints**:
- `/health` - Server health status
- `/snapshot.png` - Latest screenshot
- `/upload` - Frame upload endpoint
- `/admin/config` - Agent configuration
- `/debug` - Debug information

**Eye Agent**:
- Auto-starts on user login
- Discovers server automatically
- Captures screen every 1.5 seconds
- Format: PNG (configurable)
- Logs: `~/eye_agent.log`

---

## Technical Specifications

### System Requirements

#### Host Requirements

**Minimum**:
- Docker 24.0+ with buildx support
- 8 GB RAM
- 20 GB disk space
- x86_64 processor
- Linux kernel 5.0+ (for systemd support)

**Recommended**:
- 16 GB RAM
- 50 GB disk space
- NVIDIA GPU (for GPU acceleration)
- SSD storage

**For GPU Support**:
- NVIDIA GPU (Compute Capability 3.5+)
- NVIDIA Driver 470+ on host
- nvidia-container-toolkit installed
- Docker with `--gpus` support

#### Container Resource Usage

**Idle State**:
- RAM: ~2-3 GB
- CPU: <5%
- Disk: ~17 GB (image size)

**Active Development**:
- RAM: 4-8 GB
- CPU: 10-30%
- Disk: 17 GB + workspace data

**With GPU Workloads**:
- RAM: 6-12 GB
- VRAM: Varies by workload
- CPU: 20-50%

### Container Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    CUA Ubuntu Container                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   Systemd    │  │ Supervisor   │  │  User Init   │       │
│  │  (PID 1)     │  │  Daemon      │  │  Services    │       │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘       │
│         │                  │                  │             │
│  ┌──────▼──────────────────▼──────────────────▼───────┐     │
│  │              Service Layer                         │     │
│  │  • GPU Setup  • Disk Creation  • Network           │     │
│  │  • GDM3       • Avahi          • Eye Agent         │     │
│  └─────────────────────────┬──────────────────────────┘     │
│                            │                                │
│  ┌─────────────────────────▼───────────────────────────┐    │
│  │           GNOME Desktop (X11)                       │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐           │    │
│  │  │  Xorg    │  │  Mutter  │  │  Shell   │           │    │
│  │  │  :0      │  │ Compositor│ │  WM      │           │    │
│  │  └──────────┘  └──────────┘  └──────────┘           │    │
│  └─────────────────────────────────────────────────────┘    │
│                            │                                │
│  ┌─────────────────────────▼───────────────────────────┐    │
│  │            Application Layer                        │    │
│  │  • VS Code    • Brave      • Terminal               │    │
│  │  • NoMachine  • Eye Agent  • LibreOffice            │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└───────────────────────────┬─────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
   ┌────▼────┐         ┌────▼────┐        ┌────▼────┐
   │  GPU    │         │ Network │        │ Storage │
   │  :0     │         │ Ports   │        │ Volumes │
   └─────────┘         └─────────┘        └─────────┘
```

### Performance Metrics

#### Startup Time

- **All Services Ready**: 5-8 seconds

#### Service Startup Order

1. Systemd init (immediate)
2. create-disk.service (2-5s)
3. gpu-setup.service (5-15s)
4. GDM3 starts (after gpu-setup)
5. Auto-login to desktop (3-5s)
6. User services start (eye-agent, etc.)
7. NoMachine ready (2-3s)
8. All services operational

#### Network Performance

- **NoMachine**: 10-30 Mbps (depends on quality settings)
- **Eye Agent**: 0.5-2 MB/s upload (1.5s intervals)
- **ttyd**: <1 Mbps (text only)

---

## Installation & Deployment

### Prerequisites

1. **Install Docker** (24.0+):
```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```

2. **Install NVIDIA Container Toolkit** (for GPU support):
```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

3. **Verify GPU Support**:
```bash
docker run --rm --gpus all nvidia/cuda:12.0-base nvidia-smi
```

### Building the Image

#### Clone Repository
```bash
git clone https://github.com/nullvoider07/CUA-RL-Environment-Ubuntu-24.04.git
cd CUA-RL-Environment-Ubuntu-24.04
```

#### Build Command

**Standard Build**:
```bash
docker build -t cua-ubuntu:latest -f ubuntu-code-v0.1.dockerfile .
```

**With Build Arguments**:
```bash
docker build \
  --build-arg CONTAINER_ID=$(uuidgen | cut -c1-8) \
  -t cua-ubuntu:latest \
  -f ubuntu-code-v0.1.dockerfile .
```

**Optimized Build** (with BuildKit):
```bash
DOCKER_BUILDKIT=1 docker build \
  --progress=plain \
  --no-cache \
  -t cua-ubuntu:latest \
  -f ubuntu-code-v0.1.dockerfile .
```

#### Build Options

- `--no-cache`: Force rebuild all layers
- `--build-arg CONTAINER_ID=<id>`: Set custom container ID for username
- `--build-arg CUA_DISK_SIZE=16G`: Change virtual disk size (default: 8G)

### Running the Container

#### Basic Run

```bash
docker run -d \
  --name cua-dev \
  --hostname cua-workstation \
  --privileged \
  --gpus all \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  --cgroupns=host \
  -p 4000:4000 \
  -p 7681:7681 \
  -p 8080:8080 \
  -p 2222:22 \
  cua-ubuntu:latest
```

#### Production Run with Volumes

```bash
docker run -d \
  --name cua-dev \
  --hostname cua-workstation \
  --privileged \
  --gpus all \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  --cgroupns=host \
  -v ~/workspace:/workspace \
  -v cua-home:/home/cua-$(docker run --rm cua-ubuntu:latest id -un 1001) \
  -v cua-data:/mnt/data \
  -p 4000:4000 \
  -p 7681:7681 \
  -p 8080:8080 \
  -p 2222:22 \
  -e CUA_DISK_SIZE=16G \
  --restart unless-stopped \
  cua-ubuntu:latest
```

#### Docker Compose

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  cua-ubuntu:
    image: cua-ubuntu:latest
    container_name: cua-dev
    hostname: cua-workstation
    privileged: true
    restart: unless-stopped
    
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:rw
      - ./workspace:/workspace
      - cua-home:/home/cua-${CONTAINER_ID:-default}
      - cua-data:/mnt/data
    
    ports:
      - "4000:4000"   # NoMachine
      - "7681:7681"   # ttyd
      - "8080:8080"   # Eye Server
      - "2222:22"     # SSH
    
    environment:
      - CUA_DISK_SIZE=8G
      - NVIDIA_VISIBLE_DEVICES=all
      - NVIDIA_DRIVER_CAPABILITIES=all
    
    cgroupns: host

volumes:
  cua-home:
  cua-data:
```

Run:
```bash
docker-compose up -d
```

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CUA_DISK_SIZE` | `8G` | Virtual disk size for `/mnt/data` |
| `NVIDIA_VISIBLE_DEVICES` | `all` | GPU visibility |
| `NVIDIA_DRIVER_CAPABILITIES` | `compute,utility` | GPU capabilities |
| `DISPLAY` | `:0` | X11 display |
| `XDG_SESSION_TYPE` | `x11` | Session type |
| `GDK_BACKEND` | `x11` | GTK backend |
| `CONTAINER_ID` | (auto) | Used for unique username generation |

### Volume Mounts

#### Essential Mounts

1. **cgroup** (required for systemd):
```bash
-v /sys/fs/cgroup:/sys/fs/cgroup:rw
```

2. **Workspace** (development files):
```bash
-v ~/workspace:/workspace
```

3. **User Home** (persistent settings):
```bash
-v cua-home:/home/cua-<username>
```

4. **Data Disk** (application data):
```bash
-v cua-data:/mnt/data
```

#### Optional Mounts

**Shared Downloads**:
```bash
-v ~/Downloads:/home/cua-<username>/Downloads
```

**SSH Keys**:
```bash
-v ~/.ssh:/home/cua-<username>/.ssh:ro
```

**Git Configuration**:
```bash
-v ~/.gitconfig:/home/cua-<username>/.gitconfig:ro
```

### Port Mappings

| Port | Service | Protocol | Description |
|------|---------|----------|-------------|
| 4000 | NoMachine | TCP | Remote desktop |
| 7681 | ttyd | HTTP/WS | Web terminal |
| 8080 | Eye Server | HTTP | Screen capture API |
| 2222 | SSH | TCP | SSH access (optional) |

**Custom Port Mapping**:
```bash
# Use different host ports
-p 14000:4000 \
-p 17681:7681 \
-p 18080:8080
```

### Customizing Container

#### Change Virtual Disk Size

```bash
docker run -d \
  -e CUA_DISK_SIZE=32G \
  cua-ubuntu:latest
```

#### Change Desktop Wallpaper

Replace `favourites/19228.jpg` before building:
```bash
cp ~/my-wallpaper.jpg favourites/19228.jpg
docker build -t cua-ubuntu:custom .
```

#### Modify GNOME Settings

Edit `config/user-dconf-settings.ini` before building:
```ini
[org/gnome/desktop/interface]
gtk-theme='Yaru-light'  # Change to light theme
```

---

## Installed Software

### Desktop Applications

| Category | Applications |
|----------|-------------|
| **Browsers** | Brave (default) |
| **Editors** | VS Code, GNOME Text Editor, nano, vim |
| **File Manager** | Nautilus with terminal extension |
| **Office Suite** | LibreOffice (Writer, Calc, Impress, Draw, Math, Base) |
| **Media Player** | VLC, Shotwell (image viewer) |
| **PDF Viewer** | Evince |
| **System Tools** | GNOME System Monitor, Logs, Settings, Terminal |
| **Remote Access** | NoMachine 9.3.7 |

### Command-Line Tools

**File Management**:
- `ranger` - Terminal file manager
- `mc` - Midnight Commander
- `tree` - Directory tree viewer
- `eza` - Modern ls replacement
- `bat` - Cat with syntax highlighting

**Productivity**:
- `tmux` - Terminal multiplexer
- `fzf` - Fuzzy finder
- `jq` - JSON processor
- `aria2` - Download manager
- `duf` - Disk usage analyzer

**Monitoring**:
- `htop` / `top` - Process monitor
- `lsof` - List open files
- `strace` - System call tracer
- `nethogs` - Network monitor

**Development**:
- `git` & `git-lfs` - Version control
- `curl` & `wget` - HTTP clients
- `rsync` - File synchronization
- `ffmpeg` - Media processing

### System Services

**Running Services**:
- `systemd` - Init system (PID 1)
- `dbus` - Message bus
- `NetworkManager` - Network management
- `avahi-daemon` - mDNS/DNS-SD
- `gdm3` - Display manager
- `pulseaudio` - Audio server
- `supervisor` - Process manager
- `ttyd` - Web terminal
- `nxserver` - NoMachine server
- `eye-agent` - Screen capture agent

---

## Development Environments

### Python Development

**Pre-configured Setup**:
- Python 3.14.2 with pip 25.3
- Virtual environment support (`venv`)
- System-wide installation

**Create Virtual Environment**:
```bash
python -m venv ~/myproject/venv
source ~/myproject/venv/bin/activate
pip install numpy pandas torch
```

**VS Code Python Extensions**:
- Python language server (Pylance)
- Python debugger
- Environment manager

### Go Development

**Workspace**: `/usr/local/go-workspace`

**Project Setup**:
```bash
cd /workspace
mkdir myapp && cd myapp
go mod init github.com/user/myapp
```

**Environment Variables**:
```bash
GOROOT=/usr/local/go
GOPATH=/usr/local/go-workspace
```

### Rust Development

**Create New Project**:
```bash
cargo new myapp
cd myapp
cargo build
cargo run
```

**VS Code Integration**:
- Rust Analyzer pre-installed
- Auto-formatting on save
- Inline documentation

### Node.js / TypeScript

**Global Packages**:
- TypeScript compiler (`tsc`)
- TSX runner
- npm 11.7.0

**Create Project**:
```bash
mkdir myapp && cd myapp
npm init -y
npm install --save-dev typescript @types/node
npx tsc --init
```

### Java Development

**JDK**: Oracle Java 25 (latest)

**VS Code Extensions**:
- Java Extension Pack
- Oracle Java Extension

**Compile & Run**:
```bash
javac HelloWorld.java
java HelloWorld
```

### C# / .NET Development

**.NET SDK**: 10.0 (LTS)

**Create Project**:
```bash
dotnet new console -n MyApp
cd MyApp
dotnet run
```

**VS Code Integration**:
- C# DevKit
- .NET Runtime support
- IntelliSense enabled

### C/C++ Development

**Compilers**:
- GCC (default)
- Clang (alternative)

**Build Tools**:
- CMake
- Ninja
- Make

**VS Code Extensions**:
- C++ Tools Extension Pack
- CMake Tools
- Debugger support

**Example CMake Project**:
```bash
mkdir build && cd build
cmake ..
make
```

---

## Services & Daemons

### Systemd Services

#### create-disk.service

**Description**: Creates and mounts virtual data disk

**Configuration**:
- Size: 64GB (configurable via `CUA_DISK_SIZE`)
- Location: `/var/lib/cua/disk.img`
- Mount: `/mnt/data`
- Filesystem: ext4
- Owner: UID 1001

**Features**:
- Fresh disk on every container start
- Auto-mount with fstab entry
- User-owned for data persistence

**Logs**:
```bash
journalctl -u create-disk.service
# OR
cat /var/log/x_start.log
```

#### gpu-setup.service

**Description**: Configures NVIDIA GPU and X11

**Tasks**:
1. Cleans stale locks (`/tmp/.X*-lock`)
2. Detects NVIDIA GPU Bus ID
3. Injects Bus ID into Xorg config
4. Waits for Xorg to start
5. Applies GPU performance settings
6. Starts peripheral services

**GPU Configuration**:
- PowerMizer: Performance mode
- Fan control: Enabled
- VBlank sync: Enabled
- Composition bypass: Disabled

**Logs**:
```bash
cat /var/log/gpu-setup.log
```

#### supervisord.service

**Description**: Manages critical processes

**Managed Processes**:
- `avahi-daemon`: Service discovery
- `ttyd`: Web terminal

**Configuration**: `/etc/supervisor/supervisord.conf`

**Control**:
```bash
supervisorctl status
supervisorctl restart avahi-daemon
supervisorctl tail ttyd
```

### User Services (Systemd User)

#### eye-agent.service

**Description**: Automatic screen capture service

**Configuration**:
- Auto-discovers Eye server
- Captures every 1.5 seconds
- Format: PNG
- Runs as user (UID 1001)

**Server Discovery Order**:
1. `~/.eye/server_url` file
2. Docker gateway (auto-detected)
3. localhost:8080

**Logs**:
```bash
tail -f ~/eye_agent.log
```

**Manual Control**:
```bash
systemctl --user status eye-agent
systemctl --user restart eye-agent
systemctl --user stop eye-agent
```

---

## The Eye Integration

### Overview

The Eye is a screen capture tool integrated into the container for AI training data collection and monitoring.

### Components

1. **Eye Server** (Go binary)
   - Location: `/usr/local/bin/eye-server`
   - Port: 8080
   - Stores latest 100 frames in memory

2. **Eye Agent** (Python CLI)
   - Location: `/usr/local/bin/eye`
   - Auto-starts via systemd user service
   - Captures screen continuously

3. **Eye Daemon** (Bash wrapper)
   - Location: `/usr/local/bin/eye-daemon.sh`
   - Handles auto-discovery and restart logic

### Configuration

**Server Configuration** (`~/.eye/server_url`):
```bash
mkdir -p ~/.eye
echo "http://192.168.1.100:8080" > ~/.eye/server_url
```

**Authentication Token** (`~/.eye/token`):
```bash
echo "my-secret-token" > ~/.eye/token
```

### Usage

**View Latest Screenshot**:
```bash
# In browser
http://<container-ip>:8080/snapshot.png

# With curl
curl http://localhost:8080/snapshot.png -o screenshot.png
```

**Server Health**:
```bash
curl http://localhost:8080/health
```

**Debug Info**:
```bash
curl http://localhost:8080/debug
```

**Dynamic Configuration**:
```bash
curl -X POST http://localhost:8080/admin/config \
  -H "Content-Type: application/json" \
  -d '{"interval": 5.0, "format": "jpeg", "quality": 85}'
```

### Manual Agent Control

**Stop Auto-capture**:
```bash
systemctl --user stop eye-agent
```

**Start Manual Capture**:
```bash
eye agent start \
  --server http://localhost:8080 \
  --interval 2.0 \
  --format jpeg \
  --quality 90 \
  --duration 300
```

**Capture Specific Frames**:
```bash
eye agent start \
  --server http://localhost:8080 \
  --max-frames 100 \
  --no-notify
```

---

## Remote Access Methods

### NoMachine

**Connection Details**:
- **Host**: Container IP or host IP
- **Port**: 4000
- **Protocol**: NX
- **Authentication**: None (disabled)
- **Display**: Physical display :0

**Connect**:
1. Download NoMachine client from https://www.nomachine.com
2. Create new connection:
   - Protocol: NX
   - Host: `<container-ip>`
   - Port: 4000
3. Click "Connect" (no password required)

**Features**:
- Full desktop experience
- Hardware cursor
- Audio streaming (bidirectional)
- Clipboard sharing
- File transfer
- 60 FPS video
- H.264 hardware encoding (with GPU)

**Performance Tips**:
- Use wired connection for best experience
- Enable hardware acceleration in client
- Adjust quality settings based on bandwidth

**Troubleshooting**:
```bash
# Check NoMachine status
/usr/NX/bin/nxserver --status

# Restart NoMachine
/usr/NX/bin/nxserver --restart

# View logs
tail -f /usr/NX/var/log/nxserver.log
```

### Web Terminal (ttyd)

**Access**:
```
http://<container-ip>:7681
```

**Features**:
- Browser-based terminal
- No client installation required
- Full bash shell access
- Works on any device with web browser
- Copy/paste support

**Environment**:
- Display: `:0`
- User: UID 1001 (dynamic username)
- Shell: bash
- Full PATH with all dev tools

**Use Cases**:
- Quick command execution
- Mobile access
- Embedded terminal in web apps
- CI/CD integration

**Security Note**: No authentication by default. Use reverse proxy with auth for production.

### SSH Access (Optional)

**Enable SSH** (requires modification):

Add to Dockerfile before building:
```dockerfile
RUN apt-get update && apt-get install -y openssh-server && \
    mkdir -p /var/run/sshd && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
```

Add SSH service to supervisor:
```bash
# In supervisord.conf
[program:sshd]
command=/usr/sbin/sshd -D
autorestart=true
```

**Connect**:
```bash
# Copy SSH key to container
docker cp ~/.ssh/id_rsa.pub cua-dev:/tmp/
docker exec -it cua-dev bash -c \
  "mkdir -p /home/$(id -un 1001)/.ssh && \
   cat /tmp/id_rsa.pub >> /home/$(id -un 1001)/.ssh/authorized_keys && \
   chown -R 1001:1001 /home/$(id -un 1001)/.ssh && \
   chmod 700 /home/$(id -un 1001)/.ssh && \
   chmod 600 /home/$(id -un 1001)/.ssh/authorized_keys"

# SSH to container
ssh -p 2222 $(docker exec cua-dev id -un 1001)@localhost
```

### X11 Forwarding

**For Remote X11 Applications**:

```bash
# Get container IP
CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cua-dev)

# Allow X11 connections
xhost +local:docker

# Run X11 app from host
docker exec -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  cua-dev firefox
```

---

## Troubleshooting

### Container Won't Start

**Symptom**: Container exits immediately after starting

**Diagnosis**:
```bash
# Check container logs
docker logs cua-dev

# Check if systemd started
docker exec cua-dev systemctl status
```

**Common Causes & Fixes**:

1. **Missing cgroup mount**:
```bash
# Ensure cgroup is mounted
docker run -v /sys/fs/cgroup:/sys/fs/cgroup:rw --cgroupns=host ...
```

2. **Missing privileged mode**:
```bash
# Systemd requires privileged mode
docker run --privileged ...
```

3. **AppArmor/SELinux conflicts**:
```bash
# Disable AppArmor for container (Ubuntu/Debian)
docker run --security-opt apparmor=unconfined ...

# Disable SELinux for container (RHEL/CentOS)
docker run --security-opt label=disable ...
```

### Desktop Not Loading

**Symptom**: NoMachine shows black screen or connection fails

**Diagnosis**:
```bash
# Check if Xorg is running
docker exec cua-dev ps aux | grep Xorg

# Check GDM status
docker exec cua-dev systemctl status gdm

# Check GPU setup logs
docker exec cua-dev cat /var/log/gpu-setup.log
```

**Solutions**:

1. **Wait for startup** (may take 5-10 seconds on first boot)

2. **Check GPU passthrough**:
```bash
# Verify GPU is visible
docker exec cua-dev nvidia-smi

# If GPU not found, ensure --gpus all flag
docker run --gpus all ...
```

3. **Restart display manager**:
```bash
docker exec cua-dev systemctl restart gdm
```

4. **Check Xorg configuration**:
```bash
docker exec cua-dev cat /var/log/Xorg.0.log | grep EE
```

### GPU Not Detected

**Symptom**: nvidia-smi shows "No devices found"

**Diagnosis**:
```bash
# Check from container
docker exec cua-dev nvidia-smi

# Check Docker GPU support
docker run --rm --gpus all nvidia/cuda:12.0-base nvidia-smi
```

**Solutions**:

1. **Verify host GPU**:
```bash
# On host
nvidia-smi
```

2. **Install nvidia-container-toolkit**:
```bash
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

3. **Check Docker runtime**:
```bash
# Check daemon.json
cat /etc/docker/daemon.json

# Should contain:
{
  "runtimes": {
    "nvidia": {
      "path": "nvidia-container-runtime",
      "runtimeArgs": []
    }
  }
}
```

4. **Rebuild container with GPU support**:
```bash
docker stop cua-dev
docker rm cua-dev
docker run --gpus all ...
```

### Eye Agent Not Capturing

**Symptom**: No screenshots at `/snapshot.png` endpoint

**Diagnosis**:
```bash
# Check Eye agent status
docker exec cua-dev systemctl --user status eye-agent

# Check logs
docker exec cua-dev cat /home/$(docker exec cua-dev id -un 1001)/eye_agent.log
```

**Solutions**:

1. **Check server connectivity**:
```bash
docker exec cua-dev curl http://localhost:8080/health
```

2. **Restart Eye agent**:
```bash
docker exec cua-dev systemctl --user restart eye-agent
```

3. **Verify display environment**:
```bash
docker exec cua-dev bash -c 'echo $DISPLAY'  # Should be :0
docker exec cua-dev xdpyinfo -display :0
```

4. **Manual capture test**:
```bash
docker exec cua-dev su - $(docker exec cua-dev id -un 1001) -c \
  "DISPLAY=:0 eye agent start --server http://localhost:8080 --max-frames 5"
```

### High CPU/Memory Usage

**Symptom**: Container consuming excessive resources

**Diagnosis**:
```bash
# Check resource usage
docker stats cua-dev

# Check processes in container
docker exec cua-dev top
```

**Solutions**:

1. **Limit container resources**:
```bash
docker run \
  --cpus="4" \
  --memory="8g" \
  --memory-swap="10g" \
  ...
```

2. **Disable animations** (already done in config):
```bash
# Verify animations are disabled
docker exec cua-dev gsettings get org.gnome.desktop.interface enable-animations
# Should return: false
```

3. **Reduce Eye capture frequency**:
```bash
curl -X POST http://localhost:8080/admin/config \
  -H "Content-Type: application/json" \
  -d '{"interval": 5.0}'
```

4. **Close unused applications**:
```bash
# Via NoMachine or ttyd
pkill Brave
pkill code
```

### Network Issues

**Symptom**: Cannot access container services from host

**Diagnosis**:
```bash
# Check container ports
docker port cua-dev

# Check if services are listening
docker exec cua-dev netstat -tlnp
```

**Solutions**:

1. **Verify port mappings**:
```bash
docker ps -f name=cua-dev --format "{{.Ports}}"
```

2. **Check firewall**:
```bash
# On host
sudo ufw status
sudo iptables -L
```

3. **Test connectivity**:
```bash
# From host
curl http://localhost:8080/health
nc -zv localhost 4000
```

### Disk Space Issues

**Symptom**: Virtual disk full or container out of space

**Diagnosis**:
```bash
# Check disk usage in container
docker exec cua-dev df -h

# Check /mnt/data usage
docker exec cua-dev du -sh /mnt/data/*
```

**Solutions**:

1. **Increase virtual disk size**:
```bash
docker stop cua-dev
docker rm cua-dev

# Run with larger disk
docker run -e CUA_DISK_SIZE=32G ...
```

2. **Clean up workspace**:
```bash
docker exec cua-dev rm -rf /workspace/.cache
docker exec cua-dev rm -rf /tmp/*
```

3. **Prune Docker system** (on host):
```bash
docker system prune -a
```

### Permission Issues

**Symptom**: Cannot write files or execute commands

**Diagnosis**:
```bash
# Check current user
docker exec cua-dev whoami
docker exec cua-dev id

# Check file permissions
docker exec cua-dev ls -la /workspace
```

**Solutions**:

1. **Fix volume permissions**:
```bash
# Get dynamic username
USERNAME=$(docker exec cua-dev id -un 1001)

# Fix workspace ownership
docker exec cua-dev chown -R 1001:1001 /workspace
```

2. **Verify sudo access**:
```bash
docker exec cua-dev sudo -l
# Should show: (ALL) NOPASSWD: ALL
```

---

## Advanced Usage

### Running Multiple Containers

**Different Projects**:
```bash
# Project 1 - Python ML
docker run -d \
  --name cua-ml \
  --hostname ml-workstation \
  --privileged --gpus all \
  -v ~/ml-workspace:/workspace \
  -p 4001:4000 -p 7682:7681 -p 8081:8080 \
  cua-ubuntu:latest

# Project 2 - Web Development
docker run -d \
  --name cua-web \
  --hostname web-workstation \
  --privileged --gpus all \
  -v ~/web-workspace:/workspace \
  -p 4002:4000 -p 7683:7681 -p 8082:8080 \
  cua-ubuntu:latest
```

**Team Development**:
```bash
# Developer 1
docker run -d --name cua-alice -p 4100:4000 ...

# Developer 2
docker run -d --name cua-bob -p 4200:4000 ...
```

### Custom Image Variants

**Minimal Variant** (no desktop):
```dockerfile
FROM cua-ubuntu:latest

# Remove desktop components
RUN apt-get purge -y gnome-shell gdm3 gnome-* && \
    apt-get autoremove -y && \
    systemctl disable gdm && \
    rm -rf /usr/share/backgrounds
```

**Data Science Variant**:
```dockerfile
FROM cua-ubuntu:latest

# Install additional tools
RUN pip install --no-cache-dir \
    jupyter \
    numpy \
    pandas \
    scikit-learn \
    tensorflow \
    pytorch \
    matplotlib \
    seaborn

# Expose Jupyter port
EXPOSE 8888
```

**Game Development Variant**:
```dockerfile
FROM cua-ubuntu:latest

# Install game engines
RUN apt-get update && apt-get install -y \
    godot \
    blender && \
    rm -rf /var/lib/apt/lists/*

# Install Unity Hub (example)
RUN wget -qO- https://public-cdn.cloud.unity3d.com/hub/prod/UnityHub.AppImage \
    -O /usr/local/bin/unity-hub && \
    chmod +x /usr/local/bin/unity-hub
```

### CI/CD Integration

**GitLab CI Example**:
```yaml
# .gitlab-ci.yml
build:
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t cua-ubuntu:$CI_COMMIT_SHA .
    - docker push registry.example.com/cua-ubuntu:$CI_COMMIT_SHA

test:
  image: cua-ubuntu:$CI_COMMIT_SHA
  script:
    - python -m pytest tests/
    - npm test
    - go test ./...
```

**GitHub Actions Example**:
```yaml
# .github/workflows/build.yml
name: Build CUA Ubuntu

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Build image
        run: |
          docker build -t cua-ubuntu:latest .
      
      - name: Test container
        run: |
          docker run -d --name test-cua cua-ubuntu:latest
          sleep 60
          docker exec test-cua systemctl is-active gdm
```

### Automation Scripts

**Backup Container State**:
```bash
#!/bin/bash
# backup-cua.sh

CONTAINER_NAME="cua-dev"
BACKUP_DIR="~/cua-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Export container filesystem
docker export $CONTAINER_NAME | gzip > "$BACKUP_DIR/cua_$TIMESTAMP.tar.gz"

# Backup volumes
docker run --rm \
  -v $(docker volume inspect cua-home -f '{{.Mountpoint}}'):/source:ro \
  -v "$BACKUP_DIR":/backup \
  alpine tar czf /backup/cua-home_$TIMESTAMP.tar.gz -C /source .

echo "Backup completed: $BACKUP_DIR"
```

**Health Monitoring**:
```bash
#!/bin/bash
# monitor-cua.sh

CONTAINER_NAME="cua-dev"

while true; do
  # Check if container is running
  if ! docker ps -q -f name=$CONTAINER_NAME | grep -q .; then
    echo "[$(date)] Container is down, restarting..."
    docker start $CONTAINER_NAME
  fi
  
  # Check if desktop is responsive
  if ! docker exec $CONTAINER_NAME pgrep gnome-shell >/dev/null; then
    echo "[$(date)] GNOME Shell crashed, restarting GDM..."
    docker exec $CONTAINER_NAME systemctl restart gdm
  fi
  
  # Check Eye agent
  if ! docker exec $CONTAINER_NAME systemctl --user is-active eye-agent >/dev/null; then
    echo "[$(date)] Eye agent stopped, restarting..."
    docker exec $CONTAINER_NAME systemctl --user restart eye-agent
  fi
  
  sleep 60
done
```

**Automated Deployment**:
```bash
#!/bin/bash
# deploy-cua.sh

set -e

IMAGE_NAME="cua-ubuntu:latest"
CONTAINER_NAME="cua-dev"

echo "Building image..."
docker build -t $IMAGE_NAME .

echo "Stopping old container..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

echo "Starting new container..."
docker run -d \
  --name $CONTAINER_NAME \
  --hostname cua-workstation \
  --privileged --gpus all \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  --cgroupns=host \
  -v ~/workspace:/workspace \
  -v cua-home:/home/$(docker run --rm $IMAGE_NAME id -un 1001) \
  -v cua-data:/mnt/data \
  -p 4000:4000 -p 7681:7681 -p 8080:8080 \
  --restart unless-stopped \
  $IMAGE_NAME

echo "Waiting for container to be ready..."
sleep 60

echo "Checking health..."
docker exec $CONTAINER_NAME systemctl is-active gdm
docker exec $CONTAINER_NAME curl -s http://localhost:8080/health

echo "Deployment complete!"
echo "NoMachine: localhost:4000"
echo "Web Terminal: http://localhost:7681"
echo "Eye Server: http://localhost:8080"
```

### Development Workflows

**AI Training Data Collection**:
```bash
# 1. Start container with data collection
docker run -d --name cua-training \
  --gpus all --privileged \
  -v ~/training-data:/workspace/data \
  -p 8080:8080 \
  cua-ubuntu:latest

# 2. Run agent tasks and collect screenshots
# (Eye agent captures automatically)

# 3. Export captured data
docker exec cua-training curl http://localhost:8080/debug

# 4. Stop and archive
docker stop cua-training
docker commit cua-training cua-training-snapshot:$(date +%Y%m%d)
```

**Multi-Language Testing**:
```bash
#!/bin/bash
# test-all-languages.sh

CONTAINER_NAME="cua-dev"

echo "Testing Python..."
docker exec $CONTAINER_NAME python --version
docker exec $CONTAINER_NAME python -c "print('✓ Python works')"

echo "Testing Go..."
docker exec $CONTAINER_NAME go version
docker exec $CONTAINER_NAME go run /tmp/hello.go

echo "Testing Rust..."
docker exec $CONTAINER_NAME rustc --version
docker exec $CONTAINER_NAME bash -c "echo 'fn main(){println!(\"✓ Rust works\")}' | rustc - && ./main"

echo "Testing Node.js..."
docker exec $CONTAINER_NAME node --version
docker exec $CONTAINER_NAME node -e "console.log('✓ Node.js works')"

echo "All language tests passed!"
```

---

## Security Considerations

### Current Security Posture

**⚠️ WARNING**: This container is designed for **development environments only**. Additional hardening is recommended for production use.

**Security Characteristics**:
- ✅ Runs as non-root user (UID 1001) inside container
- ✅ Isolated filesystem and network namespace
- ✅ Uses systemd for proper service management
- ⚠️ Requires `--privileged` mode OR specific capabilities for full systemd functionality
- ❌ No authentication on NoMachine (by default)
- ❌ No authentication on ttyd (by default)
- ❌ Passwordless sudo for user (for development convenience)
- ⚠️ GPU device access (if using `--gpus all`)

**Note**: While `--privileged` mode is convenient for development, systemd can run with specific capabilities instead. See the security recommendations below for production-ready alternatives.

### Recommendations for Production Use

#### 1. Enable Authentication

**NoMachine**:
```bash
# Edit /usr/NX/etc/server.cfg
EnablePasswordAuthentication 1

# Set password
docker exec -it cua-dev /usr/NX/bin/nxpasswd $(docker exec cua-dev id -un 1001)
```

**ttyd**:
```bash
# Modify supervisord config to add basic auth
# /etc/supervisor/conf.d/ttyd.conf
[program:ttyd]
command=/usr/local/bin/ttyd -p 7681 -c user:password bash
```

**Eye Server**:
```bash
# Set authentication token
docker run -e EYE_AUTH_TOKEN=your-secret-token ...
```

#### 2. Network Isolation

**Use Docker Networks**:
```bash
# Create isolated network
docker network create cua-network

# Run container in isolated network
docker run --network cua-network ...

# Only expose necessary ports
docker run -p 127.0.0.1:4000:4000 ...  # Localhost only
```

**Use Reverse Proxy**:
```nginx
# nginx.conf
server {
    listen 443 ssl;
    server_name cua.example.com;
    
    ssl_certificate /etc/ssl/certs/cert.pem;
    ssl_certificate_key /etc/ssl/private/key.pem;
    
    location / {
        proxy_pass http://localhost:4000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        
        # Basic auth
        auth_basic "CUA Access";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}
```

#### 3. Resource Limits

**Enforce Strict Limits**:
```bash
docker run \
  --cpus="4" \
  --memory="8g" \
  --memory-swap="8g" \
  --pids-limit=500 \
  --ulimit nofile=1024:2048 \
  ...
```

**Docker Compose**:
```yaml
services:
  cua-ubuntu:
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G
        reservations:
          cpus: '2'
          memory: 4G
```

#### 4. Run Without Privileged Mode (Production)

**Use Specific Capabilities**:
```bash
docker run -d \
  --name cua-dev-prod \
  --cap-add=SYS_ADMIN \
  --cap-add=SYS_RESOURCE \
  --cap-add=NET_ADMIN \
  --security-opt apparmor=unconfined \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  --cgroupns=host \
  --gpus all \
  -p 4000:4000 \
  -p 7681:7681 \
  -p 8080:8080 \
  cua-ubuntu:latest
```

This approach gives systemd the capabilities it needs without full privileged access:
- `SYS_ADMIN`: For mount operations and cgroup management
- `SYS_RESOURCE`: For resource limit modifications
- `NET_ADMIN`: For network configuration

**Docker Compose (Production)**:
```yaml
services:
  cua-ubuntu:
    image: cua-ubuntu:latest
    cap_add:
      - SYS_ADMIN
      - SYS_RESOURCE
      - NET_ADMIN
    security_opt:
      - apparmor=unconfined
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:rw
    cgroupns: host
```

#### 5. Read-Only Filesystem

**Mount Sensitive Paths as Read-Only**:
```bash
docker run \
  -v ~/.ssh:/home/cua-$(docker run --rm cua-ubuntu id -un 1001)/.ssh:ro \
  -v ~/.gitconfig:/home/cua-$(docker run --rm cua-ubuntu id -un 1001)/.gitconfig:ro \
  ...
```

#### 6. Secrets Management

**Use Docker Secrets**:
```bash
# Create secret
echo "my-secret-token" | docker secret create eye_token -

# Use in container
docker service create \
  --secret eye_token \
  --env EYE_AUTH_TOKEN_FILE=/run/secrets/eye_token \
  cua-ubuntu:latest
```

**Use Environment File**:
```bash
# .env file
EYE_AUTH_TOKEN=secret-token
GITHUB_TOKEN=ghp_xxxxx

# Run with env file
docker run --env-file .env ...
```

#### 7. Regular Updates

**Keep Base Image Updated**:
```bash
# Rebuild regularly
docker build --no-cache --pull -t cua-ubuntu:latest .

# Update running container packages
docker exec cua-dev apt-get update && \
docker exec cua-dev apt-get upgrade -y
```

**Security Scanning**:
```bash
# Scan image for vulnerabilities
docker scan cua-ubuntu:latest

# Or use Trivy
trivy image cua-ubuntu:latest
```

#### 8. Audit Logging

**Enable Docker Logging**:
```bash
docker run \
  --log-driver json-file \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  ...
```

**Monitor Container Activity**:
```bash
# Watch logs in real-time
docker logs -f cua-dev

# Audit exec commands
docker events --filter 'event=exec_start'
```

### Best Practices

1. **Use specific capabilities instead of --privileged** - For production, run with required capabilities only:
   ```bash
   docker run \
     --cap-add=SYS_ADMIN \
     --cap-add=SYS_RESOURCE \
     --cap-add=NET_ADMIN \
     -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
     --cgroupns=host \
     cua-ubuntu:latest
   ```
   This provides systemd with necessary permissions without full privileged mode.

2. **Use secrets management** - Never hardcode credentials
3. **Enable network encryption** - Use TLS/SSL for all remote access
4. **Regular backups** - Backup volumes and important data
5. **Monitor resource usage** - Set up alerts for anomalies
6. **Use AppArmor/SELinux** - Enable security profiles when possible
7. **Scan for vulnerabilities** - Regular security audits
8. **Principle of least privilege** - Only grant necessary permissions
9. **Keep logs** - Maintain audit trail
10. **Regular updates** - Keep base image and packages updated

---

### Reporting Issues

**Bug Reports** should include:
- Docker version (`docker --version`)
- Host OS and kernel version
- GPU model (if applicable)
- Container logs (`docker logs cua-dev`)
- Steps to reproduce
- Expected vs actual behavior

**Feature Requests** should include:
- Use case description
- Proposed implementation
- Impact on existing functionality

### Project Structure

```
cua-ubuntu/
├── ubuntu-code-v0.1.dockerfile          # Main Dockerfile
├── config/                              # Configuration files
│   ├── systemd/                         # Systemd service files
│   │   ├── create-disk.service
│   │   ├── gpu-setup.service
│   │   ├── eye-agent.service
│   │   └── supervisord.service
│   ├── nvidia.env                       # NVIDIA environment variables
│   ├── 20-nvidia-isolated.conf          # Xorg GPU configuration
│   ├── logind.conf                      # systemd-logind config
│   ├── supervisord.conf                 # Supervisor daemon config
│   └── user-dconf-settings.ini          # GNOME desktop settings
├── scripts/                             # Shell scripts
│   ├── create-disk.sh                   # Virtual disk creation
│   ├── gpu-setup.sh                     # GPU initialization
│   └── eye-daemon.sh                    # Eye agent wrapper
├── favourites/                          # Wallpapers and media
│   └── 19228.jpg                        # Default wallpaper
├── README.md                            # This file
└── cua-rl-environment-ubuntu-24.04.md   # Documentation
```

---

## FAQ

### General Questions

**Q: Why does the container need `--privileged` mode?**  
A: For development convenience, `--privileged` gives systemd full access to manage services, cgroups, and devices. However, for production use, you can run without `--privileged` by using specific capabilities (`--cap-add=SYS_ADMIN`, `--cap-add=SYS_RESOURCE`, `--cap-add=NET_ADMIN`) along with cgroup mounts. See the Security Considerations section for production-ready configurations.

**Q: Can I run this without a GPU?**  
A: Yes, but remove the `--gpus all` flag and the container will fall back to software rendering. Desktop experience may be slower.

**Q: What's the dynamic username feature?**  
A: Each container generates a unique username (e.g., `cua-a1b2c3d4`) to allow multiple containers to run simultaneously without conflicts.

**Q: How much disk space does it need?**  
A: The image is ~12 GB. Add 8 GB for the virtual disk, plus your workspace data.

**Q: Can I use this in production?**  
A: Not recommended without significant security hardening. It's designed for development environments.

### Performance Questions

**Q: Why is startup slow?**  
A: First boot takes 60-90 seconds to initialize systemd, GPU, and desktop services. Subsequent starts are faster (30-45s).

**Q: How can I improve NoMachine performance?**  
A: Use wired connection, enable GPU acceleration, lower quality settings if needed, or reduce frame rate.

**Q: Does it support multiple monitors?**  
A: Currently configured for single 1920x1080 virtual display. Multi-monitor requires Xorg configuration changes.

### Compatibility Questions

**Q: Does it work on Windows/macOS?**  
A: Yes with Docker Desktop, but GPU passthrough may not work. Best results on Linux hosts.

**Q: Can I use AMD GPUs?**  
A: Not currently configured for AMD. Would need ROCm drivers and different configuration.

**Q: What about Apple Silicon (M1/M2)?**  
A: Not supported. This is an x86_64 image only.

### Customization Questions

**Q: How do I change the desktop wallpaper?**  
A: Replace `favourites/19228.jpg` before building, or change it via GNOME Settings in the running container.

**Q: Can I pre-install additional software?**  
A: Yes, add `RUN apt-get install -y <package>` commands to the Dockerfile before building.

**Q: How do I persist VS Code extensions?**  
A: They're already persisted in `/usr/share/code-extensions` which is linked to user home.

**Q: Can I use a different desktop environment?**  
A: Yes, but requires significant Dockerfile modifications. GNOME is deeply integrated.

---

## License

This project is licensed under the GPL-3.0 License - see the LICENSE file for details.

---

## Support

- **Issues**: [GitHub Issues](https://github.com/nullvoider07/CUA-RL-Environment-Ubuntu-24.04/issues)
- **Discussions**: [GitHub Discussions](https://github.com/nullvoider07/CUA-RL-Environment-Ubuntu-24.04/discussions)
- **Documentation**: This README
---
 
**Last Updated:** January 11, 2026  
**Developer:** Kartik (NullVoider)

---
## About This Project

The CUA Ubuntu 24.04 GPU-accelerated Container was built from scratch through iterative testing and refinement. Every configuration, every feature, and every line of code was crafted to create production-ready RL Environment for Computer Use Agents development process.

If you find this project useful, encounter bugs, or have feature requests, feel free to reach out directly via [X (formerly Twitter)](https://x.com/nullvoider07).

**CUA Ubuntu 24.04** - AI-ready development environment in a container 🚀