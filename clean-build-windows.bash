#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if command -v pwsh >/dev/null 2>&1
then
    exec pwsh -NoProfile -File "${repo_root}/clean-build-windows.ps1" "$@"
fi

cat >&2 <<'EOF'
clean-build-windows.bash now builds with MSVC (Visual Studio 2022), not MSYS2/MinGW.

On Windows, run from a Developer PowerShell or x64 Native Tools prompt:
  pwsh -File clean-build-windows.ps1

Set CSOUND_ROOT (or CSOUND_INSTALL_PREFIX) to an MSVC-built Csound 7 install first.
EOF
exit 1
