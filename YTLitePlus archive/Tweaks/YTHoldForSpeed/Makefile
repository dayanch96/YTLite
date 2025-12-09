TARGET := iphone:clang:17.5:15.0
INSTALL_TARGET_PROCESSES = YouTube

PACKAGE_VERSION=$(THEOS_PACKAGE_BASE_VERSION)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTHoldForSpeed
$(TWEAK_NAME)_FILES = YTHFSTweak.x YTHFSSettings.x YTHFSPrefsManager.m
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
