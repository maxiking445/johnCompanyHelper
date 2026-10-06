#!/usr/bin/env bash
set -euo pipefail

# Set up the local Android toolchain used by Godot.
#
# Optional environment variables:
#   ANDROID_SDK_ROOT  Android SDK location
#   JAVA_HOME         JDK 17 location
#   ANDROID_API       Android platform to install (default: 35)
#   ANDROID_BUILD_TOOLS Build tools version (default: 35.0.1)
#   ANDROID_NDK       NDK version (default: 28.1.13356709)
#   ANDROID_CMAKE     CMake version (default: 3.10.2.4988404)

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_API="${ANDROID_API:-35}"
ANDROID_BUILD_TOOLS="${ANDROID_BUILD_TOOLS:-35.0.1}"
ANDROID_NDK="${ANDROID_NDK:-28.1.13356709}"
ANDROID_CMAKE="${ANDROID_CMAKE:-3.10.2.4988404}"

log() {
  printf '[android-setup] %s\n' "$*" >&2
}

fail() {
  printf '[android-setup] ERROR: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Benötigtes Kommando fehlt: $1"
}

install_system_packages() {
  if command -v java >/dev/null 2>&1 && command -v curl >/dev/null 2>&1 && command -v unzip >/dev/null 2>&1; then
    log "OpenJDK, curl und unzip sind bereits installiert; überspringe Systempakete."
    return
  fi

  if command -v pacman >/dev/null 2>&1; then
    log "Installiere Linux-Pakete über pacman."
    sudo pacman -S --needed --noconfirm jdk17-openjdk unzip curl
    return
  fi

  if command -v apt-get >/dev/null 2>&1; then
    log "Installiere Linux-Pakete über apt."
    sudo apt-get update
    sudo apt-get install -y openjdk-17-jdk unzip curl ca-certificates
    return
  fi

  if command -v brew >/dev/null 2>&1; then
    log "Installiere Pakete über Homebrew."
    brew install openjdk@17
    return
  fi

  fail "Kein unterstützter Paketmanager gefunden. Installiere OpenJDK 17, curl und unzip manuell."
}

find_sdk_root() {
  if [[ -n "${ANDROID_SDK_ROOT:-}" ]]; then
    printf '%s\n' "${ANDROID_SDK_ROOT}"
    return
  fi

  if [[ -n "${ANDROID_HOME:-}" ]]; then
    printf '%s\n' "${ANDROID_HOME}"
    return
  fi

  case "$(uname -s)" in
    Darwin) printf '%s\n' "${HOME}/Library/Android/sdk" ;;
    Linux) printf '%s\n' "${HOME}/Android/Sdk" ;;
    *) fail "Nicht unterstütztes Betriebssystem: $(uname -s)" ;;
  esac
}

find_sdkmanager() {
  local sdk_root="$1"
  if command -v sdkmanager >/dev/null 2>&1; then
    command -v sdkmanager
    return
  fi

  for candidate in \
    "${sdk_root}/cmdline-tools/latest/bin/sdkmanager" \
    "${sdk_root}/cmdline-tools/bin/sdkmanager" \
    "${sdk_root}/tools/bin/sdkmanager"; do
    if [[ -x "${candidate}" ]]; then
      printf '%s\n' "${candidate}"
      return
    fi
  done

  return 1
}

