# webzfs-wheels

Scripts to create pre-built wheels for WebZFS to make installation easier on the BSDs.

Pre-built wheels live in `wheelhouse/`.

Several Python packages in `requirements.txt` have native extensions that require compilation:

| Package | Language | Notes |
|---------|----------|-------|
| pydantic-core | Rust | Core validation library, requires Rust compiler |
| cryptography | Rust + C | Cryptographic library, requires Rust and OpenSSL |
| bcrypt | Rust | Password hashing, requires Rust compiler |
| psutil | C | System monitoring, requires C compiler |
| markupsafe | C | String escaping for Jinja2, requires C compiler |
| cffi | C | Runtime dependency of pynacl, requires libffi |
| pynacl | C + libsodium | Runtime dependency of paramiko, requires libsodium |

On Linux, PyPI provides pre-built wheels for these packages. However, BSD platforms (FreeBSD, NetBSD) typically need to compile from source because:

1. Different ABI (Application Binary Interface) from Linux
2. Different system libraries and paths
3. PyPI does not host pre-built wheels for BSD platforms

## Build Scripts

| Script | Platform | Output Directory |
|--------|----------|------------------|
| `build_wheels_freebsd14-3.sh` | FreeBSD 14.3 | `wheelhouse/freebsd14-3/` |
| `build_wheels_freebsd14-4.sh` | FreeBSD 14.4 | `wheelhouse/freebsd14-4/` |
| `build_wheels_freebsd15-0.sh` | FreeBSD 15.0 | `wheelhouse/freebsd15-0/` |
| `build_wheels_freebsd15-1.sh` | FreeBSD 15.1 | `wheelhouse/freebsd15-1/` |
| `build_wheels_netbsd10-1.sh` | NetBSD 10.1 | `wheelhouse/netbsd10-1/` |

## Building Wheels

Run the appropriate build script on the target platform as root:

```bash
# On FreeBSD 14.3
sudo sh build_wheels_freebsd14-3.sh

# On FreeBSD 14.4
sudo sh build_wheels_freebsd14-4.sh

# On FreeBSD 15.0
sudo sh build_wheels_freebsd15-0.sh

# On FreeBSD 15.1
sudo sh build_wheels_freebsd15-1.sh

# On NetBSD 10.1
sudo sh build_wheels_netbsd10-1.sh
```

The scripts will:
1. Fetch the current `requirements.txt` from the main webzfs repo
2. Install required build dependencies (Rust, gmake, libffi, openssl, libsodium, etc.)
3. Create a temporary virtual environment
4. Build wheels for each native package at the versions pinned in `requirements.txt`
5. Place the wheels in the appropriate subdirectory

## Using Pre-built Wheels

To use the pre-built wheels during installation, use pip's `--find-links` option:

```bash
# FreeBSD 14.3
pip install --find-links=wheelhouse/freebsd14-3 -r requirements.txt

# FreeBSD 14.4
pip install --find-links=wheelhouse/freebsd14-4 -r requirements.txt

# FreeBSD 15.0
pip install --find-links=wheelhouse/freebsd15-0 -r requirements.txt

# FreeBSD 15.1
pip install --find-links=wheelhouse/freebsd15-1 -r requirements.txt

# NetBSD 10.1
pip install --find-links=wheelhouse/netbsd10-1 -r requirements.txt
```

Pip will automatically use the local wheels if they match the package version and platform, falling back to PyPI for packages without local wheels.

See [`wheelhouse/readme.md`](wheelhouse/readme.md) for the full list of pre-built wheels currently available.

## Package Versions

The build scripts resolve package versions dynamically from `requirements.txt`, so they always
build the versions currently pinned there. The native packages built are:

- pydantic-core
- cryptography
- bcrypt
- psutil
- markupsafe
- cffi
- pynacl

## NetBSD Notes

The pkgsrc `rust` package on NetBSD has known issues (Bus error on execution). The NetBSD build script uses rustup to install a working Rust compiler instead.

## Wheel Naming Convention

Wheels are named using the standard Python wheel format:
```
{package}-{version}-{python}-{abi}-{platform}.whl
```

For example:
```
pydantic_core-2.46.4-cp311-cp311-freebsd_15_1_release_p1_amd64.whl
```
