#!/usr/bin/env bash

set -euo pipefail

APP_NAME="dysen-ui"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="$ROOT_DIR/.venv"
LOCAL_BIN="${XDG_BIN_HOME:-$HOME/.local/bin}"
DESKTOP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"

say() {
    printf '\n[DYSEN] %s\n' "$1"
}

die() {
    printf '\n[DYSEN] ERROR: %s\n' "$1" >&2
    exit 1
}

command -v python3 >/dev/null 2>&1 || die "Python 3 is required."

PYTHON_VERSION="$(
    python3 -c 'import sys; print(".".join(map(str, sys.version_info[:3])))'
)"

PYTHON_MAJOR="$(
    python3 -c 'import sys; print(sys.version_info[0])'
)"
PYTHON_MINOR="$(
    python3 -c 'import sys; print(sys.version_info[1])'
)"

if [ "$PYTHON_MAJOR" -ne 3 ] || [ "$PYTHON_MINOR" -lt 12 ] || [ "$PYTHON_MINOR" -ge 15 ]; then
    die "DYSEN requires Python 3.12-3.14. Found $PYTHON_VERSION."
fi

install_system_deps() {
    if command -v apt-get >/dev/null 2>&1; then
        say "Debian-family system detected."

        packages=(
            python3-venv
            python3-pip
            libgl1
            libegl1
            libxkbcommon0
            libxkbcommon-x11-0
            libxcb-cursor0
            libxcb-xinerama0
            libdbus-1-3
            libpulse0
        )

        missing=()

        for pkg in "${packages[@]}"; do
            if ! dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q 'install ok installed'; then
                missing+=("$pkg")
            fi
        done

        if [ "${#missing[@]}" -gt 0 ]; then
            say "Installing missing system packages: ${missing[*]}"
            sudo apt-get update
            sudo apt-get install -y "${missing[@]}"
        else
            say "System dependencies already satisfied."
        fi

    elif command -v dnf >/dev/null 2>&1; then
        say "Fedora-family system detected."
        say "Installing common Qt runtime dependencies."

        sudo dnf install -y \
            python3 \
            python3-pip \
            python3-devel \
            mesa-libGL \
            libglvnd-egl \
            libxkbcommon \
            libxkbcommon-x11 \
            libxcb \
            dbus-libs \
            pulseaudio-libs

    elif command -v pacman >/dev/null 2>&1; then
        say "Arch-family system detected."
        say "Installing common Qt runtime dependencies."

        sudo pacman -Sy --needed \
            python \
            python-pip \
            mesa \
            libglvnd \
            libxkbcommon \
            libxcb \
            dbus \
            libpulse

    else
        say "Unknown Linux package manager."
        say "Continuing with Python environment setup."
    fi
}

install_system_deps

say "Creating Python virtual environment."
python3 -m venv "$VENV_DIR" || die "Could not create virtual environment."

say "Upgrading pip tooling."
"$VENV_DIR/bin/python" -m pip install --upgrade pip setuptools wheel

say "Installing DYSEN Python dependencies."
"$VENV_DIR/bin/python" -m pip install -r "$ROOT_DIR/requirements.txt"

mkdir -p "$LOCAL_BIN" "$DESKTOP_DIR"

cat > "$LOCAL_BIN/$APP_NAME" <<LAUNCHER
#!/usr/bin/env bash
exec "$VENV_DIR/bin/python" "$ROOT_DIR/main.py" "\$@"
LAUNCHER

chmod +x "$LOCAL_BIN/$APP_NAME"

cat > "$DESKTOP_DIR/$APP_NAME.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=DYSEN UI
Comment=DYSEN desktop UI
Exec=$LOCAL_BIN/$APP_NAME
Terminal=false
Categories=Utility;System;
StartupWMClass=DYSEN
DESKTOP

say "Installation complete."
say "Launcher: $LOCAL_BIN/$APP_NAME"
say "Desktop entry: $DESKTOP_DIR/$APP_NAME.desktop"
say "Run: $APP_NAME"