install_command_line_tools() {
  local sdk_root="$1"
  local sdkmanager_path

  if sdkmanager_path="$(find_sdkmanager "${sdk_root}")"; then
    printf '%s\n' "${sdkmanager_path}"
    return
  fi

  mkdir -p "${sdk_root}/cmdline-tools"
  local archive="${TMPDIR:-/tmp}/commandlinetools.zip"
  local url="https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip"

  if [[ "$(uname -s)" == "Darwin" ]]; then
    url="https://dl.google.com/android/repository/commandlinetools-mac-13114758_latest.zip"
  fi

  log "Lade Android Command-line Tools herunter."
  curl -fL --retry 3 "${url}" -o "${archive}"
  rm -rf "${sdk_root}/cmdline-tools/latest"
  mkdir -p "${sdk_root}/cmdline-tools/latest"
  unzip -q "${archive}" -d "${sdk_root}/cmdline-tools/latest"

  # Google ships the archive with a nested cmdline-tools directory.
  if [[ -d "${sdk_root}/cmdline-tools/latest/cmdline-tools" ]]; then
    shopt -s dotglob
    mv "${sdk_root}/cmdline-tools/latest/cmdline-tools"/* "${sdk_root}/cmdline-tools/latest/"
    rmdir "${sdk_root}/cmdline-tools/latest/cmdline-tools"
    shopt -u dotglob
  fi

  sdkmanager_path="${sdk_root}/cmdline-tools/latest/bin/sdkmanager"
  [[ -x "${sdkmanager_path}" ]] || fail "sdkmanager wurde nicht gefunden: ${sdkmanager_path}"
  printf '%s\n' "${sdkmanager_path}"
}

main() {
  [[ "$(uname -s)" == "Linux" || "$(uname -s)" == "Darwin" ]] || \
    fail "Dieses Skript unterstützt Linux und macOS."

  if [[ "${EUID}" -eq 0 ]]; then
    fail "Bitte nicht als root ausführen; das Skript verwendet sudo nur für Systempakete."
  fi

  install_system_packages
  require_command curl
  require_command unzip
  require_command godot

  local sdk_root
  sdk_root="$(find_sdk_root)"
  mkdir -p "${sdk_root}"

  local sdkmanager_path
  sdkmanager_path="$(install_command_line_tools "${sdk_root}")"
  export ANDROID_SDK_ROOT="${sdk_root}"
  export ANDROID_HOME="${sdk_root}"
  export PATH="$(dirname "${sdkmanager_path}"):${sdk_root}/platform-tools:${sdk_root}/emulator:${PATH}"

  local java_path="${JAVA_HOME:-}"
  if [[ -z "${java_path}" ]]; then
    if command -v java >/dev/null 2>&1; then
      if command -v readlink >/dev/null 2>&1 && readlink -f "$(command -v java)" >/dev/null 2>&1; then
        java_path="$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")"
      fi
    fi
    if [[ -z "${java_path}" ]] && command -v /usr/libexec/java_home >/dev/null 2>&1; then
      java_path="$(/usr/libexec/java_home -v 17)"
    fi
    if [[ -z "${java_path}" ]] && [[ -d /usr/lib/jvm/java-17-openjdk ]]; then
      java_path="/usr/lib/jvm/java-17-openjdk"
    fi
    if [[ -z "${java_path}" ]] && [[ -d /usr/lib/jvm/java-17-openjdk-amd64 ]]; then
      java_path="/usr/lib/jvm/java-17-openjdk-amd64"
    fi
    if [[ -z "${java_path}" ]] && [[ -d /opt/homebrew/opt/openjdk@17 ]]; then
      java_path="/opt/homebrew/opt/openjdk@17"
    fi
    if [[ -z "${java_path}" ]] && [[ -d /usr/local/opt/openjdk@17 ]]; then
      java_path="/usr/local/opt/openjdk@17"
    fi
  fi
  [[ -n "${java_path}" && -x "${java_path}/bin/java" ]] || \
    fail "OpenJDK 17 wurde nicht gefunden. Setze JAVA_HOME auf dessen Installationspfad."

  log "Installiere Android SDK-Komponenten."
  yes | "${sdkmanager_path}" --sdk_root="${sdk_root}" --licenses >/dev/null || true
  "${sdkmanager_path}" --sdk_root="${sdk_root}" \
    "platform-tools" \
    "platforms;android-${ANDROID_API}" \
    "build-tools;${ANDROID_BUILD_TOOLS}" \
    "cmdline-tools;latest" \
    "cmake;${ANDROID_CMAKE}" \
    "ndk;${ANDROID_NDK}"

  log "Installiere Godot Android Build Template."
  godot --headless --editor --path "${PROJECT_DIR}" \
    --quit \
    --install-android-build-template

  log "Android-Toolchain ist eingerichtet."
  log "SDK: ${sdk_root}"
  log "Java: ${java_path}"
  log "API: android-${ANDROID_API}"
  log "Build-Tools: ${ANDROID_BUILD_TOOLS}"
  log "NDK: ${ANDROID_NDK}"
  log "Setze in Godot Editor Settings > Export > Android diese beiden Pfade:"
  log "  Java SDK Path: ${java_path}"
  log "  Android SDK Path: ${sdk_root}"
  log "Installiere dort außerdem die Exporttemplates für $(godot --version | head -n 1), falls sie noch fehlen."
  log "Danach: godot --headless --path . --export-debug \"Android\" build/android/JohnCompanyHelper-debug.apk"
}

main "$@"
