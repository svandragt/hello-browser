#!/bin/bash
set -euo pipefail

# Only run in Claude Code on the web. Local sessions already have whatever the
# user installed.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Install build deps for the GTK4/WebKitGTK Vala app. Idempotent: apt-get
# install is a no-op when packages are already at the latest version.
export DEBIAN_FRONTEND=noninteractive
# Don't fail the session if a third-party PPA on the container is broken —
# our deps are in the main Ubuntu repos.
sudo -n apt-get update -qq || true
sudo -n apt-get install -y --no-install-recommends \
  meson \
  ninja-build \
  valac \
  pkg-config \
  libgtk-4-dev \
  libwebkitgtk-6.0-dev \
  libglib2.0-bin

# Configure the build dir if it doesn't exist yet, so `ninja -C build` works
# straight away. `--prefix` matches the README's recommended user-prefix flow.
if [ ! -f "$CLAUDE_PROJECT_DIR/build/build.ninja" ]; then
  (cd "$CLAUDE_PROJECT_DIR" && meson setup build --prefix="$HOME/.local")
fi

# Persist XDG_DATA_DIRS so installed GSettings schemas are discoverable when
# running the binary from build/.
echo "export XDG_DATA_DIRS=\"\$HOME/.local/share:\${XDG_DATA_DIRS:-/usr/local/share:/usr/share}\"" \
  >> "$CLAUDE_ENV_FILE"
