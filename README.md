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

All wheels are built with CPython 3.12 (`cp312`), the WebZFS Python target on
every supported platform.

| Script | Platform | Output Directory |
|--------|----------|------------------|
| `build_wheels_freebsd14-4.sh` | FreeBSD 14.4 | `wheelhouse/freebsd14-4/` |
| `build_wheels_freebsd14-5.sh` | FreeBSD 14.5 | `wheelhouse/freebsd14-5/` |
| `build_wheels_freebsd15-1.sh` | FreeBSD 15.1 | `wheelhouse/freebsd15-1/` |
| `build_wheels_netbsd10-1.sh` | NetBSD 10.1 | `wheelhouse/netbsd10-1/` |
| `build_wheels_netbsd11-0.sh` | NetBSD 11.0 | `wheelhouse/netbsd11-0/` |

## End-of-Life Releases

FreeBSD 14.3 and FreeBSD 15.0 are end-of-life and no longer receive new
wheels. Their build scripts were moved to `EOL/` for reference and are not
maintained. The existing wheels in `wheelhouse/freebsd14-3/` and
`wheelhouse/freebsd15-0/` remain available but stop at the versions that
were current when each release reached end-of-life (cryptography 49.0.0,
Python 3.11 only).

| Release | Status | WebZFS installer behavior |
|---------|--------|---------------------------|
| FreeBSD 14.3 | EOL | Uses the `freebsd14-4` wheels and prints a warning |
| FreeBSD 15.0 | EOL | Uses the `freebsd15-1` wheels and prints a warning |

Upgrading to a supported release is recommended. The FreeBSD 15.0 build of
cryptography 50.0.2 could not be produced: the `cargo` package in the
current FreeBSD 15 package repository requires a newer libc
(`FBSD_1.9`) than FreeBSD 15.0 provides.

## Building Wheels

Run the appropriate build script on the target platform as root:

```bash
# On FreeBSD 14.4
sudo sh build_wheels_freebsd14-4.sh

# On FreeBSD 14.5
sudo sh build_wheels_freebsd14-5.sh

# On FreeBSD 15.1
sudo sh build_wheels_freebsd15-1.sh

# On NetBSD 10.1
sudo sh build_wheels_netbsd10-1.sh

# On NetBSD 11.0
sudo sh build_wheels_netbsd11-0.sh
```

The scripts will:
1. Fetch the current `requirements.txt` from the main webzfs repo
2. Install required build dependencies (Rust, gmake, libffi, openssl, libsodium, etc.)
3. Create a temporary virtual environment
4. Build wheels for each native package at the versions pinned in `requirements.txt`
5. Place the wheels in the appropriate subdirectory

### Building From a Branch Other Than main

By default the scripts read `requirements.txt` from the `main` branch. To
build wheels for dependency updates before they are merged, set
`WEBZFS_BRANCH` to the pushed branch name:

```sh
sudo env WEBZFS_BRANCH=0.85.4 sh build_wheels_freebsd15-1.sh
```

Use `sudo env VAR=value` rather than `VAR=value sudo`, because `sudo` drops
most environment variables by default.

## Using Pre-built Wheels

To use the pre-built wheels during installation, use pip's `--find-links` option:

```bash
# FreeBSD 14.4
pip install --find-links=wheelhouse/freebsd14-4 -r requirements.txt

# FreeBSD 14.5
pip install --find-links=wheelhouse/freebsd14-5 -r requirements.txt

# FreeBSD 15.1
pip install --find-links=wheelhouse/freebsd15-1 -r requirements.txt

# NetBSD 10.1
pip install --find-links=wheelhouse/netbsd10-1 -r requirements.txt

# NetBSD 11.0
pip install --find-links=wheelhouse/netbsd11-0 -r requirements.txt
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
pydantic_core-2.46.4-cp312-cp312-freebsd_15_1_release_p1_amd64.whl
cryptography-50.0.2-cp312-abi3-freebsd_15_1_release_p1_amd64.whl
```

cryptography uses the stable ABI, so its tag is `cp312-abi3` rather than
`cp312-cp312`. The platform tag includes the FreeBSD patch level of the
build system (for example `release_p1` or `release_p2`). The WebZFS
installers request exact filenames, so `WHEEL_PLATFORM` in
`install_freebsd.sh` and `update_freebsd.sh` must match the tag of the
published wheels for each release.
