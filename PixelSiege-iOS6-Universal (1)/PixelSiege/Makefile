# Pixel Siege — Theos Makefile
# Run on a machine with Theos installed: https://theos.dev
#
#   export THEOS=/path/to/theos     (if not already set)
#   make package                    (or just run ./build.sh)
#
# TARGET below asks for an iOS 6.0 SDK. If your Theos toolchain only has a
# newer SDK, that's fine too — Theos will still produce an armv7 binary
# whose deployment target is 6.0, which is what actually matters for
# running on an iOS 6 device.

ARCHS = armv7
TARGET = iphone:clang:6.0:6.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = RTSGame

RTSGame_FILES = main.m $(wildcard Classes/*.m)
RTSGame_RESOURCE_FILES = $(wildcard Resources/*.png)
RTSGame_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore
RTSGame_CFLAGS = -fobjc-arc -Wno-unused-variable

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall -9 SpringBoard"
