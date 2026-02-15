# webzfs-wheels

Scripts to create Pre-built Wheels for WebZFS to make installation easier on the BSDs

Pre-Built Wheels will bein /Wheelhouse

Several Python packages in requirements.txt have native extensions that require compilation:

| Package | Language | Notes |
|---------|----------|-------|
| pydantic-core | Rust | Core validation library, requires Rust compiler |
| cryptography | Rust + C | Cryptographic library, requires Rust and OpenSSL |
| psutil | C | System monitoring, requires C compiler |
| markupsafe | C | String escaping for Jinja2, requires C compiler |

On Linux, PyPI provides pre-built wheels for these packages. However, BSD platforms (FreeBSD, NetBSD) typically need to compile from source because:

1. Different ABI (Application Binary Interface) from Linux
2. Different system libraries and paths
3. PyPI does not host pre-built wheels for BSD platforms

## Build Scripts

| Script | Platform | Output Directory |
|--------|----------|------------------|
| `build_wheels_freebsd14.sh` | FreeBSD 14.3 | `freebsd14/` |
| `build_wheels_freebsd15.sh` | FreeBSD 15.0 | `freebsd15/` |
| `build_wheels_netbsd.sh` | NetBSD | `netbsd/` |

## Building Wheels

Run the appropriate build script on the target platform as root:

```bash
# On FreeBSD 14.3
sudo sh build_wheels_freebsd14.sh

# On FreeBSD 15.0
sudo sh build_wheels_freebsd15.sh

# On NetBSD
sudo sh build_wheels_netbsd.sh
```

The scripts will:
1. Install required build dependencies (Rust, gmake, etc.)
2. Create a temporary virtual environment
3. Build wheels for each package
4. Place the wheels in the appropriate subdirectory

## Using Pre-built Wheels

To use the pre-built wheels during installation, use pip's `--find-links` option:

```bash
# FreeBSD 14.3
pip install --find-links=wheelhouse/freebsd14 -r requirements.txt

# FreeBSD 15.0
pip install --find-links=wheelhouse/freebsd15 -r requirements.txt

# NetBSD
pip install --find-links=wheelhouse/netbsd -r requirements.txt
```

Pip will automatically use the local wheels if they match the package version and platform, falling back to PyPI for packages without local wheels.

## Package Versions

The build scripts use the following package versions (matching requirements.txt):

- pydantic-core==2.41.5
- cryptography==44.0.0
- psutil==7.1.3
- markupsafe==3.0.3

If requirements.txt is updated, the version constants in the build scripts should also be updated.

## NetBSD Notes

The pkgsrc `rust` package on NetBSD has known issues (Bus error on execution). The NetBSD build script uses rustup to install a working Rust compiler instead. See `NETBSD_PYDANTIC_FIX.md` for more details.

## Wheel Naming Convention

Wheels are named using the standard Python wheel format:
```
{package}-{version}-{python}-{abi}-{platform}.whl
```

For example:
```
pydantic_core-2.41.5-cp311-cp311-freebsd_14_3_amd64.whl
```

## Troubleshooting

### Build fails with "Rust not found"
Ensure Rust is properly installed. On NetBSD, use rustup instead of pkgsrc:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
```

### Build fails with missing OpenSSL headers
Install OpenSSL development files:
```bash
# FreeBSD
pkg install openssl

# NetBSD
pkgin install openssl
```

### Wheel not used during installation
Verify the wheel matches:
1. The exact package version
2. The Python version (cp311 for Python 3.11)
3. The platform tag

Use `pip debug --verbose` to see which platforms pip will accept.
