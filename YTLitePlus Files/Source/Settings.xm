#import "../YTLitePlus.h"
#import "../Tweaks/YouTubeHeader/YTSettingsViewController.h"
#import "../Tweaks/YouTubeHeader/YTSearchableSettingsViewController.h"
#import "../Tweaks/YouTubeHeader/YTSettingsSectionItem.h"
#import "../Tweaks/YouTubeHeader/YTSettingsSectionItemManager.h"
#import "../Tweaks/YouTubeHeader/YTUIUtils.h"
#import "../Tweaks/YouTubeHeader/YTSettingsPickerViewController.h"
#import "SettingsKeys.h"
// #import "AppIconOptionsController.h"

// Basic switch item
#define BASIC_SWITCH(title, description, key) \
    [YTSettingsSectionItemClass switchItemWithTitle:title \
        titleDescription:description \
        accessibilityIdentifier:nil \
        switchOn:IsEnabled(key) \
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) { \
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:key]; \
            return YES; \
        } \
        settingItemId:0]

/*
// Custom switch item that has customizable code
#define CUSTOM_SWITCH(title, description, key, code) \
    [YTSettingsSectionItemClass switchItemWithTitle:title \
        titleDescription:description \
        accessibilityIdentifier:nil \
        switchOn:IsEnabled(key) \
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enable) { \
            code \
        } \
        settingItemId:0]
*/

static int contrastMode() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"lcm"];
}
static int appVersionSpoofer() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"versionSpoofer"];
}

@interface YTSettingsSectionItemManager (YTLitePlus)
- (void)updateYTLitePlusSectionWithEntry:(id)entry;
@end

extern NSBundle *YTLitePlusBundle();

// Add both YTLite and YTLitePlus to YouGroupSettings
static const NSInteger YTLitePlusSection = 788;
static const NSInteger YTLiteSection = 789;
%hook YTSettingsGroupData
+ (NSMutableArray <NSNumber *> *)tweaks {
    NSMutableArray <NSNumber *> *originalTweaks = %orig;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [originalTweaks addObject:@(YTLitePlusSection)];
        [originalTweaks addObject:@(YTLiteSection)];
    });

    return originalTweaks;
}
%end


// Add YTLitePlus to the settings list
%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSArray *order = %orig;
    NSMutableArray *mutableOrder = [order mutableCopy];
    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound)
        [mutableOrder insertObject:@(YTLitePlusSection) atIndex:insertIndex + 1];
    return mutableOrder;
}
%end

%hook YTSettingsSectionController

- (void)setSelectedItem:(NSUInteger)selectedItem {
    if (selectedItem != NSNotFound) %orig;
}

%end

%hook YTSettingsSectionItemManager
%new(v@:@)
- (void)updateYTLitePlusSectionWithEntry:(id)entry {
    NSMutableArray *sectionItems = [NSMutableArray array];
    NSBundle *tweakBundle = YTLitePlusBundle();
    Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);
    YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];

    // Add item for going to the YTLitePlus GitHub page
    YTSettingsSectionItem *main = [%c(YTSettingsSectionItem)
        itemWithTitle:[NSString stringWithFormat:LOC(@"VERSION"), @(OS_STRINGIFY(TWEAK_VERSION))]
        titleDescription:LOC(@"VERSION_CHECK")
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/YTLitePlus/YTLitePlus/releases/latest"]];
        }];
    [sectionItems addObject:main];

