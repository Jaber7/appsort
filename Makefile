include $(THEOS)/makefiles/common.mk

export ARCHS = arm64 arm64e
TARGET = iphone:clang:13.5:12.2

TWEAK_NAME = AppSort
AppSort_FILES = Tweak.x stats.xm
AppSort_FRAMEWORKS = Foundation UIKit CoreGraphics CoreImage QuartzCore
AppSort_LIBRARIES = activator lua5.3

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += appsort
include $(THEOS_MAKE_PATH)/aggregate.mk
