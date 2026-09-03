# Pixel Siege — a simple RTS for iOS 6 (iPhone + iPad)

A small real-time strategy game for jailbroken iOS 6 devices, built for
Theos/Cydia. Universal binary — the layout adapts to iPhone and iPad,
portrait or landscape. Train swordsmen and archers, gather gold, and take
down the enemy keep before yours falls.

## Why this is a project, not a finished .deb

I don't have Xcode, the iOS SDK, or network access in the sandbox I build
in, so I can't cross-compile the ARMv7 binary myself. `dpkg-deb` (which
*is* available to me) only wraps an already-compiled app into the `.deb`
archive format — it doesn't compile Objective-C. The actual compiler +
iOS SDK step has to happen on a machine with Theos installed.

Everything up to that point is done: full source, all art, a home-screen
icon at every required size, and a `build.sh` that runs the whole
compile → sign → package sequence in one command.

## What's in here

- `Classes/` — Objective-C source, ARC, targets iOS 6.0+
- `Resources/` — tile textures, troop sprites, keep sprites, and the
  home screen icon (57/114 for iPhone, 72/144 for iPad)
- `Resources/Info.plist` — universal app metadata (`UIDeviceFamily: 1,2`)
- `Makefile` — Theos build script
- `control` — Cydia package metadata
- `build.sh` — one-command build helper (see below)
- `generate_assets.py` — regenerates everything in `Resources/`; edit
  colors/shapes and rerun to re-theme
- `icon_master_preview.png` — the 256x256 source the icon was scaled
  down from, just for previewing

## Building the real .deb

On a machine with Theos installed and `$THEOS` set:

```
chmod +x build.sh
./build.sh
```

This runs `make package`, then copies the finished `.deb` into `dist/`.
If you'd rather run the steps yourself, `make package` alone does the
same compile/sign/package work and drops the `.deb` in `packages/`.

If `make` complains about Makefile syntax (Theos has renamed a few
variables across versions over the years), the safest fix is:
`$THEOS/bin/nic.pl` → pick the "iphone/application" template → copy this
repo's `Classes/`, `Resources/`, and `control` into that fresh scaffold,
which is guaranteed to match your installed Theos version.

I wrote this carefully against the iOS 6-era UIKit APIs specifically
(pre-iOS 7 text drawing, pre-iOS 7 status bar handling, the
`supportedInterfaceOrientations` rotation model iOS 6 introduced, etc.),
but since I can't compile it myself I can't guarantee a clean first
build — if you do hit an error, it's far more likely one of the Makefile
quirks above than a logic bug in the game code.

## Adding it to your repo

```
cp dist/*.deb /path/to/your/repo/debs/
cd /path/to/your/repo
dpkg-scanpackages -m . /dev/null | gzip -9 > Packages.gz
apt-ftparchive release . > Release
```

## How to play

- Bottom-left button trains a **Swordsman** (10 gold, melee, tanky).
  Bottom-right trains an **Archer** (15 gold, ranged, fragile).
- Tap a troop to select it (yellow ring), then tap a tile to send it there.
- Gold trickles in automatically, plus a bonus while a troop stands on a
  gold tile (the sparkly brown ones).
- The enemy (red, top-right keep) spawns and attacks on its own timer.
- Destroy the enemy keep to win; if yours falls, you lose.

## Easy tweaks

- Map size/layout: `Classes/GameMap.m`
- Troop stats: `Classes/Troop.m`
- Enemy spawn rate: `updateEnemyAI:` in `Classes/GameView.m`
- Art: edit `generate_assets.py`, rerun with `python3 generate_assets.py`
  (needs Pillow: `pip install pillow`)
- Bundle ID: currently `com.johndoe.pixelsiege` in both `control` and
  `Resources/Info.plist` — change both to match your own namespace
