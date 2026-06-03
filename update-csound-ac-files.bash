#!/usr/bin/env bash
set -euo pipefail

# Refresh shared files from the csound-ac repository (single source of truth).
# Prefer a local csound-ac checkout; otherwise download from GitHub master.

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
csound_ac_base_url="${CSOUND_AC_BASE_URL:-https://raw.githubusercontent.com/gogins-dev/csound-ac/refs/heads/master}"

csound_ac_root="${CSOUND_AC_ROOT:-}"
if [[ -z "${csound_ac_root}" && -f "${repo_root}/../csound-ac/cmake/FindCsoundHomeFirst.cmake" ]]; then
    csound_ac_root="$(cd "${repo_root}/../csound-ac" && pwd)"
fi

mkdir -p "${repo_root}/vst3-opcodes/cmake"

if [[ -n "${csound_ac_root}" ]]; then
    echo "Refreshing from local csound-ac: ${csound_ac_root}"
    cp "${csound_ac_root}/cmake/FindCsoundHomeFirst.cmake" \
        "${repo_root}/vst3-opcodes/cmake/FindCsoundHomeFirst.cmake"
    cp "${csound_ac_root}/CsoundAC/OpcodeBaseAC.hpp" \
        "${repo_root}/vst3-opcodes/OpcodeBaseAC.hpp"
    if [[ -f "${csound_ac_root}/external/codesign-check.bash" ]]; then
        cp "${csound_ac_root}/external/codesign-check.bash" \
            "${repo_root}/codesign-check.bash"
        chmod +x "${repo_root}/codesign-check.bash"
    fi
else
    echo "Downloading from ${csound_ac_base_url}"
    curl -fsSL "${csound_ac_base_url}/cmake/FindCsoundHomeFirst.cmake" \
        -o "${repo_root}/vst3-opcodes/cmake/FindCsoundHomeFirst.cmake"
    curl -fsSL "${csound_ac_base_url}/CsoundAC/OpcodeBaseAC.hpp" \
        -o "${repo_root}/vst3-opcodes/OpcodeBaseAC.hpp"
    curl -fsSL "${csound_ac_base_url}/external/codesign-check.bash" \
        -o "${repo_root}/codesign-check.bash" || true
    chmod +x "${repo_root}/codesign-check.bash" 2>/dev/null || true
fi

echo "Updated FindCsoundHomeFirst.cmake and OpcodeBaseAC.hpp."
