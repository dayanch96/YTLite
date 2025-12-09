ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
	TARGET = iphone:clang:latest:15.0
else ifeq ($(THEOS_PACKAGE_SCHEME),roothide)
	TARGET = iphone:clang:latest:15.0
else
	TARGET = iphone:clang:latest:11.0
endif
ARCHS = arm64
INSTALL_TARGET_PROCESSES = YouTube

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTUHD
$(TWEAK_NAME)_FILES = Tweak.xm Settings.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc $(EXTRA_CFLAGS)
$(TWEAK_NAME)_FRAMEWORKS = VideoToolbox

# SUBPROJECTS = YTUHD-AVD

include $(THEOS_MAKE_PATH)/tweak.mk
# include $(THEOS_MAKE_PATH)/aggregate.mk
