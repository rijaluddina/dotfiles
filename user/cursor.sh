#!/bin/bash

installCursor() {
  local CURSOR_URL="https://downloader.cursor.sh/linux/appImage/x64"
  local ICON_URL="https://www.cursor.com/favicon.svg"
  local APPIMAGE_PATH="$HOME/.local/bin/cursor.appimage"
  local ICON_PATH="$HOME/.local/share/icons/cursor.png"
  local DESKTOP_ENTRY_PATH="$HOME/.local/share/applications/cursor.desktop"

  echo "[INFO] Checking for existing Cursor installation..."

  # Detect the user's shell
  local SHELL_NAME=$(basename "$SHELL")
  local RC_FILE=""

  case "$SHELL_NAME" in
  bash) RC_FILE="$HOME/.bashrc" ;;
  zsh) RC_FILE="$HOME/.zshrc" ;;
  fish) RC_FILE="$HOME/.config/fish/config.fish" ;;
  *)
    echo "[WARNING] Unsupported shell: $SHELL_NAME. Please manually add the alias."
    return 1
    ;;
  esac

  if [ -f "$APPIMAGE_PATH" ]; then
    echo "[INFO] Cursor AI IDE is already installed. Updating existing installation..."
  else
    echo "[INFO] Performing a fresh installation of Cursor AI IDE..."
  fi

  # Install curl if not installed
  if ! command -v curl &>/dev/null; then
    echo "[INFO] curl is not installed. Attempting to install..."
    if command -v apt-get &>/dev/null; then
      sudo apt-get update && sudo apt-get install -y curl || {
        echo "[ERROR] Failed to install curl."
        exit 1
      }
    elif command -v dnf &>/dev/null; then
      sudo dnf install -y curl || {
        echo "[ERROR] Failed to install curl."
        exit 1
      }
    elif command -v pacman &>/dev/null; then
      sudo pacman -Sy --noconfirm curl || {
        echo "[ERROR] Failed to install curl."
        exit 1
      }
    else
      echo "[ERROR] Unsupported package manager. Please install curl manually."
      exit 1
    fi
  fi

  # Download AppImage and Icon with validation
  echo "[INFO] Downloading Cursor AppImage..."
  curl -L --progress-bar "$CURSOR_URL" -o /tmp/cursor.appimage || {
    echo "[ERROR] Failed to download AppImage."
    exit 1
  }
  if [ ! -s /tmp/cursor.appimage ]; then
    echo "[ERROR] AppImage download failed."
    exit 1
  fi

  echo "[INFO] Downloading Cursor icon..."
  curl -L --progress-bar "$ICON_URL" -o /tmp/cursor.png || {
    echo "[ERROR] Failed to download icon."
    exit 1
  }
  if [ ! -s /tmp/cursor.png ]; then
    echo "[ERROR] Icon download failed."
    exit 1
  fi

  echo "[INFO] Installing Cursor files..."
  install -Dm 755 /tmp/cursor.appimage "$APPIMAGE_PATH"
  install -Dm 644 /tmp/cursor.png "$ICON_PATH"

  echo "[INFO] Creating .desktop entry..."
  printf "[Desktop Entry]\nName=Cursor\nExec=%s --no-sandbox\nIcon=%s\nTerminal=false\nType=Application\nCategories=Development;\n" "$APPIMAGE_PATH" "$ICON_PATH" | install -Dm 644 /dev/stdin "$DESKTOP_ENTRY_PATH"

  echo "[INFO] Adding cursor alias to $RC_FILE..."
  if [ "$SHELL_NAME" = "fish" ]; then
    if ! grep -q "function cursor" "$RC_FILE"; then
      echo "function cursor" >>"$RC_FILE"
      echo "    $APPIMAGE_PATH --no-sandbox \$argv > /dev/null 2>&1 & disown" >>"$RC_FILE"
      echo "end" >>"$RC_FILE"
    else
      echo "[INFO] Alias already exists in $RC_FILE."
    fi
  else
    if ! grep -q "function cursor" "$RC_FILE"; then
      cat >>"$RC_FILE" <<EOL

# Cursor alias
function cursor() {
    $APPIMAGE_PATH --no-sandbox "\${@}" > /dev/null 2>&1 & disown
}
EOL
    else
      echo "[INFO] Alias already exists in $RC_FILE."
    fi
  fi

  echo "[INFO] To apply changes, restart your terminal or run: source $RC_FILE"
  echo "[SUCCESS] Cursor AI IDE installation or update complete. You can find it in your application menu."
}

installCursor
