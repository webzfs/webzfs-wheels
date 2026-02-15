#!/bin/sh
#
# WebZFS Wheel Builder for FreeBSD 14.3
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
# Usage: Run this script on a FreeBSD 14.3 system to generate wheels.
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
echo "WebZFS Wheel Builder for FreeBSD 14.3"
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

# Install build dependencies
echo "Installing build dependencies..."
pkg install -y python${PYTHON_VERSION} py${PYTHON_VERSION}-pip rust gmake libffi openssl

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

# Build wheels
echo "========================================"
echo "Building wheels..."
echo "========================================"
echo

# pydantic-core
echo "Building pydantic-core==${PYDANTIC_CORE_VERSION}..."
pip wheel --no-deps --wheel-dir="$WHEELHOUSE_DIR/freebsd14" "pydantic-core==${PYDANTIC_CORE_VERSION}"
if [ $? -eq 0 ]; then
    printf "${GREEN}OK${NC} pydantic-core wheel built\n"
else
    printf "${RED}FAILED${NC} pydantic-core wheel build failed\n"
fi
echo

# cryptography
echo "Building cryptography==${CRYPTOGRAPHY_VERSION}..."
pip wheel --no-deps --wheel-dir="$WHEELHOUSE_DIR/freebsd14" "cryptography==${CRYPTOGRAPHY_VERSION}"
if [ $? -eq 0 ]; then
    printf "${GREEN}OK${NC} cryptography wheel built\n"
else
    printf "${RED}FAILED${NC} cryptography wheel build failed\n"
fi
echo

# psutil
echo "Building psutil==${PSUTIL_VERSION}..."
pip wheel --no-deps --wheel-dir="$WHEELHOUSE_DIR/freebsd14" "psutil==${PSUTIL_VERSION}"
if [ $? -eq 0 ]; then
    printf "${GREEN}OK${NC} psutil wheel built\n"
else
    printf "${RED}FAILED${NC} psutil wheel build failed\n"
fi
echo

# markupsafe
echo "Building markupsafe==${MARKUPSAFE_VERSION}..."
pip wheel --no-deps --wheel-dir="$WHEELHOUSE_DIR/freebsd14" "markupsafe==${MARKUPSAFE_VERSION}"
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
echo "Wheels built for FreeBSD 14.3:"
echo "========================================"
ls -la "$WHEELHOUSE_DIR/freebsd14/"
echo

echo "========================================"
printf "${GREEN}Wheel building complete!${NC}\n"
echo "========================================"
echo
echo "To use these wheels during installation, use:"
echo "  pip install --find-links=$WHEELHOUSE_DIR/freebsd14 -r requirements.txt"
echo
