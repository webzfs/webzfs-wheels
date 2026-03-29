#!/bin/sh
#
# WebZFS Wheel Builder for FreeBSD 14.4
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
#   - cffi (C) - runtime dependency of pynacl
#   - pynacl (C + libsodium) - runtime dependency of paramiko
#
# Usage: Run this script on a FreeBSD 14.4 system to generate wheels.
#        The wheels will be placed in the wheelhouse directory.
#
# Requirements: Must be run as root to install build dependencies.
#

set -e

# Configuration
PYTHON_VERSION="311"
PYTHON_CMD="python3.11"
WHEELHOUSE_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="/tmp/webzfs_wheel_build"
REQUIREMENTS_URL="https://raw.githubusercontent.com/webzfs/webzfs/refs/heads/main/requirements.txt"

# Packages that require native compilation (need pre-built wheels)
NATIVE_PACKAGES="pydantic-core cryptography bcrypt psutil markupsafe cffi pynacl"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "WebZFS Wheel Builder for FreeBSD 14.4"
echo "========================================"
echo

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    printf "${RED}Error: This script must be run as root${NC}\n"
    echo "Please run: sudo $0"
    exit 1
fi

# Check FreeBSD version
FREEBSD_VERSION=$(uname -r | cut -d'-' -f1)
echo "FreeBSD version: $FREEBSD_VERSION"
echo

# Fetch requirements.txt from GitHub
echo "Fetching requirements.txt from webzfs/webzfs..."
REQUIREMENTS_FILE="$BUILD_DIR/requirements.txt"
mkdir -p "$BUILD_DIR"

fetch -o "$REQUIREMENTS_FILE" "$REQUIREMENTS_URL" 2>/dev/null || \
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

# Install build dependencies
echo "Installing build dependencies..."
pkg install -y python${PYTHON_VERSION} py${PYTHON_VERSION}-pip rust gmake libffi openssl libsodium

if [ $? -ne 0 ]; then
    printf "${RED}Error: Failed to install build dependencies${NC}\n"
    exit 1
fi

printf "${GREEN}OK${NC} Build dependencies installed\n"
echo

# Verify Rust
if ! command -v rustc >/dev/null 2>&1; then
    printf "${RED}Error: Rust compiler not found${NC}\n"
    exit 1
fi
printf "${GREEN}OK${NC} Rust $(rustc --version | cut -d' ' -f2) found\n"

# Verify Python
if ! command -v $PYTHON_CMD >/dev/null 2>&1; then
    printf "${RED}Error: Python not found${NC}\n"
    exit 1
fi
printf "${GREEN}OK${NC} $($PYTHON_CMD --version) found\n"
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

# Build wheels
echo "========================================"
echo "Building wheels..."
echo "========================================"
echo

FAIL_COUNT=0
for pkg_spec in $PACKAGES_TO_BUILD; do
    pkg_name=$(echo "$pkg_spec" | cut -d'=' -f1)
    echo "Building ${pkg_spec}..."
    if pip wheel --no-deps --wheel-dir="$WHEELHOUSE_DIR/freebsd14" "$pkg_spec"; then
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
echo "Wheels built for FreeBSD 14.4:"
echo "========================================"
ls -la "$WHEELHOUSE_DIR/freebsd14/"
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
echo "  pip install --find-links=$WHEELHOUSE_DIR/freebsd14 -r requirements.txt"
echo
