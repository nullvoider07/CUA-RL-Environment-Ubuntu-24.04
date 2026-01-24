# xai/cua-ubuntu-24.04-gpu — AI Agent GUI Control Base
FROM ubuntu:24.04

# === Force EGL (early for all layers) ===
ENV EGL_PLATFORM=x11

# === NVIDIA Settings (early for all layers) ===
ENV NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility \
    __GLX_VENDOR_LIBRARY_NAME=mesa \
    __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/10_mesa.json

# NVIDIA Environment Variables
COPY config/nvidia.env /tmp/nvidia.env
RUN cat /tmp/nvidia.env >> /etc/environment && rm /tmp/nvidia.env

# === 1. Initial Setup ===
RUN \
    # Create missing groups if they don't exist yet
    getent group video >/dev/null || groupadd -r video && \
    getent group render >/dev/null || groupadd -r render && \
    getent group sudo >/dev/null || groupadd -r sudo && \
    getent group input >/dev/null || groupadd -r input && \
    \
    # Create base user "cua" (will be renamed dynamically below)
    useradd -m -u 1001 -s /bin/bash -G video,render,sudo,input cua && \
    passwd -d cua && \
    \
    # Create dirs
    mkdir -p /workspace /tmp /run/dbus /run/user/1001 && \
    chown cua:cua /workspace /tmp /run/user/1001 && \
    chmod 700 /run/user/1001