# pragma mark - Copy and Paste Settings
    YTSettingsSectionItem *copySettings = [%c(YTSettingsSectionItem)
        itemWithTitle:IS_ENABLED(@"switchCopyandPasteFunctionality_enabled") ? LOC(@"EXPORT_SETTINGS") : LOC(@"COPY_SETTINGS")
        titleDescription:IS_ENABLED(@"switchCopyandPasteFunctionality_enabled") ? LOC(@"EXPORT_SETTINGS_DESC") : LOC(@"COPY_SETTINGS_DESC")
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            if (IS_ENABLED(@"switchCopyandPasteFunctionality_enabled")) {
                // Export Settings functionality
                NSURL *tempFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"YTLitePlusSettings.txt"]];
                NSMutableString *settingsString = [NSMutableString string];
                for (NSString *key in NSUserDefaultsCopyKeys) {
                    id value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
                    id defaultValue = NSUserDefaultsCopyKeysDefaults[key];
                    
                    // Only include the setting if it is different from the default value
                    // If no default value is found, include it by default
                    if (value && (!defaultValue || ![value isEqual:defaultValue])) {
                        [settingsString appendFormat:@"%@: %@\n", key, value];
                    }
                }
                [settingsString writeToURL:tempFileURL atomically:YES encoding:NSUTF8StringEncoding error:nil];
                UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithURL:tempFileURL inMode:UIDocumentPickerModeExportToService];
                documentPicker.delegate = (id<UIDocumentPickerDelegate>)self;
                documentPicker.allowsMultipleSelection = NO;
                [settingsViewController presentViewController:documentPicker animated:YES completion:nil];
            } else {
                // Copy Settings functionality (DEFAULT - Copies to Clipboard)
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSMutableString *settingsString = [NSMutableString string];
                for (NSString *key in NSUserDefaultsCopyKeys) {
                    id value = [userDefaults objectForKey:key];
                    id defaultValue = NSUserDefaultsCopyKeysDefaults[key];
                    
                    // Only include the setting if it is different from the default value
                    // If no default value is found, include it by default
                    if (value && (!defaultValue || ![value isEqual:defaultValue])) {
                        [settingsString appendFormat:@"%@: %@\n", key, value];
                    }
                }       
                [[UIPasteboard generalPasteboard] setString:settingsString];
                // Show a confirmation message or perform some other action here
                [[%c(GOOHUDManagerInternal) sharedInstance] showMessageMainThread:[%c(YTHUDMessage) messageWithText:@"Settings copied"]];
                
                // Show an option to export YouTube Plus settings
                UIAlertController *exportAlert = [UIAlertController alertControllerWithTitle:@"Export Settings"
                                                    message:@"Note: This feature cannot save iSponsorBlock and most YouTube settings.\n\nWould you like to also export your YouTube Plus Settings?"
                                                    preferredStyle:UIAlertControllerStyleAlert];
                [exportAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
                [exportAlert addAction:[UIAlertAction actionWithTitle:@"Export" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    // Export YouTube Plus Settings functionality
                    [%c(YTLUserDefaults) exportYtlSettings];
                }]];
                // Present the alert from the root view controller
                [settingsViewController presentViewController:exportAlert animated:YES completion:nil];
            }

            return YES;
        }
    ];
    [sectionItems addObject:copySettings];

    YTSettingsSectionItem *pasteSettings = [%c(YTSettingsSectionItem)
        itemWithTitle:IS_ENABLED(@"switchCopyandPasteFunctionality_enabled") ? LOC(@"IMPORT_SETTINGS") : LOC(@"PASTE_SETTINGS")
        titleDescription:IS_ENABLED(@"switchCopyandPasteFunctionality_enabled") ? LOC(@"IMPORT_SETTINGS_DESC") : LOC(@"PASTE_SETTINGS_DESC")
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            if (IS_ENABLED(@"switchCopyandPasteFunctionality_enabled")) {
                // Paste Settings functionality (ALTERNATE - Pastes from ".txt")
                UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.text"] inMode:UIDocumentPickerModeImport];
                documentPicker.delegate = (id<UIDocumentPickerDelegate>)self;
                documentPicker.allowsMultipleSelection = NO;
                [settingsViewController presentViewController:documentPicker animated:YES completion:nil];
            } else {
                // Paste Settings functionality (DEFAULT - Pastes from Clipboard)
                UIAlertController *confirmPasteAlert = [UIAlertController alertControllerWithTitle:LOC(@"PASTE_SETTINGS_ALERT") message:nil preferredStyle:UIAlertControllerStyleAlert];
                [confirmPasteAlert addAction:[UIAlertAction actionWithTitle:LOC(@"Cancel") style:UIAlertActionStyleCancel handler:nil]];
                [confirmPasteAlert addAction:[UIAlertAction actionWithTitle:LOC(@"Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSString *settingsString = [[UIPasteboard generalPasteboard] string];
                    if (settingsString.length > 0) {
                        NSArray *lines = [settingsString componentsSeparatedByString:@"\n"];
                        for (NSString *line in lines) {
                            NSArray *components = [line componentsSeparatedByString:@": "];
                            if (components.count == 2) {
                                NSString *key = components[0];
                                NSString *value = components[1];
                                [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
                            }
                        }
                        [settingsViewController reloadData];
                        // Show a confirmation toast
                        [[%c(GOOHUDManagerInternal) sharedInstance] showMessageMainThread:[%c(YTHUDMessage) messageWithText:@"Settings applied"]];
                        // Show a reminder to import YouTube Plus settings as well
                        UIAlertController *reminderAlert = [UIAlertController alertControllerWithTitle:@"Reminder"
                                                            message:@"Remember to import your YouTube Plus settings as well"
                                                            preferredStyle:UIAlertControllerStyleAlert];
                        [reminderAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                        [settingsViewController presentViewController:reminderAlert animated:YES completion:nil];
                    }
                }]];
                [settingsViewController presentViewController:confirmPasteAlert animated:YES completion:nil];
            }

            return YES;
        }
    ];
    [sectionItems addObject:pasteSettings];

/*
    YTSettingsSectionItem *appIcon = [%c(YTSettingsSectionItem)
        itemWithTitle:LOC(@"CHANGE_APP_ICON")
        titleDescription:nil
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            AppIconOptionsController *appIconController = [[AppIconOptionsController alloc] init];
            [settingsViewController.navigationController pushViewController:appIconController animated:YES];
            return YES;
        }
    ];
    [sectionItems addObject:appIcon];
*/

# pragma mark - Player Gestures - @bhackel
    // Helper to get the selected gesture mode
    static NSString* (^sectionGestureSelectedModeToString)(GestureMode) = ^(GestureMode sectionIndex) {
        switch (sectionIndex) {
            case GestureModeVolume:
                return LOC(@"VOLUME");
            case GestureModeBrightness:
                return LOC(@"BRIGHTNESS");
            case GestureModeSeek:
                return LOC(@"SEEK");
            case GestureModeDisabled:
                return LOC(@"DISABLED");
            default:
                return @"Invalid index - Report bug";
        }
    };

    // Helper to generate checkmark setting items for selecting gesture modes
    static YTSettingsSectionItem* (^gestureCheckmarkSettingItem)(NSInteger, NSString *) = ^(NSInteger idx, NSString *key) {
        return [YTSettingsSectionItemClass 
            checkmarkItemWithTitle:sectionGestureSelectedModeToString(idx)
            selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                [[NSUserDefaults standardUserDefaults] setInteger:idx forKey:key];
                [settingsViewController reloadData];
                return YES;
            }
        ];
    };

    // Helper to generate a section item for selecting a gesture mode
    YTSettingsSectionItem *(^createSectionGestureSelector)(NSString *, NSString *) = ^YTSettingsSectionItem *(NSString *sectionLabel, NSString *sectionKey) {
        return [YTSettingsSectionItemClass itemWithTitle:LOC(sectionLabel)
            accessibilityIdentifier:nil
            detailTextBlock:^NSString *() {
                return sectionGestureSelectedModeToString(GetInteger(sectionKey));
            }
            selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                NSArray <YTSettingsSectionItem *> *rows = @[
                    gestureCheckmarkSettingItem(0, sectionKey), // Volume                             
                    gestureCheckmarkSettingItem(1, sectionKey), // Brightness
                    gestureCheckmarkSettingItem(2, sectionKey), // Seek
                    gestureCheckmarkSettingItem(3, sectionKey)  // Disabled
                ];
                // Present picker when selecting this settings item
                YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] 
                    initWithNavTitle:LOC(sectionLabel) 
                    pickerSectionTitle:nil 
                    rows:rows 
                    selectedItemIndex:GetInteger(sectionKey) 
                    parentResponder:[self parentResponder]
                ];
                [settingsViewController pushViewController:picker];
                return YES;
            }
        ];
    };
    // Configuration picker for deadzone to pick from 0 to 100 pixels with interval of 10
    NSMutableArray<NSNumber *> *deadzoneValues = [NSMutableArray array];
    for (CGFloat value = 0; value <= 100; value += 10) {
        [deadzoneValues addObject:@(value)];
    }
    YTSettingsSectionItem *deadzonePicker = [YTSettingsSectionItemClass 
        itemWithTitle:LOC(@"DEADZONE") 
        titleDescription:LOC(@"DEADZONE_DESC")
        accessibilityIdentifier:nil 
        detailTextBlock:^NSString *() {
            return [NSString stringWithFormat:@"%ld px", (long)GetFloat(@"playerGesturesDeadzone")];
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            // Generate rows for deadzone picker using the predefined array
            NSMutableArray <YTSettingsSectionItem *> *deadzoneRows = [NSMutableArray array];
            for (NSNumber *deadzoneValue in deadzoneValues) {
                CGFloat deadzone = [deadzoneValue floatValue];
                [deadzoneRows addObject:[YTSettingsSectionItemClass 
                    checkmarkItemWithTitle:[NSString stringWithFormat:@"%ld px", (long)deadzone] 
                    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                        [[NSUserDefaults standardUserDefaults] setFloat:deadzone forKey:@"playerGesturesDeadzone"];
                        [settingsViewController reloadData];
                        return YES;
                    }
                ]];
            }
            // Determine the index of the currently selected deadzone
            CGFloat currentDeadzone = GetFloat(@"playerGesturesDeadzone");
            NSUInteger selectedIndex = [deadzoneValues indexOfObject:@(currentDeadzone)];
            if (selectedIndex == NSNotFound) {
                selectedIndex = 0; // Default to the first item if the current deadzone is not found
            }
            // Present deadzone picker when selecting this settings item
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] 
                initWithNavTitle:LOC(@"DEADZONE") 
                pickerSectionTitle:nil 
                rows:deadzoneRows 
                selectedItemIndex:selectedIndex 
                parentResponder:[self parentResponder]
            ];
            [settingsViewController pushViewController:picker];
            return YES;
        }
    ];

    // Configuration picker for sensitivity to pick from 0.5 to 2.0 with interval of 0.1
    NSMutableArray<NSNumber *> *sensitivityValues = [NSMutableArray array];
    for (CGFloat value = 0.5; value <= 2.0; value += 0.1) {
        [sensitivityValues addObject:@(value)];
    }
    YTSettingsSectionItem *sensitivityPicker = [YTSettingsSectionItemClass 
        itemWithTitle:LOC(@"SENSITIVITY") 
        titleDescription:LOC(@"SENSITIVITY_DESC")
        accessibilityIdentifier:nil 
        detailTextBlock:^NSString *() {
            return [NSString stringWithFormat:@"%.1f", GetFloat(@"playerGesturesSensitivity")];
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            // Generate rows for sensitivity picker using the predefined array
            NSMutableArray <YTSettingsSectionItem *> *sensitivityRows = [NSMutableArray array];
            for (NSNumber *sensitivityValue in sensitivityValues) {
                CGFloat sensitivity = [sensitivityValue floatValue];
                [sensitivityRows addObject:[YTSettingsSectionItemClass 
                    checkmarkItemWithTitle:[NSString stringWithFormat:@"%.1f", sensitivity] 
                    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                        [[NSUserDefaults standardUserDefaults] setFloat:sensitivity forKey:@"playerGesturesSensitivity"];
                        [settingsViewController reloadData];
                        return YES;
                    }
                ]];
            }
            // Determine the index of the currently selected sensitivity
            CGFloat currentSensitivity = GetFloat(@"playerGesturesSensitivity");
            NSUInteger selectedIndex = [sensitivityValues indexOfObject:@(currentSensitivity)];
            if (selectedIndex == NSNotFound) {
                selectedIndex = 0; // Default to the first item if the current sensitivity is not found
            }
            // Present sensitivity picker
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] 
                initWithNavTitle:LOC(@"SENSITIVITY") 
                pickerSectionTitle:nil 
                rows:sensitivityRows 
                selectedItemIndex:selectedIndex 
                parentResponder:[self parentResponder]
            ];
            [settingsViewController pushViewController:picker];
            return YES;
        }
    ];

    // Create and add items to the high level gestures menu
    YTSettingsSectionItem *playerGesturesGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"PLAYER_GESTURES_TITLE") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            // Description header item
            [YTSettingsSectionItemClass 
                itemWithTitle:nil
                titleDescription:LOC(@"PLAYER_GESTURES_DESC")
                accessibilityIdentifier:nil
                detailTextBlock:nil
                selectBlock:nil
            ],
            // Toggle for enabling gestures
            BASIC_SWITCH(LOC(@"PLAYER_GESTURES_TOGGLE"), nil, @"playerGestures_enabled"),
            // Pickers for each gesture section
            createSectionGestureSelector(@"TOP_SECTION",    @"playerGestureTopSelection"),
            createSectionGestureSelector(@"MIDDLE_SECTION", @"playerGestureMiddleSelection"),
            createSectionGestureSelector(@"BOTTOM_SECTION", @"playerGestureBottomSelection"),
            // Pickers for configuration settings
            deadzonePicker,
            sensitivityPicker,
            // Toggle for haptic feedback
            BASIC_SWITCH(LOC(@"PLAYER_GESTURES_HAPTIC_FEEDBACK"), nil, @"playerGesturesHapticFeedback_enabled"),
        ];        
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"PLAYER_GESTURES_TITLE") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:playerGesturesGroup];

