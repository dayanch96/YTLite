ifeq ($(ROOTLESS),1)
THEOS_PACKAGE_SCHEME=rootless
endif

export ARCHS = arm64
TARGET := iphone:clang:16.5:13.0
INSTALL_TARGET_PROCESSES = YouTube

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = iSponsorBlock

iSponsorBlock_FILES = iSponsorBlock.xm $(wildcard *.m)
iSponsorBlock_LIBRARIES = colorpicker
iSponsorBlock_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-module-import-in-extern-c -Wno-unknown-warning-option -Wno-vla-cxx-extension -Wno-vla-extension

include $(THEOS_MAKE_PATH)/tweak.mk