# === 2. Core Packages (single RUN for caching) ===
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core
    zsh curl wget git git-lfs ca-certificates sudo nano \
    aria2 tree lsof strace gnupg apt-transport-https \
    software-properties-common bash-completion man-db \
    mc ranger fzf bat eza duf jq \
    # Ubuntu Desktop Base
    ubuntu-desktop ubuntu-session \
    # GNOME (X11)
    gdm3 gnome-shell gnome-remote-desktop mutter gpg \
    gnome-session-bin gsettings-desktop-schemas gnome-control-center \
    gnome-settings-daemon gnome-terminal gnome-backgrounds gnome-calendar \
    gnome-system-monitor gnome-shell-extensions gnome-text-editor \
    # X11 Utilities
    x11-utils x11-xserver-utils xdg-utils \
    # Window Management
    xdotool wmctrl psmisc \
    # Nautilus File Manager
    yaru-theme-gnome-shell yaru-theme-gtk yaru-theme-icon \
    nautilus nautilus-extension-gnome-terminal \
    # Image handling
    shotwell eog \
    # PDF Viewer + Logs Viewer
    evince gnome-logs \
    # Xorg + fallbacks
    xorg xserver-xorg-core xserver-xorg-input-libinput xauth \
    # DBus/Polkit/Supervisor
    dbus-user-session dbus dbus-x11 policykit-1 supervisor \
    # Audio/Icons/Fonts
    pulseaudio pulseaudio-utils \
    adwaita-icon-theme fontconfig locales \
    fonts-ubuntu fonts-noto-core fonts-noto-color-emoji \
    # Automation/Monitoring/Utils/Debug
    rsync tmux procps iproute2 net-tools util-linux \
    # NVIDIA Drivers (for GPU passthrough)
    libnvidia-egl-wayland1 mesa-utils nvidia-settings \
    # Misc
    logrotate openssl network-manager \
    # Video/Graphics
    ffmpeg libx11-6 libxext6 libxrender1 libxrandr2 \
    libxtst6 libxcb1 libxcomposite1 libxdamage1 \
    # Clean up apt cache and lists
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && fc-cache -f -v \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/*

# === 2.1. NVIDIA Container Toolkit ===
RUN curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
    && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
       sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
       tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends nvidia-container-toolkit \
    && rm -rf /var/lib/apt/lists/*

# === 3. Programming Languages Installation and Setup ===
# === Install Python 3.14.2 + pip 25.3 ===
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential zlib1g-dev libncurses5-dev libgdbm-dev \
        libnss3-dev libssl-dev libreadline-dev libffi-dev \
        libsqlite3-dev libbz2-dev liblzma-dev uuid-dev curl \
    && curl -L https://www.python.org/ftp/python/3.14.2/Python-3.14.2.tgz | tar xz \
    && cd Python-3.14.2 \
    && ./configure --enable-optimizations --with-ensurepip=install \
    && make -j$(nproc) \
    && make altinstall \
    && cd .. && rm -rf Python-3.14.2 \
    #&& apt-get purge -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev \
        #libnss3-dev libssl-dev libreadline-dev libffi-dev \
        #libsqlite3-dev libbz2-dev liblzma-dev uuid-dev \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip to exactly 25.3
RUN python3.14 -m pip install --upgrade pip==25.3

# Create symlinks so `python` and `pip` point to 3.14.2
RUN update-alternatives --install /usr/bin/python python /usr/local/bin/python3.14 100 \
    && update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip3.14 100

# Ensure venv is available (standard for AI/coding workflows)
RUN python3.14 -m ensurepip --upgrade

# === Install Rust (via rustup) ===
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

# Install Rust (stable)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --default-toolchain stable \
    && . "$CARGO_HOME/env" \
    && rustup default stable \
    && chown -R root:1001 $RUSTUP_HOME $CARGO_HOME \
    && chmod -R 775 $RUSTUP_HOME $CARGO_HOME \
    && rustup --version && cargo --version && rustc --version

# === C / C++ Development Tools ===
RUN apt-get update && apt-get install -y --no-install-recommends \
    clang \
    lldb \
    gdb \
    cmake \
    ninja-build \
    valgrind \
    cppcheck \
    && update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 \
    && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 100 \
    && update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 200 \
    && update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 200 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# === C# / .NET 10 SDK (LTS) ===
RUN wget -q https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb \
    && dpkg -i /tmp/packages-microsoft-prod.deb \
    && rm /tmp/packages-microsoft-prod.deb \
    && apt-get update && apt-get install -y --no-install-recommends \
    dotnet-sdk-10.0 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set .NET environment variables
ENV \
    DOTNET_NOLOGO=1 \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    PATH="$PATH:/home/cua/.dotnet/tools"

# === Java (LTS) ===
RUN wget -q https://download.oracle.com/java/25/latest/jdk-25_linux-x64_bin.tar.gz -O /tmp/jdk.tar.gz \
    && mkdir -p /usr/lib/jvm \
    && tar -xzf /tmp/jdk.tar.gz -C /usr/lib/jvm \
    && mv /usr/lib/jvm/jdk-25* /usr/lib/jvm/jdk-25 \
    && rm /tmp/jdk.tar.gz \
    && update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk-25/bin/java 100 \
    && update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk-25/bin/javac 100

# === Scala (3.7.4) ===
RUN curl -fL https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz | gzip -d > /usr/local/bin/cs && \
    chmod +x /usr/local/bin/cs && \
    /usr/local/bin/cs install --dir /usr/local/bin scala:3.7.4 scalac:3.7.4 && \
    chown -R root:1001 /usr/local/bin/scala /usr/local/bin/scalac && \
    chmod -R 775 /usr/local/bin/scala /usr/local/bin/scalac && \
    /usr/local/bin/scala -version

# Configure Scala Environment
ENV SCALA_HOME=/usr/local/scala \
    PATH=/usr/local/scala/bin:$PATH

# === Go (Golang) ===
RUN wget -q https://go.dev/dl/go1.25.5.linux-amd64.tar.gz -O /tmp/go.tar.gz \
    && rm -rf /usr/local/go \
    && tar -C /usr/local -xzf /tmp/go.tar.gz \
    && rm /tmp/go.tar.gz

# Configure Go Environment (System-wide & User)
ENV GOROOT=/usr/local/go \
    GOPATH=/usr/local/go-workspace \
    PATH=/usr/local/go/bin:/usr/local/go-workspace/bin:$PATH

# Create User Workspace & Fix Permissions
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" "$GOPATH/pkg" \
    && chown -R 1001:1001 "$GOPATH" \
    && chmod -R 755 "$GOPATH"

# === Node.js & TypeScript ===
RUN wget -q https://nodejs.org/dist/v25.2.1/node-v25.2.1-linux-x64.tar.xz -O /tmp/node.tar.xz \
    && tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 \
    && rm /tmp/node.tar.xz

# Configure NPM Global Install Location (Root)
ENV NPM_CONFIG_PREFIX=/usr/local/npm-global \
    PATH=/usr/local/npm-global/bin:$PATH

# Create NPM Global Dir & Fix Permissions
RUN mkdir -p $NPM_CONFIG_PREFIX \
    && npm install -g --no-audit --no-fund npm@11.7.0 typescript@latest tsx@latest \
    && chown -R 1001:1001 $NPM_CONFIG_PREFIX \
    && chmod -R 755 $NPM_CONFIG_PREFIX

# === Kotlin ===
RUN wget -q https://github.com/JetBrains/kotlin/releases/download/v2.3.0/kotlin-compiler-2.3.0.zip -O /tmp/kotlin.zip \
    && unzip -q /tmp/kotlin.zip -d /usr/local \
    && rm /tmp/kotlin.zip

# Configure Kotlin Environment
ENV KOTLIN_HOME=/usr/local/kotlinc \
    PATH=/usr/local/kotlinc/bin:$PATH

# === 4. Pre-bake GNOME settings into dconf database ===
COPY config/user-dconf-settings.ini /tmp/dconf-db/user-dconf-settings.ini
RUN \
    # Install dconf-cli
    apt-get update && apt-get install -y --no-install-recommends dconf-cli && \
    \
    sed -i "s/experimental-features=\[\]/experimental-features=@as \[\]/g" /tmp/dconf-db/user-dconf-settings.ini && \
    sed -i "s/enabled-extensions=.*/enabled-extensions=@as \[\]/g" /tmp/dconf-db/user-dconf-settings.ini && \
    \
    # === Compile settings ===
    # 1. Create dir (owned by root initially)
    mkdir -p /home/cua/.config/dconf && \
    # 2. Compile (Now safe because files are fixed)
    dconf compile /home/cua/.config/dconf/user /tmp/dconf-db/ && \
    # 3. Fix ownership for the user
    chown -R 1001:1001 /home/cua/.config/dconf && \
    \
    # === GNOME Config Files (Mutter) ===
    # Force Mutter X11 + disable experimental features (Config file backup)
    mkdir -p /home/cua/.config && \
    echo "[org.gnome.mutter]\nexperimental-features=[]" > /home/cua/.config/mutter.conf && \
    chown -R 1001:1001 /home/cua/.config && \
    \
    # Mask slow/unneeded services
    systemctl mask tracker-miner-fs-3.service tracker-extract-3.service \
                   gnome-initial-setup.service \
                   gnome-shell-extensions.service NetworkManager-wait-online.service && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/dconf-db

