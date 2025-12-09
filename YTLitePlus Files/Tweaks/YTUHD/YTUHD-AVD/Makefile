TARGET := iphone:clang:latest:14.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTUHD-AVD
$(TWEAK_NAME)_FILES = AVD.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = IOKit

include $(THEOS_MAKE_PATH)/tweak.mk
