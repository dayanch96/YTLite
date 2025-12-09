ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
	TARGET = iphone:clang:latest:15.0
else ifeq ($(THEOS_PACKAGE_SCHEME),roothide)
	TARGET = iphone:clang:latest:15.0
else
	TARGET = iphone:clang:latest:11.0
endif
INSTALL_TARGET_PROCESSES = YouTube
ARCHS = arm64
PACKAGE_VERSION = 1.9.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTABConfig

$(TWEAK_NAME)_FILES = Settings.x Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -DTWEAK_VERSION=$(PACKAGE_VERSION)
$(TWEAK_NAME)_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