# === 5. SCALE-SAFE: Dynamic username per container ===
RUN UNIQUE_SUFFIX="$(head /dev/urandom | tr -dc a-z0-9 | head -c 8)" && \
    UNIQUE_USER="cua-${CONTAINER_ID:-$UNIQUE_SUFFIX}" && \
    echo "Changing username from cua → $UNIQUE_USER (UID 1001)" && \
    usermod -l "$UNIQUE_USER" cua && \
    groupmod -n "$UNIQUE_USER" cua 2>/dev/null || true && \
    usermod -d "/home/$UNIQUE_USER" -m "$UNIQUE_USER" && \
    sed -i "s/AutomaticLogin = cua/AutomaticLogin = $UNIQUE_USER/" /etc/gdm3/custom.conf && \
    echo "Final scale-safe username: $UNIQUE_USER"

# Configure User Environment Variables (in .bashrc.d)
RUN USER_NAME=$(id -un 1001) && \
    USER_HOME=$(eval echo ~$USER_NAME) && \
    mkdir -p "$USER_HOME/.bashrc.d" && \
    { \
        echo 'export RUSTUP_HOME=/usr/local/rustup'; \
        echo 'export CARGO_HOME=/usr/local/cargo'; \
        echo 'export GOROOT=/usr/local/go'; \
        echo 'export GOPATH=/usr/local/go-workspace'; \
        echo 'export JAVA_HOME=/usr/lib/jvm/jdk-25'; \
        echo 'export KOTLIN_HOME=/usr/local/kotlinc'; \
        echo 'export SCALA_HOME=/usr/local/scala'; \
        echo 'export PATH=/usr/local/cargo/bin:/usr/local/go/bin:/usr/local/go-workspace/bin:/usr/local/kotlinc/bin:/usr/local/scala/bin:/usr/local/bin:/usr/local/npm-global/bin:$JAVA_HOME/bin:$PATH'; \
    } > "$USER_HOME/.bashrc.d/prog-langs.sh" && \
    chmod 644 "$USER_HOME/.bashrc.d/prog-langs.sh" && \
    chown -R 1001:1001 "$USER_HOME/.bashrc.d" && \
    # Source it in .bashrc
    echo 'for f in ~/.bashrc.d/*.sh; do [ -r "$f" ] && source "$f"; done' >> "$USER_HOME/.bashrc" && \
    chown 1001:1001 "$USER_HOME/.bashrc" && \
    # Also source it in .zshrc
    echo 'for f in ~/.bashrc.d/*.sh; do [ -r "$f" ] && source "$f"; done' >> "$USER_HOME/.zshrc" && \
    chown 1001:1001 "$USER_HOME/.zshrc" && \
    { \
        echo 'if [ -d ~/.bashrc.d ]; then'; \
        echo '  for f in ~/.bashrc.d/*.sh; do'; \
        echo '    [ -r "$f" ] && . "$f"'; \
        echo '  done'; \
        echo 'fi'; \
    } >> "$USER_HOME/.profile" && \
    chown 1001:1001 "$USER_HOME/.profile" && \
    { \
        echo 'if [ -d ~/.bashrc.d ]; then'; \
        echo '  for f in ~/.bashrc.d/*.sh; do'; \
        echo '    [ -r "$f" ] && . "$f"'; \
        echo '  done'; \
        echo 'fi'; \
    } >> "$USER_HOME/.zprofile" && \
    chown 1001:1001 "$USER_HOME/.zprofile"

