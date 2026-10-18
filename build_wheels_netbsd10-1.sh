#!/bin/sh
#
# WebZFS Wheel Builder for NetBSD 10.1
#
# This script builds Python wheels for packages that require native compilation.
# Pre-built wheels eliminate the need to compile dependencies during installation.
#
# It fetches the current requirements.txt from the main webzfs repo on GitHub
# and builds wheels for packages that need native compilation:
#   - pydantic-core (Rust)
#   - cryptography (Rust + C)
#   - bcrypt (Rust)
#   - psutil (C)
#   - markupsafe (C)
#   - cffi (C)
#   - pynacl (C, requires libsodium)
#
# Wheels are built with CPython 3.12 (cp312). This is the WebZFS Python ABI
# target for NetBSD.
#
# Usage: Run this script on a NetBSD 10.x system to generate wheels.
#        The wheels will be placed in the wheelhouse/netbsd10-1 directory.
#
# Requirements: Must be run as root to install build dependencies.
#
# NOTE: The pkgsrc rust package has Bus error issues on NetBSD.
#       This script uses rustup to install a working Rust compiler.
#

set -e

# Configuration
PYTHON_VERSION="312"
PYTHON_CMD="python3.12"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
WHEELHOUSE_DIR="$REPO_DIR/wheelhouse/netbsd10-1"
BUILD_DIR="/tmp/webzfs_wheel_build"
# Branch of webzfs/webzfs to read requirements.txt from. Override with
# WEBZFS_BRANCH=<branch> to build wheels before changes are merged to main.
WEBZFS_BRANCH="${WEBZFS_BRANCH:-main}"
REQUIREMENTS_URL="https://raw.githubusercontent.com/webzfs/webzfs/refs/heads/${WEBZFS_BRANCH}/requirements.txt"

# Packages that require native compilation (need pre-built wheels)
NATIVE_PACKAGES="pydantic-core cryptography bcrypt psutil markupsafe cffi pynacl"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "WebZFS Wheel Builder for NetBSD 10.1"
echo "========================================"
echo

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    printf "${RED}Error: This script must be run as root${NC}\n"
    echo "Please run: sudo $0"
    exit 1
fi

# Check NetBSD version - this builder is only for NetBSD 10.x
NETBSD_VERSION=$(uname -r)
NETBSD_MAJOR=$(echo "$NETBSD_VERSION" | cut -d. -f1)
echo "NetBSD version: $NETBSD_VERSION"
if [ "$NETBSD_MAJOR" != "10" ]; then
    printf "${RED}Error: This builder targets NetBSD 10.x but this system is NetBSD ${NETBSD_VERSION}${NC}\n"
    echo "Use the builder matching this system's release so wheels are placed"
    echo "in the correct wheelhouse directory."
    exit 1
fi
echo

mkdir -p "$WHEELHOUSE_DIR"

# Fetch requirements.txt from GitHub
echo "Fetching requirements.txt from webzfs/webzfs (branch: ${WEBZFS_BRANCH})..."
REQUIREMENTS_FILE="$BUILD_DIR/requirements.txt"
mkdir -p "$BUILD_DIR"

curl -sSfL -o "$REQUIREMENTS_FILE" "$REQUIREMENTS_URL"

if [ ! -s "$REQUIREMENTS_FILE" ]; then
    printf "${RED}Error: Failed to fetch requirements.txt${NC}\n"
    exit 1
fi

printf "${GREEN}OK${NC} requirements.txt fetched\n"
echo

# Parse package versions from requirements.txt
# Extract "package==version" for each native package
echo "Resolving native package versions from requirements.txt..."
PACKAGES_TO_BUILD=""
for pkg in $NATIVE_PACKAGES; do
    version=$(grep -i "^${pkg}==" "$REQUIREMENTS_FILE" | sed 's/ *;.*//' | head -1)
    if [ -n "$version" ]; then
        PACKAGES_TO_BUILD="$PACKAGES_TO_BUILD $version"
        printf "  ${GREEN}✓${NC} %s\n" "$version"
    else
        printf "  ${RED}✗${NC} %s not found in requirements.txt\n" "$pkg"
    fi
done
echo

if [ -z "$PACKAGES_TO_BUILD" ]; then
    printf "${RED}Error: No native packages found in requirements.txt${NC}\n"
    rm -rf "$BUILD_DIR"
    exit 1
fi

# Install build dependencies via pkgsrc
echo "Installing build dependencies via pkgsrc..."
pkgin -y install python${PYTHON_VERSION} py${PYTHON_VERSION}-pip gmake libsodium curl libffi openssl

if [ $? -ne 0 ]; then
    printf "${RED}Error: Failed to install build dependencies${NC}\n"
    exit 1
fi

