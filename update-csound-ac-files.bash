#!/usr/bin/env bash
set -euo pipefail

# Refresh FindCsoundHomeFirst.cmake and OpcodeBaseAC.hpp from csound-ac master on GitHub.
# Vendored copies under vst3-opcodes/ are committed as offline fallbacks; CMake also
# downloads and replaces them on configure and before each build.

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
csound_ac_base_url="${CSOUND_AC_BASE_URL:-https://raw.githubusercontent.com/gogins-dev/csound-ac/refs/heads/master}"

mkdir -p "${repo_root}/vst3-opcodes/cmake"

echo "Downloading from ${csound_ac_base_url}"
curl -fsSL "${csound_ac_base_url}/cmake/FindCsoundHomeFirst.cmake" \
    -o "${repo_root}/vst3-opcodes/cmake/FindCsoundHomeFirst.cmake"
curl -fsSL "${csound_ac_base_url}/CsoundAC/OpcodeBaseAC.hpp" \
    -o "${repo_root}/vst3-opcodes/OpcodeBaseAC.hpp"

echo "Updated FindCsoundHomeFirst.cmake and OpcodeBaseAC.hpp."
