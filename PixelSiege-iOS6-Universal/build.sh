#!/bin/bash
# build.sh — one-shot build for Pixel Siege.

set -e

if [ -z "$THEOS" ]; then
    echo "THEOS environment variable is not set."
    exit 1
fi

if [ ! -d "$THEOS/makefiles" ]; then
    echo "\$THEOS points at '$THEOS' but no makefiles/ folder was found there."
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