# pragma mark - Video Controls Overlay Options
    YTSettingsSectionItem *videoControlOverlayGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"VIDEO_CONTROLS_OVERLAY_OPTIONS") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            BASIC_SWITCH(LOC(@"ENABLE_SHARE_BUTTON"), LOC(@"ENABLE_SHARE_BUTTON_DESC"), @"enableShareButton_enabled"),
            BASIC_SWITCH(LOC(@"ENABLE_SAVE_TO_PLAYLIST_BUTTON"), LOC(@"ENABLE_SAVE_TO_PLAYLIST_BUTTON_DESC"), @"enableSaveToButton_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_SHADOW_OVERLAY_BUTTONS"), LOC(@"HIDE_SHADOW_OVERLAY_BUTTONS_DESC"), @"hideVideoPlayerShadowOverlayButtons_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_RIGHT_PANEL"), LOC(@"HIDE_RIGHT_PANEL_DESC"), @"hideRightPanel_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_HEATWAVES"), LOC(@"HIDE_HEATWAVES_DESC"), @"hideHeatwaves_enabled"),
            BASIC_SWITCH(LOC(@"DISABLE_AMBIENT_PORTRAIT"), LOC(@"DISABLE_AMBIENT_PORTRAIT_DESC"), @"disableAmbientModePortrait_enabled"),
            BASIC_SWITCH(LOC(@"DISABLE_AMBIENT_FULLSCREEN"), LOC(@"DISABLE_AMBIENT_FULLSCREEN_DESC"), @"disableAmbientModeFullscreen_enabled"),
            BASIC_SWITCH(LOC(@"FULLSCREEN_TO_THE_RIGHT"), LOC(@"FULLSCREEN_TO_THE_RIGHT_DESC"), @"fullscreenToTheRight_enabled"),
            BASIC_SWITCH(LOC(@"SEEK_ANYWHERE"), LOC(@"SEEK_ANYWHERE_DESC"), @"seekAnywhere_enabled"),
            BASIC_SWITCH(LOC(@"ENABLE_TAP_TO_SEEK"), LOC(@"ENABLE_TAP_TO_SEEK_DESC"), @"YTTapToSeek_enabled"),
            BASIC_SWITCH(LOC(@"DISABLE_PULL_TO_FULLSCREEN_GESTURE"), LOC(@"DISABLE_PULL_TO_FULLSCREEN_GESTURE_DESC"), @"disablePullToFull_enabled"),
            BASIC_SWITCH(LOC(@"ALWAYS_USE_REMAINING_TIME"), LOC(@"ALWAYS_USE_REMAINING_TIME_DESC"), @"alwaysShowRemainingTime_enabled"),
            BASIC_SWITCH(LOC(@"DISABLE_TOGGLE_TIME_REMAINING"), LOC(@"DISABLE_TOGGLE_TIME_REMAINING_DESC"), @"disableRemainingTime_enabled"),
            BASIC_SWITCH(LOC(@"DISABLE_ENGAGEMENT_OVERLAY"), LOC(@"DISABLE_ENGAGEMENT_OVERLAY_DESC"), @"disableEngagementOverlay_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_COMMENT_PREVIEWS_UNDER_PLAYER"), LOC(@"HIDE_COMMENT_PREVIEWS_UNDER_PLAYER_DESC"), @"hidePreviewCommentSection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_AUTOPLAY_MINI_PREVIEW"), LOC(@"HIDE_AUTOPLAY_MINI_PREVIEW_DESC"), @"hideAutoplayMiniPreview_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_HUD_MESSAGES"), LOC(@"HIDE_HUD_MESSAGES_DESC"), @"hideHUD_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_COLLAPSE_BUTTON"), LOC(@"HIDE_COLLAPSE_BUTTON_DESC"), @"disableCollapseButton_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_SPEED_TOAST"), LOC(@"HIDE_SPEED_TOAST_DESC"), @"hideSpeedToast_enabled"),
        ];        
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"VIDEO_CONTROLS_OVERLAY_OPTIONS") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:videoControlOverlayGroup];

