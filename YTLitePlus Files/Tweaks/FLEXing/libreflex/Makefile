export ARCHS = arm64 arm64e
export TARGET = iphone:latest:13.0
include $(THEOS)/makefiles/common.mk

XCODEPROJ_NAME = Reflex

Reflex_XCODE_PROJECT = Reflex/Reflex.xcodeproj
Reflex_XCODE_SCHEME = libreflex

include $(THEOS_MAKE_PATH)/xcodeproj.mk

# include $(THEOS_MAKE_PATH)/tweak.mk

before-stage::
	find . -name ".DS_Store" -delete

# For printing variables from the makefile
print-%  : ; @echo $* = $($*)
