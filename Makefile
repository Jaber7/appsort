include $(THEOS)/makefiles/common.mk
export ARCHS = arm64 arm64e
export SDKVERSION = 13.1
TARGET = iphone:clang:13.1

TWEAK_NAME = AppSort
AppSort_FILES = Tweak.x stats.xm
AppSort_FRAMEWORKS = Foundation UIKit CoreGraphics CoreImage QuartzCore
AppSort_LIBRARIES = activator 
AppSort_OBJ_FILES = liblua/libliblua.a
ADDITIONAL_OBJCFLAGS = -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += appsort
include $(THEOS_MAKE_PATH)/aggregate.mk
