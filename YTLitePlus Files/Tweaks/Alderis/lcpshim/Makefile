include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = libcolorpicker

libcolorpicker_FILES = $(wildcard *.m)
libcolorpicker_PRIVATE_FRAMEWORKS = Preferences
libcolorpicker_INSTALL_PATH = $(THEOS_PACKAGE_INSTALL_PREFIX)/usr/lib
libcolorpicker_LDFLAGS = -install_name @rpath/libcolorpicker.dylib

include $(THEOS_MAKE_PATH)/library.mk
