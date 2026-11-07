#!/bin/sh
# Builds a runtime from our Hadron fork with this Mac's signing setup and our graphics stack:
#
# - the Wine loader becomes Wine.app with the App ID that carries the cross-architecture capability,
#   signed with the Apple Development identity its Xcode-managed profile lists (build-wine.sh finds both);
# - KosmicKrisp from tools/kk-build (Mesa + fxgl/steamac v1.9.7 + patches/kk), the build MSFS 2024
#   reached the cockpit on;
# - vkd3d-proton and DXVK built for ARM64EC by tools/d3d-build (ARCH=arm64ec), from our forks;
# - SDL3 for winebus from tools/sdl-build (patches/sdl) in place of Homebrew's, for SDL=yes runtimes.
#
#   tools/hadron/build-runtime.sh [runtime id]    default: wine-11.21-highball (the simulator's since 11/7)
#
# Each input can be overridden from the environment (VKD3D_EC: the tools/d3d-build folder of vkd3d-proton's
# ARM64EC build, default vkd3d-ec); an empty HADRON_KOSMICKRISP or
# HADRON_ARM64EC_GRAPHICS leaves that part out, an empty HADRON_SDL3 takes Homebrew's SDL3.
set -eu
MSFS_SRC="${MSFS_SRC:-$HOME/GitHub/msfs-src}"
HADRON="${HADRON:-$HOME/GitHub/squark-app}"
export WINE_BUNDLE_ID="${WINE_BUNDLE_ID:-io.github.jason5545.hadron.wine}"
export HADRON_KOSMICKRISP="${HADRON_KOSMICKRISP-$MSFS_SRC/kk/stage-rel}"
VKD3D_EC="${VKD3D_EC:-$MSFS_SRC/d3d-build/vkd3d-ec}"
export HADRON_ARM64EC_GRAPHICS="${HADRON_ARM64EC_GRAPHICS-vkd3d:$VKD3D_EC/arm64ec:$HOME/GitHub/vkd3d-proton-steamac/LICENSE dxvk:$MSFS_SRC/d3d-build/dxvk-ec/arm64ec:$HOME/GitHub/dxvk-steamac/LICENSE}"
# FEX 0043's table also covers vkd3d-proton's d3d12core and d3d12: the unstripped DLLs of the same build
# (the check needs their symbols; strip keeps the TimeDateStamp and .text size FEX matches)
export HADRON_FPCR_SCAN_EXTRA="${HADRON_FPCR_SCAN_EXTRA-$VKD3D_EC/build/libs/d3d12core/d3d12core.dll $VKD3D_EC/build/libs/d3d12/d3d12.dll}"
export HADRON_SDL3="${HADRON_SDL3-$MSFS_SRC/sdl/stage/libSDL3.0.dylib}"
exec "$HADRON/runtime/build-wine.sh" "${1:-wine-11.21-highball}"