printf "${GREEN}OK${NC} pkgsrc dependencies installed\n"
echo

# Install Rust via rustup (pkgsrc rust package has Bus error issues)
echo "Checking Rust installation..."

# Check if rustc exists and actually works (not the broken pkgsrc version)
RUST_WORKS=0
if command -v rustc >/dev/null 2>&1; then
    # Try to run rustc --version, if it crashes with Bus error, we need rustup
    if rustc --version >/dev/null 2>&1; then
        RUST_WORKS=1
        printf "${GREEN}OK${NC} Working Rust installation found\n"
    else
        printf "${YELLOW}Warning: Rust installed but not working (likely Bus error)${NC}\n"
    fi
fi

if [ "$RUST_WORKS" -eq 0 ]; then
    echo "Installing Rust via rustup..."

    # Remove broken pkgsrc rust if installed
    pkgin -y remove rust 2>/dev/null || true

    # Install via rustup
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal --no-modify-path

    # Source cargo environment
    export PATH="$HOME/.cargo/bin:$PATH"
    . "$HOME/.cargo/env" 2>/dev/null || true

    # Verify it works
    if ! rustc --version >/dev/null 2>&1; then
        printf "${RED}Error: Rust installation via rustup failed${NC}\n"
        exit 1
    fi

    printf "${GREEN}OK${NC} Rust installed via rustup\n"
else
    # Make sure cargo is in PATH
    if [ -f "$HOME/.cargo/env" ]; then
        . "$HOME/.cargo/env"
    fi
fi

printf "${GREEN}OK${NC} Rust $(rustc --version | cut -d' ' -f2) found\n"

# Verify Python
if ! command -v $PYTHON_CMD >/dev/null 2>&1; then
    printf "${RED}Error: Python not found${NC}\n"
    exit 1
fi
printf "${GREEN}OK${NC} $($PYTHON_CMD --version) found\n"

# Verify gmake
if ! command -v gmake >/dev/null 2>&1; then
    printf "${RED}Error: gmake not found${NC}\n"
    exit 1
fi
printf "${GREEN}OK${NC} gmake found\n"

# Verify libsodium
if [ ! -f "/usr/pkg/include/sodium.h" ]; then
    printf "${YELLOW}Warning: libsodium not found in expected location${NC}\n"
else
    printf "${GREEN}OK${NC} libsodium found\n"
fi
echo

# Create build directory (already exists from fetch step)
echo "Setting up build directory: $BUILD_DIR"
cd "$BUILD_DIR"

# Create virtual environment for building
echo "Creating build virtual environment..."
$PYTHON_CMD -m venv build_venv
. build_venv/bin/activate

# Upgrade pip and install build tools
echo "Installing build tools..."
pip install --upgrade pip wheel setuptools
pip install maturin  # Required for Rust-based packages

printf "${GREEN}OK${NC} Build environment ready\n"
echo

# Set environment for building
export MAKE=$(command -v gmake)
export PATH="$HOME/.cargo/bin:$PATH"

# Set library paths for NetBSD pkgsrc
export CFLAGS="-I/usr/pkg/include"
export LDFLAGS="-L/usr/pkg/lib -Wl,-R/usr/pkg/lib"
export PKG_CONFIG_PATH="/usr/pkg/lib/pkgconfig"

# PyNaCl should link against the pkgsrc libsodium instead of building
# its bundled copy
export SODIUM_INSTALL="system"

# Build wheels
echo "========================================"
echo "Building wheels..."
echo "========================================"
echo

FAIL_COUNT=0
for pkg_spec in $PACKAGES_TO_BUILD; do
    pkg_name=$(echo "$pkg_spec" | cut -d'=' -f1)
    echo "Building ${pkg_spec}..."
    if pip wheel --no-deps --wheel-dir="$WHEELHOUSE_DIR" "$pkg_spec"; then
        printf "${GREEN}OK${NC} %s wheel built\n" "$pkg_name"
    else
        printf "${RED}FAILED${NC} %s wheel build failed\n" "$pkg_name"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    echo
done

# Deactivate virtual environment
deactivate

# Clean up
echo "Cleaning up build directory..."
rm -rf "$BUILD_DIR"

# List built wheels
echo
echo "========================================"
echo "Wheels built for NetBSD 10.1:"
echo "========================================"
ls -la "$WHEELHOUSE_DIR/"
echo

if [ "$FAIL_COUNT" -gt 0 ]; then
    printf "${RED}Warning: %d wheel(s) failed to build${NC}\n" "$FAIL_COUNT"
else
    echo "========================================"
    printf "${GREEN}Wheel building complete!${NC}\n"
    echo "========================================"
fi
echo
echo "To use these wheels during installation, use:"
echo "  pip install --find-links=$WHEELHOUSE_DIR -r requirements.txt"
echo
