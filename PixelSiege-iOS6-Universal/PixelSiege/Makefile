ARCHS = armv7
TARGET = iphone:clang:6.0:6.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = RTSGame
RTSGame_FILES = main.m $(wildcard Classes/*.m)
RTSGame_RESOURCE_FILES = $(wildcard Resources/*.png) Resources/Info.plist
RTSGame_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore
RTSGame_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall -9 SpringBoard"
