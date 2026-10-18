# Pre-compiled Wheels Available

Current WebZFS pins: cryptography 50.0.2, markupsafe 3.0.3, psutil 7.2.2,
pydantic-core 2.46.4, bcrypt 5.0.0, cffi 2.1.0, pynacl 1.6.2. All current
wheels target CPython 3.12 (`cp312`).

| Directory | Status | Current wheel set |
|-----------|--------|-------------------|
| `freebsd14-3` | EOL | No (cp311 only, ends at cryptography 49.0.0) |
| `freebsd14-4` | Supported | Yes (`freebsd_14_4_release_p1_amd64`) |
| `freebsd14-5` | Supported | Yes (`freebsd_14_5_release_p2_amd64`) |
| `freebsd15-0` | EOL | No (cp311 only, ends at cryptography 49.0.0) |
| `freebsd15-1` | Supported | Yes (`freebsd_15_1_release_p1_amd64`) |
| `netbsd10-1` | Supported | Partial (bcrypt, cffi, pynacl pending rebuild) |
| `netbsd11-0` | Supported | Yes (`netbsd_11_0_amd64`) |

Older cp311 wheels are kept for existing installations that have not yet
moved to Python 3.12.

```
├── freebsd14-3 (EOL)
│   ├── bcrypt-4.3.0-cp311-cp311-freebsd_14_3_release_amd64.whl
│   ├── bcrypt-5.0.0-cp311-cp311-freebsd_14_3_release_amd64.whl
│   ├── cffi-1.17.1-cp311-cp311-freebsd_14_3_release_amd64.whl
│   ├── cffi-2.1.0-cp311-cp311-freebsd_14_3_release_amd64.whl
│   ├── cryptography-44.0.0-cp37-abi3-freebsd_14_3_release_amd64.whl
│   ├── cryptography-48.0.1-cp311-abi3-freebsd_14_3_release_amd64.whl
│   ├── cryptography-49.0.0-cp311-abi3-freebsd_14_3_release_amd64.whl
│   ├── markupsafe-3.0.3-cp311-cp311-freebsd_14_3_release_amd64.whl
│   ├── psutil-7.1.3-cp311-cp311-freebsd_14_3_release_amd64.whl
│   ├── psutil-7.2.2-cp311-cp311-freebsd_14_3_release_amd64.whl
│   ├── pydantic_core-2.41.5-cp311-cp311-freebsd_14_3_release_amd64.whl
│   ├── pydantic_core-2.46.4-cp311-cp311-freebsd_14_3_release_amd64.whl
│   ├── pynacl-1.5.0-cp311-cp311-freebsd_14_3_release_amd64.whl
│   └── pynacl-1.6.2-cp311-cp311-freebsd_14_3_release_amd64.whl
├── freebsd14-4
│   ├── bcrypt-4.3.0-cp311-cp311-freebsd_14_4_release_amd64.whl
│   ├── bcrypt-4.3.0-cp311-cp311-freebsd_14_4_release_p1_amd64.whl
│   ├── bcrypt-5.0.0-cp311-cp311-freebsd_14_4_release_p1_amd64.whl
│   ├── bcrypt-5.0.0-cp312-cp312-freebsd_14_4_release_p1_amd64.whl
│   ├── cffi-1.17.1-cp311-cp311-freebsd_14_4_release_amd64.whl
│   ├── cffi-1.17.1-cp311-cp311-freebsd_14_4_release_p1_amd64.whl
│   ├── cffi-2.1.0-cp311-cp311-freebsd_14_4_release_p1_amd64.whl
│   ├── cffi-2.1.0-cp312-cp312-freebsd_14_4_release_p1_amd64.whl
│   ├── cryptography-44.0.0-cp37-abi3-freebsd_14_4_release_amd64.whl
│   ├── cryptography-44.0.0-cp37-abi3-freebsd_14_4_release_p1_amd64.whl
│   ├── cryptography-48.0.1-cp311-abi3-freebsd_14_4_release_p1_amd64.whl
│   ├── cryptography-49.0.0-cp311-abi3-freebsd_14_4_release_p1_amd64.whl
│   ├── cryptography-49.0.0-cp312-abi3-freebsd_14_4_release_p1_amd64.whl
│   ├── cryptography-50.0.2-cp312-abi3-freebsd_14_4_release_p1_amd64.whl
│   ├── markupsafe-3.0.3-cp311-cp311-freebsd_14_4_release_amd64.whl
│   ├── markupsafe-3.0.3-cp311-cp311-freebsd_14_4_release_p1_amd64.whl
│   ├── markupsafe-3.0.3-cp312-cp312-freebsd_14_4_release_p1_amd64.whl
│   ├── psutil-7.1.3-cp311-cp311-freebsd_14_4_release_amd64.whl
│   ├── psutil-7.1.3-cp311-cp311-freebsd_14_4_release_p1_amd64.whl
│   ├── psutil-7.2.2-cp311-cp311-freebsd_14_4_release_p1_amd64.whl
│   ├── psutil-7.2.2-cp312-cp312-freebsd_14_4_release_p1_amd64.whl
│   ├── pydantic_core-2.41.5-cp311-cp311-freebsd_14_4_release_amd64.whl
│   ├── pydantic_core-2.41.5-cp311-cp311-freebsd_14_4_release_p1_amd64.whl
│   ├── pydantic_core-2.46.4-cp311-cp311-freebsd_14_4_release_p1_amd64.whl
│   ├── pydantic_core-2.46.4-cp312-cp312-freebsd_14_4_release_p1_amd64.whl
│   ├── pynacl-1.5.0-cp311-cp311-freebsd_14_4_release_amd64.whl
│   ├── pynacl-1.5.0-cp311-cp311-freebsd_14_4_release_p1_amd64.whl
│   ├── pynacl-1.6.2-cp311-cp311-freebsd_14_4_release_p1_amd64.whl
│   └── pynacl-1.6.2-cp312-cp312-freebsd_14_4_release_p1_amd64.whl
├── freebsd14-5
│   ├── bcrypt-5.0.0-cp312-cp312-freebsd_14_5_release_p2_amd64.whl
│   ├── cffi-2.1.0-cp312-cp312-freebsd_14_5_release_p2_amd64.whl
│   ├── cryptography-50.0.2-cp312-abi3-freebsd_14_5_release_p2_amd64.whl
│   ├── markupsafe-3.0.3-cp312-cp312-freebsd_14_5_release_p2_amd64.whl
│   ├── psutil-7.2.2-cp312-cp312-freebsd_14_5_release_p2_amd64.whl
│   ├── pydantic_core-2.46.4-cp312-cp312-freebsd_14_5_release_p2_amd64.whl
│   └── pynacl-1.6.2-cp312-cp312-freebsd_14_5_release_p2_amd64.whl
├── freebsd15-0 (EOL)
│   ├── bcrypt-4.3.0-cp311-cp311-freebsd_15_0_release_amd64.whl
│   ├── bcrypt-5.0.0-cp311-cp311-freebsd_15_0_release_amd64.whl
│   ├── cffi-1.17.1-cp311-cp311-freebsd_15_0_release_amd64.whl
│   ├── cffi-2.1.0-cp311-cp311-freebsd_15_0_release_amd64.whl
│   ├── cryptography-44.0.0-cp37-abi3-freebsd_15_0_release_amd64.whl
│   ├── cryptography-48.0.1-cp311-abi3-freebsd_15_0_release_amd64.whl
│   ├── cryptography-49.0.0-cp311-abi3-freebsd_15_0_release_amd64.whl
│   ├── markupsafe-3.0.3-cp311-cp311-freebsd_15_0_release_amd64.whl
│   ├── psutil-7.1.3-cp311-cp311-freebsd_15_0_release_amd64.whl
│   ├── psutil-7.2.2-cp311-cp311-freebsd_15_0_release_amd64.whl
│   ├── pydantic_core-2.41.5-cp311-cp311-freebsd_15_0_release_amd64.whl
│   ├── pydantic_core-2.46.4-cp311-cp311-freebsd_15_0_release_amd64.whl
│   ├── pynacl-1.5.0-cp311-cp311-freebsd_15_0_release_amd64.whl
│   └── pynacl-1.6.2-cp311-cp311-freebsd_15_0_release_amd64.whl
├── freebsd15-1
│   ├── bcrypt-5.0.0-cp311-cp311-freebsd_15_1_release_p1_amd64.whl
│   ├── bcrypt-5.0.0-cp312-cp312-freebsd_15_1_release_p1_amd64.whl
│   ├── cffi-2.1.0-cp311-cp311-freebsd_15_1_release_p1_amd64.whl
│   ├── cffi-2.1.0-cp312-cp312-freebsd_15_1_release_p1_amd64.whl
│   ├── cryptography-48.0.1-cp311-abi3-freebsd_15_1_release_p1_amd64.whl
│   ├── cryptography-49.0.0-cp311-abi3-freebsd_15_1_release_p1_amd64.whl
│   ├── cryptography-49.0.0-cp312-abi3-freebsd_15_1_release_p1_amd64.whl
│   ├── cryptography-50.0.2-cp312-abi3-freebsd_15_1_release_p1_amd64.whl
│   ├── markupsafe-3.0.3-cp311-cp311-freebsd_15_1_release_p1_amd64.whl
│   ├── markupsafe-3.0.3-cp312-cp312-freebsd_15_1_release_p1_amd64.whl
│   ├── psutil-7.2.2-cp311-cp311-freebsd_15_1_release_p1_amd64.whl
│   ├── psutil-7.2.2-cp312-cp312-freebsd_15_1_release_p1_amd64.whl
│   ├── pydantic_core-2.46.4-cp311-cp311-freebsd_15_1_release_p1_amd64.whl
│   ├── pydantic_core-2.46.4-cp312-cp312-freebsd_15_1_release_p1_amd64.whl
│   ├── pynacl-1.6.2-cp311-cp311-freebsd_15_1_release_p1_amd64.whl
│   └── pynacl-1.6.2-cp312-cp312-freebsd_15_1_release_p1_amd64.whl
├── netbsd10-1
│   ├── cryptography-44.0.0-cp37-abi3-netbsd_10_1_amd64.whl
│   ├── cryptography-48.0.1-cp311-abi3-netbsd_10_1_amd64.whl
│   ├── cryptography-49.0.0-cp311-abi3-netbsd_10_1_amd64.whl
│   ├── cryptography-50.0.2-cp311-abi3-netbsd_10_1_amd64.whl
│   ├── cryptography-50.0.2-cp312-abi3-netbsd_10_1_amd64.whl
│   ├── markupsafe-3.0.3-cp311-cp311-netbsd_10_1_amd64.whl
│   ├── markupsafe-3.0.3-cp312-cp312-netbsd_10_1_amd64.whl
│   ├── psutil-7.1.3-cp311-cp311-netbsd_10_1_amd64.whl
│   ├── psutil-7.2.2-cp311-cp311-netbsd_10_1_amd64.whl
│   ├── psutil-7.2.2-cp312-cp312-netbsd_10_1_amd64.whl
│   ├── pydantic_core-2.41.5-cp311-cp311-netbsd_10_1_amd64.whl
│   ├── pydantic_core-2.46.4-cp311-cp311-netbsd_10_1_amd64.whl
│   └── pydantic_core-2.46.4-cp312-cp312-netbsd_10_1_amd64.whl
└── netbsd11-0
    ├── bcrypt-5.0.0-cp312-cp312-netbsd_11_0_amd64.whl
    ├── cffi-2.1.0-cp312-cp312-netbsd_11_0_amd64.whl
    ├── cryptography-49.0.0-cp312-abi3-netbsd_11_0_amd64.whl
    ├── cryptography-50.0.2-cp312-abi3-netbsd_11_0_amd64.whl
    ├── markupsafe-3.0.3-cp312-cp312-netbsd_11_0_amd64.whl
    ├── psutil-7.2.2-cp312-cp312-netbsd_11_0_amd64.whl
    ├── pydantic_core-2.46.4-cp312-cp312-netbsd_11_0_amd64.whl
    └── pynacl-1.6.2-cp312-cp312-netbsd_11_0_amd64.whl
```
