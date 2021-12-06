#!/usr/bin/env sh
set -eu

VERSION="latest"
REPO="useimmutable/agent-releases"
URL="https://api.github.com/repos/$REPO/releases/$VERSION"

# Find out what version we should be installing
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

if [ "$OS" = "linux" ]; then
  if [ "$ARCH" = "x86_64" ]; then
    PLATFORM="x86_64-unknown-linux-musl"
  elif [ "$ARCH" = "arm64" ]; then
    PLATFORM="aarch64-unknown-linux-musl"
  else
    echo "Unsupported operating system and architecture: $OS ($ARCH)"
    exit 1
  fi
elif [ "$OS" = "darwin" ]; then
  if [ "$ARCH" = "x86_64" ]; then
    PLATFORM="x86_64-apple-darwin"
  elif [ "$ARCH" = "arm64" ]; then
    echo "warning: using x86_64-apple-darwin target for arm64"
    PLATFORM="x86_64-apple-darwin"
  else
    echo "Unsupported operating system and architecture: $OS ($ARCH)"
    exit 1
  fi
else
  echo "Unsupported operating system: $OS"
  exit 1
fi
echo "Installing agent for $OS ($ARCH)..."
echo "  => immutable-agent target = $VERSION@$PLATFORM"

echo "Discovering latest release via Github..."
PACKAGE_URL=$(curl --progress-bar $URL \
    | grep "browser_download_url.*$PLATFORM" \
    | cut -d : -f 2,3 \
    | tr -d \")
echo "  => $PACKAGE_URL"
echo ""

ZIP_LOC="$(mktemp -d)/agent.zip"

echo "Downloading latest release..."
curl --progress-bar -L $PACKAGE_URL -o $ZIP_LOC
echo "  => downloaded to $ZIP_LOC"
echo ""

echo "Unzipping..."
unzip -q $ZIP_LOC -d $(pwd)
echo "  => unzipped to $(pwd)"
echo ""

if [ -f $ZIP_LOC ]; then
    echo "Cleaning up..."
    rm $ZIP_LOC
    echo ""
fi

if [ ! -f "immutable_agent" ]; then
    echo "Failed to download agent binary"
    exit 1
fi

echo "Immutable agent binary downloaded successfully"
echo "Get started by running: ${PWD}/immutable_agent"