# pragma mark - App Settings Overlay Options
    YTSettingsSectionItem *appSettingsOverlayGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"APP_SETTINGS_OVERLAY_OPTIONS") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            BASIC_SWITCH(LOC(@"HIDE_ACCOUNT_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableAccountSection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_AUTOPLAY_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableAutoplaySection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_TRYNEWFEATURES_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableTryNewFeaturesSection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_VIDEOQUALITYPREFERENCES_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableVideoQualityPreferencesSection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_NOTIFICATIONS_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableNotificationsSection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_MANAGEALLHISTORY_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableManageAllHistorySection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_YOURDATAINYOUTUBE_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableYourDataInYouTubeSection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_PRIVACY_SECTION"), LOC(@"APP_RESTART_DESC"), @"disablePrivacySection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_LIVECHAT_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableLiveChatSection_enabled")
        ];        
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"APP_SETTINGS_OVERLAY_OPTIONS") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:appSettingsOverlayGroup];

# pragma mark - LowContrastMode
    YTSettingsSectionItem *lowContrastModeSection = [YTSettingsSectionItemClass itemWithTitle:LOC(@"LOW_CONTRAST_MODE")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (contrastMode()) {
                case 1:
                    return LOC(@"Hex Color");
                case 0:
                default:
                    return LOC(@"Default");
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"Default") titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"lcm"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"Hex Color") titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"lcm"];
                    [settingsViewController reloadData];
                    return YES;
                }]
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"LOW_CONTRAST_MODE") pickerSectionTitle:nil rows:rows selectedItemIndex:contrastMode() parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];