# === 6. GDM3 AUTO-LOGIN ===
RUN \
    mkdir -p /etc/gdm3 && \
    { \
        echo "[daemon]"; \
        echo "WaylandEnable=false"; \
        echo "AutomaticLoginEnable=true"; \
        echo "AutomaticLogin=$(id -un 1001)"; \
        echo "AutomaticLoginDelay=0"; \
    } > /etc/gdm3/custom.conf

# === 7. Logrotate Config ===
RUN echo "/var/log/*.log {\n\
      daily\n\
      rotate 7\n\
      compress\n\
      missingok\n\
      notifempty\n\
      copytruncate\n\
    }" > /etc/logrotate.d/docker-logs

# NVIDIA Xorg Config
COPY config/20-nvidia-isolated.conf /etc/X11/xorg.conf.d/20-nvidia-isolated.conf

# === 8. Static Configs (after packages) ===
# Polkit: Allow all
RUN mkdir -p /etc/polkit-1/rules.d && \
    echo 'polkit.addRule(function(action, subject) { return polkit.Result.YES; });' > /etc/polkit-1/rules.d/99-allow-all.rules && \
    chmod 644 /etc/polkit-1/rules.d/99-allow-all.rules

# Xwrapper: Anybody
RUN echo "allowed_users = anybody" > /etc/X11/Xwrapper.config && \
    echo "needs_root_rights = no" >> /etc/X11/Xwrapper.config

# Sudoers
RUN echo "cua ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/cua && \
    chmod 0440 /etc/sudoers.d/cua

