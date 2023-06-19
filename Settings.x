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

static YTSettingsSectionItem *createSwitchItem(NSString *title, NSString *titleDescription, NSString *key, BOOL *value, id selfObject) {
    Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);
    YTSettingsSectionItem *item = [YTSettingsSectionItemClass switchItemWithTitle:title
        titleDescription:titleDescription
        accessibilityIdentifier:nil
        switchOn:*value
        switchBlock:^BOOL(YTSettingsCell *cell, BOOL enabled) {
            [selfObject updatePrefsForKey:key enabled:enabled];
            return YES;
        }
        settingItemId:0];
    return item;
}

%new(v@:@)
- (void)updateYTLiteSectionWithEntry:(id)entry {
    NSMutableArray *sectionItems = [NSMutableArray array];
    Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);
    YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];
    id selfObject = self;

    YTSettingsSectionItem *general = [YTSettingsSectionItemClass itemWithTitle:LOC(@"General")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            return @"‣";
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
            createSwitchItem(LOC(@"RemoveAds"), LOC(@"RemoveAdsDesc"), @"noAds", &kNoAds, selfObject),
            createSwitchItem(LOC(@"BackgroundPlayback"), LOC(@"BackgroundPlaybackDesc"), @"backgroundPlayback", &kBackgroundPlayback, selfObject)
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
            createSwitchItem(LOC(@"RemoveCast"), LOC(@"RemoveCastDesc"), @"noCast", &kNoCast, selfObject),
            createSwitchItem(LOC(@"RemoveNotifications"), LOC(@"RemoveNotificationsDesc"), @"removeNotifsButton", &kNoNotifsButton, selfObject),
            createSwitchItem(LOC(@"RemoveSearch"), LOC(@"RemoveSearchDesc"), @"removeSearchButton", &kNoSearchButton, selfObject)
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
            createSwitchItem(LOC(@"RemoveLabels"), LOC(@"RemoveLabelsDesc"), @"removeLabels", &kRemoveLabels, selfObject),
            createSwitchItem(LOC(@"HideShortsTab"), LOC(@"HideShortsTabDesc"), @"removeShorts", &kRemoveShorts, selfObject),
            createSwitchItem(LOC(@"HideSubscriptionsTab"), LOC(@"HideSubscriptionsTabDesc"), @"removeSubscriptions", &kRemoveSubscriptions, selfObject),
            createSwitchItem(LOC(@"HideUploadButton"), LOC(@"HideUploadButtonDesc"), @"removeUploads", &kRemoveUploads, selfObject),
            createSwitchItem(LOC(@"HideLibraryTab"), LOC(@"HideLibraryTabDesc"), @"removeLibrary", &kRemoveLibrary, selfObject)
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
