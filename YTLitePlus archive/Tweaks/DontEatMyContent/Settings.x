#import "Tweak.h"
#import "Settings.h"

// Adapted from 
// https://github.com/PoomSmart/YouPiP/blob/bd04bf37be3d01540db418061164ae17a8f0298e/Settings.x
// https://github.com/qnblackcat/uYouPlus/blob/265927b3900d886e2085d05bfad7cd4157be87d2/Settings.xm

#define SECTION_HEADER(s) [sectionItems addObject:[%c(YTSettingsSectionItem) itemWithTitle:@"\t" titleDescription:[s uppercaseString] accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger sectionItemIndex) { return NO; }]]
#define SWITCH_ITEM(t, d, k) [sectionItems addObject:[%c(YTSettingsSectionItem) switchItemWithTitle:t titleDescription:d accessibilityIdentifier:nil switchOn:IS_ENABLED(k) switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:k];DEMC_showSnackBar(LOCALIZED_STRING(@"CHANGES_SAVED"));return YES;} settingItemId:0]]

static const NSInteger sectionId = 517; // DontEatMyContent's section ID (just a random number)

%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSArray *order = %orig;
    NSMutableArray *mutableOrder = [order mutableCopy];
    NSUInteger insertIndex = [order indexOfObject:@(1)]; // Index of Settings > General
    if (insertIndex != NSNotFound)
        [mutableOrder insertObject:@(sectionId) atIndex:insertIndex + 1]; // Insert DontEatMyContent settings under General
    return mutableOrder;
}
%end

