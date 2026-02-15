#!/bin/sh
#
# WebZFS Wheel Builder for NetBSD
# 
# This script builds Python wheels for packages that require native compilation.
# Pre-built wheels eliminate the need to compile dependencies during installation.
#
# Packages built:
#   - pydantic-core (Rust)
#   - cryptography (Rust + C)
#   - psutil (C)
#   - markupsafe (C)
#
# Usage: Run this script on a NetBSD system to generate wheels.
#        The wheels will be placed in the wheelhouse directory.
#
# Requirements: Must be run as root to install build dependencies.
#
# NOTE: The pkgsrc rust package has Bus error issues on NetBSD.
#       This script uses rustup to install a working Rust compiler.
#

set -e

# Configuration
PYTHON_VERSION="311"
PYTHON_CMD="python3.11"
WHEELHOUSE_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="/tmp/webzfs_wheel_build"

# Package versions from requirements.txt
PYDANTIC_CORE_VERSION="2.41.5"
CRYPTOGRAPHY_VERSION="44.0.0"
PSUTIL_VERSION="7.1.3"
MARKUPSAFE_VERSION="3.0.3"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "WebZFS Wheel Builder for NetBSD"
echo "========================================"
echo

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    printf "${RED}Error: This script must be run as root${NC}\n"
    echo "Please run: sudo $0"
    exit 1
fi

# Check NetBSD version
NETBSD_VERSION=$(uname -r)
echo "NetBSD version: $NETBSD_VERSION"
echo

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

# Create build directory
echo "Creating build directory: $BUILD_DIR"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
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

# Build wheels
echo "========================================"
echo "Building wheels..."
echo "========================================"
echo

# pydantic-core
echo "Building pydantic-core==${PYDANTIC_CORE_VERSION}..."
pip wheel --no-deps --wheel-dir="$WHEELHOUSE_DIR/netbsd" "pydantic-core==${PYDANTIC_CORE_VERSION}"
if [ $? -eq 0 ]; then
    printf "${GREEN}OK${NC} pydantic-core wheel built\n"
else
    printf "${RED}FAILED${NC} pydantic-core wheel build failed\n"
fi
echo

# cryptography
echo "Building cryptography==${CRYPTOGRAPHY_VERSION}..."
pip wheel --no-deps --wheel-dir="$WHEELHOUSE_DIR/netbsd" "cryptography==${CRYPTOGRAPHY_VERSION}"
if [ $? -eq 0 ]; then
    printf "${GREEN}OK${NC} cryptography wheel built\n"
else
    printf "${RED}FAILED${NC} cryptography wheel build failed\n"
fi
echo

# psutil
echo "Building psutil==${PSUTIL_VERSION}..."
pip wheel --no-deps --wheel-dir="$WHEELHOUSE_DIR/netbsd" "psutil==${PSUTIL_VERSION}"
if [ $? -eq 0 ]; then
    printf "${GREEN}OK${NC} psutil wheel built\n"
else
    printf "${RED}FAILED${NC} psutil wheel build failed\n"
fi
echo

# markupsafe
echo "Building markupsafe==${MARKUPSAFE_VERSION}..."
pip wheel --no-deps --wheel-dir="$WHEELHOUSE_DIR/netbsd" "markupsafe==${MARKUPSAFE_VERSION}"
if [ $? -eq 0 ]; then
    printf "${GREEN}OK${NC} markupsafe wheel built\n"
else
    printf "${RED}FAILED${NC} markupsafe wheel build failed\n"
fi
echo

# Deactivate virtual environment
deactivate

# Clean up
echo "Cleaning up build directory..."
rm -rf "$BUILD_DIR"

# List built wheels
echo
echo "========================================"
echo "Wheels built for NetBSD:"
echo "========================================"
ls -la "$WHEELHOUSE_DIR/netbsd/"
echo

echo "========================================"
printf "${GREEN}Wheel building complete!${NC}\n"
echo "========================================"
echo
echo "To use these wheels during installation, use:"
echo "  pip install --find-links=$WHEELHOUSE_DIR/netbsd -r requirements.txt"
echo
