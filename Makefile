include $(THEOS)/makefiles/common.mk

export ARCHS = arm64 arm64e # no armv7 support as liblua5.3 (from sbingner) is not built for this arch.
TARGET = iphone:clang:13.5:12.2

GO_EASY_ON_ME = 1
FINALPACKAGE = 1

TWEAK_NAME = AppSort
AppSort_FILES = Tweak.x stats.xm
AppSort_FRAMEWORKS = Foundation UIKit CoreGraphics CoreImage QuartzCore
AppSort_LIBRARIES = activator lua5.3

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += appsort
include $(THEOS_MAKE_PATH)/aggregate.mk
