ifeq ($(ROOTLESS),1)
THEOS_PACKAGE_SCHEME=rootless
endif

DEBUG=0
FINALPACKAGE=1
ARCHS = arm64
PACKAGE_VERSION = 3.0
TARGET := iphone:clang:latest:13.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTLite
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation SystemConfiguration
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -DTWEAK_VERSION=$(PACKAGE_VERSION)
$(TWEAK_NAME)_FILES = $(wildcard *.x Utils/*.m)

include $(THEOS_MAKE_PATH)/tweak.mk