# pragma mark - VersionSpooferLite
    YTSettingsSectionItem *versionSpooferSection = [YTSettingsSectionItemClass itemWithTitle:LOC(@"VERSION_SPOOFER_TITLE")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (appVersionSpoofer()) {
                case 1:
                    return @"v18.34.5 (Enable Library Tab)";
                case 2:
                    return @"v18.33.3 (Removes Playables)";
                case 3:
                    return @"v18.18.2 (Fixes YTClassicVideoQuality & YTSpeed)";
                case 4:
                    return @"v18.01.2 (First v18 Version)";
                case 5:
                    return @"v17.49.6 (Removes Rounded Miniplayer)";
                case 6:
                    return @"v17.38.10 (Fixes LowContrastMode)";
                case 7:
                    return @"v17.33.2 (Oldest Supported Version)";
                case 0:
                default:
                    return @"v18.49.3 (Last v18 Version)";
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.49.3 (Last v18 Version)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.34.5 (Enable Library Tab)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.33.3 (Removes Playables)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.18.2 (Fixes YTClassicVideoQuality & YTSpeed)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.01.2 (First v18 Version)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.49.6 (Removes Rounded Miniplayer)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.38.10 (Fixes LowContrastMode)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:6 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.33.2 (Oldest Supported Version)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:7 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }]
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:@"VERSION_SPOOFER_TITLE" pickerSectionTitle:nil rows:rows selectedItemIndex:appVersionSpoofer() parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];

