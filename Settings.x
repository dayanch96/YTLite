#import "YTLite.h"

@interface YTSettingsSectionItemManager (YTLite)
- (void)updateYTLiteSectionWithEntry:(id)entry;
@end

static const NSInteger YTLiteSection = 789;

NSBundle *YTLiteBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YTLite" ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else
            bundle = [NSBundle bundleWithPath:ROOT_PATH_NS("/Library/Application Support/YTLite.bundle")];
    });
    return bundle;
}

// Settings
%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSArray *order = %orig;
    NSMutableArray *mutableOrder = [order mutableCopy];
    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound)
        [mutableOrder insertObject:@(YTLiteSection) atIndex:insertIndex + 1];
    return mutableOrder;
}
%end

%hook YTSettingsSectionController
- (void)setSelectedItem:(NSUInteger)selectedItem {
    if (selectedItem != NSNotFound) %orig;
}
%end

%hook YTSettingsSectionItemManager
%new
- (void)updatePrefsForKey:(NSString *)key enabled:(BOOL)enabled {
    NSString *prefsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"YTLite.plist"];
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:prefsPath];

    if (!prefs) prefs = [NSMutableDictionary dictionary];

    [prefs setObject:@(enabled) forKey:key];
    [prefs writeToFile:prefsPath atomically:NO];

    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.dvntm.ytlite.prefschanged"), NULL, NULL, YES);
}

%new(v@:@)
- (void)updateYTLiteSectionWithEntry:(id)entry {
    NSMutableArray *sectionItems = [NSMutableArray array];
    Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);
    YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];

    YTSettingsSectionItem *general = [YTSettingsSectionItemClass itemWithTitle:LOC(@"General")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            return @"‣";
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"RemoveAds")
                titleDescription:LOC(@"RemoveAdsDesc")
                accessibilityIdentifier:nil
                switchOn:kNoAds
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [self updatePrefsForKey:@"noAds" enabled:enabled];
                    return YES;
                }
                settingItemId:0],
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"BackgroundPlayback")
                titleDescription:LOC(@"BackgroundPlaybackDesc")
                accessibilityIdentifier:nil
                switchOn:kBackgroundPlayback
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [self updatePrefsForKey:@"backgroundPlayback" enabled:enabled];
                    return YES;
                }
                settingItemId:0]
        ];

        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"General") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:general];

    YTSettingsSectionItem *navbar = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Navbar")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            return @"‣";
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"RemoveCast")
                titleDescription:LOC(@"RemoveCastDesc")
                accessibilityIdentifier:nil
                switchOn:kNoCast
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [self updatePrefsForKey:@"noCast" enabled:enabled];
                    return YES;
                }
                settingItemId:0],
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"RemoveNotifications")
                titleDescription:LOC(@"RemoveNotificationsDesc")
                accessibilityIdentifier:nil
                switchOn:kNoNotifsButton
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [self updatePrefsForKey:@"removeNotifsButton" enabled:enabled];
                    return YES;
                }
                settingItemId:0],
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"RemoveSearch")
                titleDescription:LOC(@"RemoveSearchDesc")
                accessibilityIdentifier:nil
                switchOn:kNoSearchButton
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [self updatePrefsForKey:@"removeSearchButton" enabled:enabled];
                    return YES;
                }
                settingItemId:0]
        ];

        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"Navbar") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:navbar];

    YTSettingsSectionItem *tabbar = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Tabbar")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            return @"‣";
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"RemoveLabels")
                titleDescription:LOC(@"RemoveLabelsDesc")
                accessibilityIdentifier:nil
                switchOn:kRemoveLabels
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [self updatePrefsForKey:@"removeLabels" enabled:enabled];
                    return YES;
                }
                settingItemId:0],
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HideShortsTab")
                titleDescription:LOC(@"HideShortsTabDesc")
                accessibilityIdentifier:nil
                switchOn:kRemoveShorts
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [self updatePrefsForKey:@"removeShorts" enabled:enabled];
                    return YES;
                }
                settingItemId:0],
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HideSubscriptionsTab")
                titleDescription:LOC(@"HideSubscriptionsTabDesc")
                accessibilityIdentifier:nil
                switchOn:kRemoveSubscriptions
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [self updatePrefsForKey:@"removeSubscriptions" enabled:enabled];
                    return YES;
                }
                settingItemId:0],
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HideUploadButton")
                titleDescription:LOC(@"HideUploadButtonDesc")
                accessibilityIdentifier:nil
                switchOn:kRemoveUploads
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [self updatePrefsForKey:@"removeUploads" enabled:enabled];
                    return YES;
                }
                settingItemId:0],
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HideLibraryTab")
                titleDescription:LOC(@"HideLibraryTabDesc")
                accessibilityIdentifier:nil
                switchOn:kRemoveLibrary
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [self updatePrefsForKey:@"removeLibrary" enabled:enabled];
                    return YES;
                }
                settingItemId:0]
        ];

        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"Tabbar") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:tabbar];

    YTSettingsSectionItem *ps = [%c(YTSettingsSectionItem) itemWithTitle:@"PoomSmart" titleDescription:@"YouTube-X, YTNoPremium, YouTubeHeaders" accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/PoomSmart/"]];
    }];

    YTSettingsSectionItem *dayanch96 = [%c(YTSettingsSectionItem) itemWithTitle:@"Dayanch96" titleDescription:LOC(@"Developer") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/Dayanch96/"]];
    }];

    YTSettingsSectionItem *version = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Version")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            return @(OS_STRINGIFY(TWEAK_VERSION));
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[ps, dayanch96];

        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"About") pickerSectionTitle:LOC(@"Credits") rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:version];

    [settingsViewController setSectionItems:sectionItems forCategory:YTLiteSection title:@"YTLite" titleDescription:nil headerHidden:NO];
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == YTLiteSection) {
        [self updateYTLiteSectionWithEntry:entry];
        return;
    } %orig;
}
%end