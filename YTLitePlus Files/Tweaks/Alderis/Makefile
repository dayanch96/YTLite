ifeq ($(ROOTLESS),1)
	export THEOS_PACKAGE_SCHEME = rootless
	export TARGET = iphone:latest:15.0
else ifeq ($(BUILD_LEGACY_ARM64E),1)
	export TARGET = iphone:13.7:12.0
else
	export TARGET = iphone:latest:12.0
endif

FRAMEWORK_OUTPUT_DIR = $(THEOS_OBJ_DIR)/install$(THEOS_PACKAGE_INSTALL_PREFIX)/Library/Frameworks
ALDERIS_SDK_DIR = $(THEOS_OBJ_DIR)/alderis_sdk_$(THEOS_PACKAGE_BASE_VERSION)

export ADDITIONAL_CFLAGS = -fobjc-arc \
	-Wextra -Wno-unused-parameter \
	-F$(FRAMEWORK_OUTPUT_DIR)
export ADDITIONAL_LDFLAGS = -F$(FRAMEWORK_OUTPUT_DIR)

INSTALL_TARGET_PROCESSES = Preferences

include $(THEOS)/makefiles/common.mk

XCODEPROJ_NAME = Alderis

Alderis_XCODEFLAGS = \
	DYLIB_INSTALL_NAME_BASE=@rpath \
	BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
	LOCAL_LIBRARY_DIR="$(THEOS_PACKAGE_INSTALL_PREFIX)/Library" \
	ARCHS="$(ARCHS)"

SUBPROJECTS = lcpshim

include $(THEOS_MAKE_PATH)/xcodeproj.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-Alderis-all::
ifeq ($(ROOTLESS),1)
	@rm -f $(FRAMEWORK_OUTPUT_DIR)/Alderis.framework/Assets.car
	@ldid -S $(FRAMEWORK_OUTPUT_DIR)/Alderis.framework
endif

internal-stage::
ifneq ($(ROOTLESS),1)
	@mkdir -p $(THEOS_STAGING_DIR)/DEBIAN
	@cp postinst $(THEOS_STAGING_DIR)/DEBIAN
endif

internal-package::
ifeq ($(ROOTLESS),1)
	@grep -v Depends: $(THEOS_STAGING_DIR)/DEBIAN/control > tmp
	@mv tmp $(THEOS_STAGING_DIR)/DEBIAN/control
endif

docs:
	@$(PRINT_FORMAT_MAKING) "Generating docs"
	jazzy --module-version $(THEOS_PACKAGE_BASE_VERSION)
	rm -rf docs/screenshots/ docs/docsets/Alderis.docset/Contents/Resources/Documents/screenshots/
	cp -r screenshots/ docs/screenshots/
	cp -r screenshots/ docs/docsets/Alderis.docset/Contents/Resources/Documents/screenshots/
	rm -rf build docs/undocumented.json

sdk: stage
	@$(PRINT_FORMAT_MAKING) "Generating SDK"
	rm -rf $(ALDERIS_SDK_DIR) $(notdir $(ALDERIS_SDK_DIR)).zip
	for i in Alderis; do \
		mkdir -p $(ALDERIS_SDK_DIR)/$$i.framework; \
		cp -a $(THEOS_STAGING_DIR)/Library/Frameworks/$$i.framework/{$$i,Headers,Modules} $(ALDERIS_SDK_DIR)/$$i.framework/; \
		tbd -p -v1 --ignore-missing-exports \
			--replace-install-name /Library/Frameworks/$$i.framework/$$i \
			$(ALDERIS_SDK_DIR)/$$i.framework/$$i \
			-o $(ALDERIS_SDK_DIR)/$$i.framework/$$i.tbd; \
		rm $(ALDERIS_SDK_DIR)/$$i.framework/$$i; \
		rm -rf $(THEOS_VENDOR_LIBRARY_PATH)/$$i.framework; \
	done
	rm -r $(THEOS_STAGING_DIR)/Library/Frameworks/*.framework/{Headers,Modules}
	cp -a $(ALDERIS_SDK_DIR)/* $(THEOS_VENDOR_LIBRARY_PATH)
	printf 'This is an SDK for developers wanting to use Alderis.\n\nVersion: %s\n\nFor more information, visit %s.' \
		"$(THEOS_PACKAGE_BASE_VERSION)" \
		"https://hbang.github.io/Alderis/" \
		> $(ALDERIS_SDK_DIR)/README.txt
	cd $(dir $(ALDERIS_SDK_DIR)); \
		zip -9Xrq "$(THEOS_PROJECT_DIR)/$(notdir $(ALDERIS_SDK_DIR)).zip" $(notdir $(ALDERIS_SDK_DIR))

ifeq ($(FINALPACKAGE),1)
before-package:: sdk
endif

.PHONY: docs sdk