# pragma mark - Theme
    YTSettingsSectionItem *themeGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"THEME_OPTIONS")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (GetInteger(@"appTheme")) {
                case 1:
                    return LOC(@"OLD_DARK_THEME");
                case 0:
                default:
                    return LOC(@"DEFAULT_THEME");
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"DEFAULT_THEME") titleDescription:LOC(@"DEFAULT_THEME_DESC") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"appTheme"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"OLD_DARK_THEME") titleDescription:LOC(@"OLD_DARK_THEME_DESC") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"appTheme"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                BASIC_SWITCH(LOC(@"OLED_KEYBOARD"), LOC(@"OLED_KEYBOARD_DESC"), @"oledKeyBoard_enabled"),
                BASIC_SWITCH(LOC(@"LOW_CONTRAST_MODE"), LOC(@"LOW_CONTRAST_MODE_DESC"), @"lowContrastMode_enabled"),
                lowContrastModeSection
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"THEME_OPTIONS") pickerSectionTitle:nil rows:rows selectedItemIndex:GetInteger(@"appTheme") parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];
    [sectionItems addObject:themeGroup];

# pragma mark - Copy of Playback in feeds section - @bhackel
    // This section is hidden in vanilla YouTube when using the new settings UI, so
    // we can recreate it here
    YTSettingsSectionItem *playbackInFeedsGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"PLAYBACK_IN_FEEDS")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            // The specific values were gathered by checking the value for each setting
            switch (GetInteger(@"inline_muted_playback_enabled")) {
                case 3:
                    return LOC(@"PLAYBACK_IN_FEEDS_WIFI_ONLY");
                case 1:
                    return LOC(@"PLAYBACK_IN_FEEDS_OFF");
                case 2:
                default:
                    return LOC(@"PLAYBACK_IN_FEEDS_ALWAYS_ON");
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"PLAYBACK_IN_FEEDS_OFF") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"inline_muted_playback_enabled"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"PLAYBACK_IN_FEEDS_ALWAYS_ON") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"inline_muted_playback_enabled"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"PLAYBACK_IN_FEEDS_WIFI_ONLY") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"inline_muted_playback_enabled"];
                    [settingsViewController reloadData];
                    return YES;
                }],
            ];
            // It seems values greater than 3 act the same as Always On (Index 1)
            // Convert the stored value to an index for a picker (0 to 2)
            NSInteger (^getInlineSelection)(void) = ^NSInteger(void) {
                NSInteger selection = GetInteger(@"inline_muted_playback_enabled") - 1;
                // Check if selection is within the valid bounds [0, 1, 2]
                if (selection < 0 || selection > 2) {
                    return 1;
                }
                return selection;
            };
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"PLAYBACK_IN_FEEDS") pickerSectionTitle:nil rows:rows selectedItemIndex:getInlineSelection() parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }
    ];

