#!/bin/bash
# build.sh — one-shot build for Pixel Siege.
# Run this on a machine with Theos installed (macOS or Linux) and $THEOS set.
#
# What it does:
#   1. Sanity-checks that Theos is findable.
#   2. Runs `make package` to compile + bundle + sign + wrap into a .deb.
#   3. Copies the finished .deb into ./dist/ and prints its path.
#
# Usage:
#   chmod +x build.sh
#   ./build.sh

set -e

if [ -z "$THEOS" ]; then
    echo "THEOS environment variable is not set."
    echo "Install Theos (https://theos.dev) first, then: export THEOS=/path/to/theos"
    exit 1
fi

if [ ! -d "$THEOS/makefiles" ]; then
    echo "\$THEOS points at '$THEOS' but no makefiles/ folder was found there."
    echo "Double check your Theos install."
    exit 1
fi

echo "Using Theos at: $THEOS"
echo "Building Pixel Siege..."

make package FINALPACKAGE=1

mkdir -p dist
DEB_FILE=$(ls -t packages/*.deb 2>/dev/null | head -n 1)

if [ -z "$DEB_FILE" ]; then
    echo "Build finished but no .deb was found in packages/ — check the make output above for errors."
    exit 1
fi

cp "$DEB_FILE" dist/
echo ""
echo "Done. Your installable package is at:"
echo "  dist/$(basename "$DEB_FILE")"
echo ""
echo "Copy it into your repo's debs folder, then re-index, e.g.:"
echo "  dpkg-scanpackages -m . /dev/null | gzip -9 > Packages.gz"
