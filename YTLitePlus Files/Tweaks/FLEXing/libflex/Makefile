ifeq ($(SIMULATOR),1)
	export ARCHS = arm64 x86_64
	export TARGET = simulator:clang::15.0
else
	export THEOS_PACKAGE_SCHEME = rootless
	export ARCHS = arm64 arm64e
	export TARGET = iphone:latest:15.0
endif
include $(THEOS)/makefiles/common.mk

# FULL PATH of the FLEX repo on your own machine
FLEX_ROOT = FLEX

# Function to convert /foo/bar to -I/foo/bar
dtoim = $(foreach d,$(1),-I$(d))

# Gather FLEX sources
SOURCES  = $(shell find $(FLEX_ROOT)/Classes -name '*.c')
SOURCES += $(shell find $(FLEX_ROOT)/Classes -name '*.m')
SOURCES += $(shell find $(FLEX_ROOT)/Classes -name '*.mm')
# Gather FLEX headers for search paths
_IMPORTS  = $(shell /bin/ls -d $(FLEX_ROOT)/Classes/*/)
_IMPORTS += $(shell /bin/ls -d $(FLEX_ROOT)/Classes/*/*/)
_IMPORTS += $(shell /bin/ls -d $(FLEX_ROOT)/Classes/*/*/*/)
_IMPORTS += $(shell /bin/ls -d $(FLEX_ROOT)/Classes/*/*/*/*/)
IMPORTS = -I$(FLEX_ROOT)/Classes/ $(call dtoim, $(_IMPORTS))

TWEAK_NAME = libFLEX
$(TWEAK_NAME)_FILES = libFLEX.x $(SOURCES)
$(TWEAK_NAME)_FRAMEWORKS = CoreGraphics UIKit ImageIO QuartzCore
$(TWEAK_NAME)_LIBRARIES = sqlite3 z
$(TWEAK_NAME)_CFLAGS += -fobjc-arc -w -Wno-unsupported-availability-guard $(IMPORTS) -g
$(TWEAK_NAME)_CCFLAGS += -std=gnu++11

include $(THEOS_MAKE_PATH)/tweak.mk

before-stage::
	find . -name ".DS_Store" -delete

# For printing variables from the makefile
print-%  : ; @echo $* = $($*)
