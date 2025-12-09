ARCHS = arm64
ifeq ($(SIMULATOR),1)
	TARGET = simulator:clang:latest:15.0
else
	ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
		TARGET = iphone:clang:latest:15.0
	else ifeq ($(THEOS_PACKAGE_SCHEME),roothide)
		TARGET = iphone:clang:latest:15.0
	else
		TARGET = iphone:clang:latest:11.0
	endif
endif
INSTALL_TARGET_PROCESSES = YouTube

API_URL = "https://returnyoutubedislikeapi.com"
TWEAK_DISPLAY_NAME = "Return\ YouTube\ Dislike"

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YouTubeDislikesReturn
$(TWEAK_NAME)_FILES = Settings.x TweakSettings.x API.x Vote.x Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -DAPI_URL="\"${API_URL}\"" -DTWEAK_NAME="\"${TWEAK_DISPLAY_NAME}\""

include $(THEOS_MAKE_PATH)/tweak.mk

ifeq ($(SIMULATOR),1)
include ../../Simulator/preferenceloader-sim/locatesim.mk
setup:: clean all
	@rm -f /opt/simject/$(TWEAK_NAME).dylib
	@cp -v $(THEOS_OBJ_DIR)/$(TWEAK_NAME).dylib /opt/simject/$(TWEAK_NAME).dylib
	@cp -v $(PWD)/$(TWEAK_NAME).plist /opt/simject/$(TWEAK_NAME).plist
	@sudo mkdir -p "$(PL_SIMULATOR_APPLICATION_SUPPORT_PATH)"
	@sudo cp -vR "$(PWD)/layout/Library/Application Support/RYD.bundle" "$(PL_SIMULATOR_APPLICATION_SUPPORT_PATH)/"
endif