# pragma mark - Miscellaneous
    YTSettingsSectionItem *miscellaneousGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"MISCELLANEOUS") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            playbackInFeedsGroup,
            // BASIC_SWITCH(LOC(@"NEW_SETTINGS_UI"), LOC(@"NEW_SETTINGS_UI_DESC"), @"newSettingsUI_enabled"), // disabled because YTLite is probably forcing it to NO
            BASIC_SWITCH(LOC(@"ENABLE_YT_STARTUP_ANIMATION"), LOC(@"ENABLE_YT_STARTUP_ANIMATION_DESC"), @"ytStartupAnimation_enabled"), 
            BASIC_SWITCH(LOC(@"HIDE_MODERN_INTERFACE"), LOC(@"HIDE_MODERN_INTERFACE_DESC"), @"ytNoModernUI_enabled"),
            BASIC_SWITCH(LOC(@"IPAD_LAYOUT"), LOC(@"IPAD_LAYOUT_DESC"), @"iPadLayout_enabled"),
            BASIC_SWITCH(LOC(@"IPHONE_LAYOUT"), LOC(@"IPHONE_LAYOUT_DESC"), @"iPhoneLayout_enabled"),
            BASIC_SWITCH(LOC(@"CAST_CONFIRM"), LOC(@"CAST_CONFIRM_DESC"), @"castConfirm_enabled"),
            BASIC_SWITCH(LOC(@"NEW_MINIPLAYER_STYLE"), LOC(@"NEW_MINIPLAYER_STYLE_DESC"), @"bigYTMiniPlayer_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_CAST_BUTTON"), LOC(@"HIDE_CAST_BUTTON_DESC"), @"hideCastButton_enabled"),
            BASIC_SWITCH(LOC(@"VIDEO_PLAYER_BUTTON"), LOC(@"VIDEO_PLAYER_BUTTON_DESC"), @"videoPlayerButton_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_SPONSORBLOCK_BUTTON"), LOC(@"HIDE_SPONSORBLOCK_BUTTON_DESC"), @"hideSponsorBlockButton_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_HOME_TAB"), LOC(@"HIDE_HOME_TAB_DESC"), @"hideHomeTab_enabled"),
            BASIC_SWITCH(LOC(@"FIX_CASTING"), LOC(@"FIX_CASTING_DESC"), @"fixCasting_enabled"),
            BASIC_SWITCH(LOC(@"REPLACE_COPY_AND_PASTE_BUTTONS"), LOC(@"REPLACE_COPY_AND_PASTE_BUTTONS_DESC"), @"switchCopyandPasteFunctionality_enabled"),
            BASIC_SWITCH(LOC(@"ENABLE_FLEX"), LOC(@"ENABLE_FLEX_DESC"), @"flex_enabled"),
            BASIC_SWITCH(LOC(@"APP_VERSION_SPOOFER_LITE"), LOC(@"APP_VERSION_SPOOFER_LITE_DESC"), @"enableVersionSpoofer_enabled"),    
            versionSpooferSection
        ];
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"MISCELLANEOUS") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:miscellaneousGroup];

    if ([settingsViewController respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)])
        [settingsViewController setSectionItems:sectionItems forCategory:YTLitePlusSection title:@"YTLitePlus" icon:nil titleDescription:LOC(@"TITLE DESCRIPTION") headerHidden:YES];
    else
        [settingsViewController setSectionItems:sectionItems forCategory:YTLitePlusSection title:@"YTLitePlus" titleDescription:LOC(@"TITLE DESCRIPTION") headerHidden:YES];}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == YTLitePlusSection) {
        [self updateYTLitePlusSectionWithEntry:entry];
        return;
    }
    %orig;
}