%hook YTSettingsSectionItemManager
%new
- (void)updateDEMCSectionWithEntry:(id)entry {
    YTSettingsViewController *delegate = [self valueForKey:@"_dataDelegate"];
    NSMutableArray *sectionItems = [NSMutableArray array]; // Create autoreleased array
    NSBundle *bundle = DEMC_getTweakBundle();

    // Enabled
    [sectionItems addObject:[%c(YTSettingsSectionItem)
        switchItemWithTitle:LOCALIZED_STRING(@"ENABLED")
        titleDescription:LOCALIZED_STRING(@"TWEAK_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_ENABLED(kTweak)
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kTweak];
            
            YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];
            [settingsViewController.navigationController popViewControllerAnimated:YES];
            DEMC_showSnackBar(LOCALIZED_STRING(@"CHANGES_SAVED"));
            return YES;

            YTAlertView *alert = [%c(YTAlertView) confirmationDialogWithAction:^
                {
                    // https://stackoverflow.com/a/17802404/19227228
                    [[UIApplication sharedApplication] performSelector:@selector(suspend)];
                    [NSThread sleepForTimeInterval:0.5];
                    exit(0);
                }
                actionTitle:LOCALIZED_STRING(@"EXIT")
                cancelTitle:LOCALIZED_STRING(@"LATER")
            ];
            alert.title = DEMC;
            alert.subtitle = LOCALIZED_STRING(@"EXIT_YT_DESC");
            [alert show];

            return YES;
        }
        settingItemId:0
    ]];

    // Disable ambient mode
    SWITCH_ITEM(LOCALIZED_STRING(@"DISABLE_AMBIENT_MODE"), nil, kDisableAmbientMode);

    if (IS_ENABLED(kTweak)) {
        SECTION_HEADER(LOCALIZED_STRING(@"ADVANCED"));

        // Safe area constant
        [sectionItems addObject:[%c(YTSettingsSectionItem)
            itemWithTitle:LOCALIZED_STRING(@"SAFE_AREA_CONST")
            titleDescription:LOCALIZED_STRING(@"SAFE_AREA_CONST_DESC")
            accessibilityIdentifier:nil
            detailTextBlock:^NSString *() {
                return [NSString stringWithFormat:@"%.1f", constant];
            }
            selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger sectionItemIndex) {
                __block YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];
                
                // Create rows
                NSMutableArray *rows = [NSMutableArray array];
                float currentConstant = 20.0;
                float storedConstant = [[NSUserDefaults standardUserDefaults] floatForKey:kSafeAreaConstant];
                UInt8 index = 0, selectedIndex = 0;
                while (currentConstant <= 25.0) {
                    NSString *title = [NSString stringWithFormat:@"%.1f", currentConstant];
                    if (currentConstant == DEFAULT_CONSTANT)
                        title = [NSString stringWithFormat:@"%.1f (%@)", currentConstant, LOCALIZED_STRING(@"DEFAULT")];
                    if (currentConstant == storedConstant)
                        selectedIndex = index;
                    [rows addObject:[%c(YTSettingsSectionItem) checkmarkItemWithTitle:title
                        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger sectionItemIndex) {
                            [[NSUserDefaults standardUserDefaults] setFloat:currentConstant forKey:kSafeAreaConstant];
                            constant = currentConstant;
                            [settingsViewController reloadData]; // Refresh section's detail text (constant)
                            DEMC_showSnackBar(LOCALIZED_STRING(@"CHANGES_SAVED_DISMISS_VIDEO"));
                            return YES;
                        }
                    ]];
                    currentConstant += 0.5; index++;
                }

                YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOCALIZED_STRING(@"SAFE_AREA_CONST")
                    pickerSectionTitle:[LOCALIZED_STRING(@"SAFE_AREA_CONST") uppercaseString]
                    rows:rows
                    selectedItemIndex:selectedIndex
                    parentResponder:[self parentResponder]
                ];

                [settingsViewController pushViewController:picker];
                return YES;
            }
        ]];
        
        // Color views
        SWITCH_ITEM(LOCALIZED_STRING(@"COLOR_VIEWS"), LOCALIZED_STRING(@"COLOR_VIEWS_DESC"), kColorViews);

        // Enable for all videos
        SWITCH_ITEM(LOCALIZED_STRING(@"ENABLE_FOR_ALL_VIDEOS"), LOCALIZED_STRING(@"ENABLE_FOR_ALL_VIDEOS_DESC"), kEnableForAllVideos);
    }

    SECTION_HEADER(LOCALIZED_STRING(@"ABOUT"));

    // Report an issue
    [sectionItems addObject:[%c(YTSettingsSectionItem)
        itemWithTitle:LOCALIZED_STRING(@"REPORT_ISSUE")
        titleDescription:nil
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger sectionItemIndex) {
            NSString *url = [NSString stringWithFormat:@"https://github.com/therealFoxster/DontEatMyContent/issues/new/?template=bug_report.yml&title=[v%@] %@", DEMC_VERSION, LOCALIZED_STRING(@"ADD_TITLE")];
            return [%c(YTUIUtils) openURL:[NSURL URLWithString:url]];
        }
    ]];

    // Version
    [sectionItems addObject:[%c(YTSettingsSectionItem)
        itemWithTitle:LOCALIZED_STRING(@"VERSION")
        titleDescription:nil
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            return [NSString stringWithFormat:@"v%@", DEMC_VERSION];
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger sectionItemIndex) {
            return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/therealFoxster/DontEatMyContent/releases/"]];
        }
    ]];

    if ([delegate respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)])
        // For YouTube v19.03.2+ (https://github.com/PoomSmart/YouPiP/commit/0597b15d57361e652557a33f0592667058c5145c)
        [delegate setSectionItems:sectionItems
            forCategory:sectionId 
            title:LOCALIZED_STRING(@"SETTINGS_TITLE") 
            icon:nil 
            titleDescription:nil 
            headerHidden:NO
        ];
    else
        [delegate setSectionItems:sectionItems 
            forCategory:sectionId 
            title:LOCALIZED_STRING(@"SETTINGS_TITLE")
            titleDescription:nil 
            headerHidden:NO
        ];
}
- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == sectionId) {
        [self updateDEMCSectionWithEntry:entry];
        return;
    }
    %orig;
}
%end