# Supervisor Config
COPY config/supervisord.conf /etc/supervisor/supervisord.conf

# === 9. Tools/Applications ===

# === Web Terminal ===
RUN curl -fsSL https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 -o /usr/local/bin/ttyd && \
    chmod +x /usr/local/bin/ttyd

# === PowerShell ===
RUN wget -qO- https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O /tmp/ms.deb && \
    dpkg -i /tmp/ms.deb && rm /tmp/ms.deb && \
    apt-get update && apt-get install -y powershell && \
    rm -rf /var/lib/apt/lists/*

# === Brave ===
RUN curl -fsS https://dl.brave.com/install.sh | sh

# === VS Code ===
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg \
    && install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg \
    && echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list \
    && rm packages.microsoft.gpg \
    && apt-get update && apt-get install -y code \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Configure VS Code Extensions Location (System-wide)
RUN mkdir -p /usr/share/code-extensions \
    && chown -R 1001:1001 /usr/share/code-extensions \
    && chmod -R 755 /usr/share/code-extensions

# VS Code Extensions (Pre-install as user, dynamic post-rename)
RUN USER_NAME=$(id -un 1001) && \
    su - $USER_NAME -c " \
        code --extensions-dir /usr/share/code-extensions --user-data-dir /tmp/vscode-user-data --install-extension ms-vscode.cpptools-extension-pack --force && \
        code --extensions-dir /usr/share/code-extensions --user-data-dir /tmp/vscode-user-data --install-extension ms-azuretools.vscode-docker --force && \
        code --extensions-dir /usr/share/code-extensions --user-data-dir /tmp/vscode-user-data --install-extension vscjava.vscode-java-pack --force && \
        code --extensions-dir /usr/share/code-extensions --user-data-dir /tmp/vscode-user-data --install-extension Oracle.oracle-java --force && \
        code --extensions-dir /usr/share/code-extensions --user-data-dir /tmp/vscode-user-data --install-extension ms-dotnettools.vscode-dotnet-runtime --force && \
        code --extensions-dir /usr/share/code-extensions --user-data-dir /tmp/vscode-user-data --install-extension ms-dotnettools.csharp --force && \
        code --extensions-dir /usr/share/code-extensions --user-data-dir /tmp/vscode-user-data --install-extension ms-dotnettools.csdevkit --force && \
        code --extensions-dir /usr/share/code-extensions --user-data-dir /tmp/vscode-user-data --install-extension GitLab.gitlab-workflow --force && \
        code --extensions-dir /usr/share/code-extensions --user-data-dir /tmp/vscode-user-data --install-extension eamodio.gitlens --force && \
        code --extensions-dir /usr/share/code-extensions --user-data-dir /tmp/vscode-user-data --install-extension golang.go --force && \
        code --extensions-dir /usr/share/code-extensions --user-data-dir /tmp/vscode-user-data --install-extension ms-python.python --force && \
        code --extensions-dir /usr/share/code-extensions --user-data-dir /tmp/vscode-user-data --install-extension ms-python.vscode-pylance --force && \
        code --extensions-dir /usr/share/code-extensions --user-data-dir /tmp/vscode-user-data --install-extension ms-python.debugpy --force && \
        code --extensions-dir /usr/share/code-extensions --user-data-dir /tmp/vscode-user-data --install-extension donjayamanne.python-environment-manager --force && \
        code --extensions-dir /usr/share/code-extensions --user-data-dir /tmp/vscode-user-data --install-extension rust-lang.rust-analyzer --force && \
        code --extensions-dir /usr/share/code-extensions --user-data-dir /tmp/vscode-user-data --install-extension scala-lang.scala --force \
    " && \
    rm -rf /tmp/vscode-user-data  # Cleanup temp dir

# Fix Permissions (system-wide)
RUN chown -R 1001:1001 /usr/share/code-extensions \
    && chmod -R 755 /usr/share/code-extensions

# Configure VS Code Extensions Location (User, dynamic)
RUN USER_NAME=$(id -un 1001) && \
    USER_HOME="/home/${USER_NAME}" && \
    mkdir -p "${USER_HOME}/.vscode" && \
    rm -rf "${USER_HOME}/.vscode/extensions" && \
    ln -sf /usr/share/code-extensions "${USER_HOME}/.vscode/extensions" && \
    chown -R 1001:1001 "${USER_HOME}/.vscode" && \
    echo "VS Code extensions symlink created: ${USER_HOME}/.vscode/extensions -> /usr/share/code-extensions"

# Verify VS Code Extensions Symlink (User, dynamic)
RUN USER_NAME=$(id -un 1001) && \
    test -L "/home/${USER_NAME}/.vscode/extensions" && \
    test "$(readlink "/home/${USER_NAME}/.vscode/extensions")" = "/usr/share/code-extensions" && \
    echo "SUCCESS: VS Code extensions symlink verified" || \
    (echo "ERROR: VS Code extensions symlink missing or incorrect" && exit 1)

# === Git ===
RUN add-apt-repository ppa:git-core/ppa -y \
    && apt-get update && apt-get install -y --no-install-recommends \
    git \
    git-lfs \
    git-man \
    && git lfs install \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Configure Git Defaults
RUN git config --system --add safe.directory '*'

# === LibreOffice ===
RUN add-apt-repository ppa:libreoffice/ppa -y \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        libreoffice \
        libreoffice-gnome \
        libreoffice-java-common \
        libreoffice-help-en-us \
        libreoffice-l10n-en-us \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# === NoMachine ===
ENV NOMACHINE_VER=9.3.7
ENV NOMACHINE_REL=1

RUN wget -q "https://download.nomachine.com/download/9.3/Linux/nomachine_${NOMACHINE_VER}_${NOMACHINE_REL}_amd64.deb" -O /tmp/nomachine.deb \
    && apt-get update \
    && apt-get install -y /tmp/nomachine.deb \
    && rm /tmp/nomachine.deb \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# NoMachine Config
RUN echo "EnablePasswordAuthentication 0" >> /usr/NX/etc/server.cfg && \
    echo "EnableClipboard both" >> /usr/NX/etc/server.cfg && \
    echo "EnableDesktopSharing 1" >> /usr/NX/etc/server.cfg && \
    echo "AcceptConnections 1" >> /usr/NX/etc/server.cfg && \
    echo "MaxConcurrentSessions 2" >> /usr/NX/etc/server.cfg && \
    echo "EnableAudio 1" >> /usr/NX/etc/server.cfg && \
    echo "AudioEncoding both" >> /usr/NX/etc/server.cfg && \
    echo "DisplayServerVideoCodec h264" >> /usr/NX/etc/server.cfg && \
    echo "DisplayServerNetQuality 2" >> /usr/NX/etc/server.cfg && \
    echo "DisplayServerFrameRateLimit 60" >> /usr/NX/etc/server.cfg && \
    \
    echo "PhysicalDisplays :0" >> /usr/NX/etc/node.cfg && \
    echo "VirtualDesktop 0" >> /usr/NX/etc/node.cfg && \
    echo "CreateDisplay 0" >> /usr/NX/etc/node.cfg && \
    rm -f /etc/nxserver/nxserver.conf

# === VLC Media Player ===
RUN apt-get update && apt-get install -y --no-install-recommends \
    vlc \
    vlc-plugin-base \
    vlc-plugin-video-output \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# === VLC Configuration ===
RUN sed -i 's/geteuid/getppid/' /usr/bin/vlc

# === The Eyes (Eye) - Screen Monitoring Tool ===
RUN curl -L -o /tmp/eye.tar.gz "https://github.com/nullvoider07/the-eyes/releases/download/v0.2.0/eye-0.2.0-linux-x64.tar.gz" \
    && tar -xzf /tmp/eye.tar.gz -C /tmp \
    && mv /tmp/bin/eye /usr/local/bin/eye \
    && mv /tmp/bin/eye-server /usr/local/bin/eye-server \
    && chmod +x /usr/local/bin/eye /usr/local/bin/eye-server \
    && rm -rf /tmp/eye.tar.gz /tmp/bin

# Configure Eye Environment Variables
RUN echo 'export DISPLAY=:0' >> /etc/profile.d/eye-env.sh \
    && echo 'export XAUTHORITY=/run/user/$(id -u)/gdm/Xauthority' >> /etc/profile.d/eye-env.sh \
    && chmod 644 /etc/profile.d/eye-env.sh

# === 10. Configurations/Customizations ===
# Override logind.conf
COPY config/logind.conf /etc/systemd/logind.conf

# Copy all scripts, service, customization files
COPY scripts/*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

# === Copy Systemd Services ===
COPY config/systemd/*.service /etc/systemd/system/

# === Copy Wallpapers ===
COPY favourites/ /usr/share/backgrounds/favourites/
RUN chown -R root:root /usr/share/backgrounds/favourites && \
    chmod 644 /usr/share/backgrounds/favourites/*

# === Set Default Wallpaper (copy to system location) ===
COPY favourites/19228.jpg /usr/share/backgrounds/default-wallpaper.jpg
RUN chmod 644 /usr/share/backgrounds/default-wallpaper.jpg

# GDM Login Wallpaper
RUN mkdir -p /usr/share/backgrounds/gdm && \
    cp /usr/share/backgrounds/default-wallpaper.jpg /usr/share/backgrounds/gdm/ && \
    sed -i 's|background-image:.*|background-image: url(file:///usr/share/backgrounds/gdm/default-wallpaper.jpg);|' /usr/share/gnome-shell/theme/gnome-shell.css || true

# === 11. Systemd Services ===
# Docker Systemd Fix
RUN mkdir -p /etc/systemd/system.conf.d && \
    echo '[Manager]\nManagerEnvironment=SYSTEMD_GENERATOR_SANDBOXED=0\nSystemCallArchitectures=native' > /etc/systemd/system.conf.d/10-docker.conf

# GDM depends on GPU setup
RUN mkdir -p /etc/systemd/system/gdm.service.d && \
    printf "[Unit]\nAfter=gpu-setup.service\n" > /etc/systemd/system/gdm.service.d/override.conf

# Enable All services
RUN mkdir -p \
      /etc/systemd/system/multi-user.target.wants \
      /etc/systemd/system/graphical.target.wants && \
    ln -sf /etc/systemd/system/create-disk.service /etc/systemd/system/multi-user.target.wants/ && \
    ln -s /etc/systemd/system/supervisord.service /etc/systemd/system/multi-user.target.wants/ && \
    ln -s /etc/systemd/system/gpu-setup.service /etc/systemd/system/graphical.target.wants/

# Eye Agent Service
COPY config/systemd/eye-agent.service /usr/lib/systemd/user/eye-agent.service
COPY scripts/eye-daemon.sh /usr/local/bin/eye-daemon.sh
RUN chmod +x /usr/local/bin/eye-daemon.sh

# Enable Eye Agent for the user
RUN mkdir -p /usr/lib/systemd/user/default.target.wants && \
    ln -sf /usr/lib/systemd/user/eye-agent.service \
           /usr/lib/systemd/user/default.target.wants/eye-agent.service

# === 12. Final Settings ===
ENV container=docker \
    SYSTEMD_LOG_LEVEL=info \
    GDK_BACKEND=x11 \
    XDG_SESSION_TYPE=x11
WORKDIR /workspace
EXPOSE 4000 7681 2222 8080
STOPSIGNAL SIGRTMIN+3
VOLUME /run
RUN chown -R 1001:1001 /home/cua-*

HEALTHCHECK --interval=30s --timeout=15s --start-period=120s --retries=5 \
    CMD /bin/bash -c 'pgrep -f gnome-shell && pgrep -f nxserver && pgrep -f ttyd'

ENTRYPOINT ["/lib/systemd/systemd"]