// Implement the delegate method for document picker
%new
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count > 0) {
        NSURL *pickedURL = [urls firstObject];
        NSError *error;
        // Check which mode the document picker is in
        if (controller.documentPickerMode == UIDocumentPickerModeImport) {
            // Import mode: Handle the import of settings from a text file
            NSString *fileType = [pickedURL resourceValuesForKeys:@[NSURLTypeIdentifierKey] error:&error][NSURLTypeIdentifierKey];

            UTType *utType = [UTType typeWithIdentifier:fileType];
            if ([utType conformsToType:UTTypePlainText]) {
                NSString *fileContents = [NSString stringWithContentsOfURL:pickedURL encoding:NSUTF8StringEncoding error:nil];
                NSArray *lines = [fileContents componentsSeparatedByString:@"\n"];
                for (NSString *line in lines) {
                    NSArray *components = [line componentsSeparatedByString:@": "];
                    if (components.count == 2) {
                        NSString *key = components[0];
                        NSString *value = components[1];
                        [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
                    }
                }
                // Reload settings view after importing
                YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];
                [settingsViewController reloadData];
                // Show a confirmation message or perform some other action here
                [[%c(GOOHUDManagerInternal) sharedInstance] showMessageMainThread:[%c(YTHUDMessage) messageWithText:@"Settings applied"]];
                // Show a reminder to import YouTube Plus settings as well
                UIAlertController *reminderAlert = [UIAlertController alertControllerWithTitle:@"Reminder"
                                                    message:@"Remember to import your YouTube Plus settings as well"
                                                    preferredStyle:UIAlertControllerStyleAlert];
                [reminderAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [settingsViewController presentViewController:reminderAlert animated:YES completion:nil];
            }

        } else if (controller.documentPickerMode == UIDocumentPickerModeExportToService || controller.documentPickerMode == UIDocumentPickerModeMoveToService) {
            [[%c(GOOHUDManagerInternal) sharedInstance] showMessageMainThread:[%c(YTHUDMessage) messageWithText:@"Settings saved"]];
            // Export mode: Display a reminder to save YouTube Plus settings
            UIAlertController *exportAlert = [UIAlertController alertControllerWithTitle:@"Export Settings"
                                                message:@"Note: This feature cannot save iSponsorBlock and most YouTube settings.\n\nWould you like to also export your YouTube Plus Settings?"
                                                preferredStyle:UIAlertControllerStyleAlert];
            [exportAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
            [exportAlert addAction:[UIAlertAction actionWithTitle:@"Export" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // Export YouTube Plus Settings functionality
                [%c(YTLUserDefaults) exportYtlSettings];
            }]];
            YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];
            // Present the alert from the root view controller
            [settingsViewController presentViewController:exportAlert animated:YES completion:nil];
        }
    }
}

%end

