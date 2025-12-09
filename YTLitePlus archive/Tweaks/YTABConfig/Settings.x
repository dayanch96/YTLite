#import <PSHeader/Misc.h>
#import <YouTubeHeader/UIDevice+YouTube.h>
#import <YouTubeHeader/GOOHUDManagerInternal.h>
#import <YouTubeHeader/YTAlertView.h>
#import <YouTubeHeader/YTCommonUtils.h>
#import <YouTubeHeader/YTSearchableSettingsViewController.h>
#import <YouTubeHeader/YTSettingsGroupData.h>
#import <YouTubeHeader/YTSettingsPickerViewController.h>
#import <YouTubeHeader/YTSettingsSectionItem.h>
#import <YouTubeHeader/YTSettingsSectionItemManager.h>
#import <YouTubeHeader/YTSettingsViewController.h>
#import <YouTubeHeader/YTUIUtils.h>
#import <YouTubeHeader/YTVersionUtils.h>

#define Prefix @"YTABC"
#define EnabledKey @"EnabledYTABC"
#define GroupedKey @"GroupedYTABC"
#define INCLUDED_CLASSES @"Included classes: YTGlobalConfig, YTColdConfig, YTHotConfig"
#define EXCLUDED_METHODS @"Excluded settings: android*, amsterdam*, kidsClient*, musicClient*, musicOfflineClient* and unplugged*"

#define _LOC(b, x) [b localizedStringForKey:x value:nil table:nil]
#define LOC(x) _LOC(tweakBundle, x)

static const NSInteger YTABCSection = 404;
static const NSUInteger EstimatedCategoryCount = 26;
static const NSUInteger EstimatedCategoryDivisor = 10;
static const NSUInteger LongMethodNameThreshold = 26;
static NSString * const KeyFormatString = @"%@.%@";
static NSString * const FullKeyFormatString = @"%@.%@.%@";

@interface YTSettingsSectionItemManager (YTABConfig)
- (void)updateYTABCSectionWithEntry:(id)entry;
@end

extern NSMutableDictionary <NSString *, NSMutableDictionary <NSString *, NSNumber *> *> *cache;
NSUserDefaults *defaults;
NSSet <NSString *> *allKeysSet;
BOOL allKeysNeedsUpdate = YES;
NSMutableDictionary <NSString *, NSString *> *keyCache;
NSSortDescriptor *titleSortDescriptor;
NSRegularExpression *importRegex;
NSMutableDictionary <NSString *, NSString *> *categoryCache; // Memoize category results
NSUInteger prefixLength; // Cache prefix length

BOOL tweakEnabled() {
    return [defaults boolForKey:EnabledKey];
}

BOOL groupedSettings() {
    return [defaults boolForKey:GroupedKey];
}

NSBundle *YTABCBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YTABC" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:tweakBundlePath ?: PS_ROOT_PATH_NS(@"/Library/Application Support/" Prefix ".bundle")];
    });
    return bundle;
}

NSString *getKey(NSString *method, NSString *classKey) {
    NSString *cacheKey = [NSString stringWithFormat:KeyFormatString, classKey, method];
    NSString *fullKey = keyCache[cacheKey];
    if (!fullKey) {
        fullKey = [NSString stringWithFormat:FullKeyFormatString, Prefix, classKey, method];
        keyCache[cacheKey] = fullKey;
    }
    return fullKey;
}

static NSString *getCacheKey(NSString *method, NSString *classKey) {
    return [NSString stringWithFormat:KeyFormatString, classKey, method];
}

BOOL getValue(NSString *methodKey) {
    if (!methodKey) return NO;
    if (![allKeysSet containsObject:methodKey]) {
        NSString *keyPath = [methodKey substringFromIndex:prefixLength + 1];
        id value = [cache valueForKeyPath:keyPath];
        return value ? [value boolValue] : NO;
    }
    return [defaults boolForKey:methodKey];
}

static void setValue(NSString *method, NSString *classKey, BOOL value) {
    [cache setValue:@(value) forKeyPath:getCacheKey(method, classKey)];
    [defaults setBool:value forKey:getKey(method, classKey)];
    allKeysNeedsUpdate = YES;
}

static void setValueFromImport(NSString *settingKey, BOOL value) {
    [cache setValue:@(value) forKeyPath:settingKey];
    [defaults setBool:value forKey:[NSString stringWithFormat:KeyFormatString, Prefix, settingKey]];
    allKeysNeedsUpdate = YES;
}

void updateAllKeys() {
    if (allKeysNeedsUpdate) {
        NSArray *keys = [defaults dictionaryRepresentation].allKeys;
        allKeysSet = [NSSet setWithArray:keys];
        allKeysNeedsUpdate = NO;
    }
}

static void clearCaches() {
    [keyCache removeAllObjects];
    [categoryCache removeAllObjects];
}

%group Search

%hook YTSettingsViewController

- (void)loadWithModel:(id)model fromView:(UIView *)view {
    %orig;
    @try {
        if ([[self valueForKey:@"_detailsCategoryID"] integerValue] == YTABCSection)
            [self setValue:@(YES) forKey:@"_shouldShowSearchBar"];
    } @catch (id ex) {}
}

- (void)setSectionControllers {
    %orig;
    @try {
        if (![[self valueForKey:@"_shouldShowSearchBar"] boolValue]) return;
        YTSettingsSectionController *settingsSectionController = [self settingsSectionControllers][[self valueForKey:@"_detailsCategoryID"]];
        if (settingsSectionController == nil) return;
        YTSearchableSettingsViewController *searchableVC = [self valueForKey:@"_searchableSettingsViewController"];
        [searchableVC storeCollectionViewSections:@[settingsSectionController]];
    } @catch (id ex) {}
}

%end

%end

%hook YTSettingsGroupData

- (NSArray <NSNumber *> *)orderedCategories {
    if (self.type != 1 || class_getClassMethod(objc_getClass("YTSettingsGroupData"), @selector(tweaks)))
        return %orig;
    NSMutableArray *mutableCategories = %orig.mutableCopy;
    [mutableCategories insertObject:@(YTABCSection) atIndex:0];
    return mutableCategories.copy;
}

%end

%hook YTAppSettingsPresentationData

+ (NSArray <NSNumber *> *)settingsCategoryOrder {
    NSArray <NSNumber *> *order = %orig;
    NSMutableArray <NSNumber *> *mutableOrder = [order mutableCopy];
    [mutableOrder insertObject:@(YTABCSection) atIndex:0];
    return mutableOrder.copy;
}

%end

static NSString *getCategory(char c, NSString *method) {
    // Check cache first
    NSString *cachedCategory = categoryCache[method];
    if (cachedCategory) return cachedCategory;

    NSString *category = nil;
    if (c == 'e') {
        if ([method hasPrefix:@"elements"]) category = @"elements";
        else if ([method hasPrefix:@"enable"]) category = @"enable";
    }
    else if (c == 'i') {
        if ([method hasPrefix:@"ios"]) category = @"ios";
        else if ([method hasPrefix:@"is"]) category = @"is";
    }
    else if (c == 's') {
        if ([method hasPrefix:@"shorts"]) category = @"shorts";
        else if ([method hasPrefix:@"should"]) category = @"should";
    }

    if (!category) {
        unichar uc = (unichar)c;
        category = [NSString stringWithCharacters:&uc length:1];
    }

    // Cache the result
    categoryCache[method] = category;
    return category;
}

%hook YTSettingsSectionItemManager

%new(v@:@)
- (void)updateYTABCSectionWithEntry:(id)entry {
    NSMutableArray *sectionItems = [NSMutableArray array];
    int totalSettings = 0;
    NSBundle *tweakBundle = YTABCBundle();
    BOOL isPhone = ![%c(YTCommonUtils) isIPad];
    NSString *yesText = _LOC([NSBundle mainBundle], @"settings.yes");
    NSString *cancelText = _LOC([NSBundle mainBundle], @"confirm.cancel");
    NSString *deleteText = _LOC([NSBundle mainBundle], @"search.action.delete");
    Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);
    Class YTAlertViewClass = %c(YTAlertView);

    if (tweakEnabled()) {
        // AB flags
        // Pre-calculate total method count for capacity allocation
        NSUInteger estimatedMethodCount = 0;
        for (NSString *classKey in cache) {
            estimatedMethodCount += [cache[classKey] count];
        }

        NSMutableDictionary <NSString *, NSMutableArray <YTSettingsSectionItem *> *> *properties = [NSMutableDictionary dictionaryWithCapacity:EstimatedCategoryCount];
        updateAllKeys(); // Update once before the loop
        for (NSString *classKey in cache) {
            @autoreleasepool { // Drain autorelease pool periodically to reduce peak memory
                for (NSString *method in cache[classKey]) {
                    if (method.length == 0) continue; // Safety check
                    char c = tolower([method characterAtIndex:0]);
                    NSString *category = getCategory(c, method);
                    if (![properties objectForKey:category]) properties[category] = [NSMutableArray arrayWithCapacity:estimatedMethodCount / EstimatedCategoryDivisor];
                    NSString *methodKey = getKey(method, classKey); // Cache the key
                    BOOL modified = [allKeysSet containsObject:methodKey];
                    NSString *modifiedTitle = modified ? [NSString stringWithFormat:@"%@ *", method] : method;
                    YTSettingsSectionItem *methodSwitch = [YTSettingsSectionItemClass switchItemWithTitle:modifiedTitle
                        titleDescription:isPhone && method.length > LongMethodNameThreshold ? modifiedTitle : nil
                        accessibilityIdentifier:nil
                        switchOn:getValue(methodKey)
                        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                            setValue(method, classKey, enabled);
                            return YES;
                        }
                        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                            NSString *content = [NSString stringWithFormat:KeyFormatString, classKey, method];
                            YTAlertView *alertView = [YTAlertViewClass confirmationDialog];
                            alertView.title = method;
                            alertView.subtitle = content;
                            [alertView addTitle:LOC(@"COPY_TO_CLIPBOARD") withAction:^{
                                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                pasteboard.string = content;
                                [[%c(GOOHUDManagerInternal) sharedInstance] showMessageMainThread:[%c(YTHUDMessage) messageWithText:LOC(@"COPIED_TO_CLIPBOARD")]];
                            }];
                            updateAllKeys();
                            NSString *key = getKey(method, classKey);
                            if ([allKeysSet containsObject:key]) {
                                [alertView addTitle:deleteText withAction:^{
                                    [defaults removeObjectForKey:key];
                                    allKeysNeedsUpdate = YES;
                                    updateAllKeys();
                                }];
                            }
                            [alertView addCancelButton:NULL];
                            [alertView show];
                            return NO;
                        }
                        settingItemId:0];
                    [properties[category] addObject:methodSwitch];
                }
            } // @autoreleasepool
        }
        YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];
        BOOL grouped = groupedSettings();
        for (NSString *category in properties) {
            NSMutableArray <YTSettingsSectionItem *> *rows = properties[category];
            totalSettings += rows.count;
            if (grouped) {
                [rows sortUsingDescriptors:@[titleSortDescriptor]];
                NSString *shortTitle = [NSString stringWithFormat:@"\"%@\" (%ld)", category, rows.count];
                NSString *title = [NSString stringWithFormat:@"%@ %@", LOC(@"SETTINGS_START_WITH"), shortTitle];
                YTSettingsSectionItem *headerItem = [YTSettingsSectionItemClass itemWithTitle:title accessibilityIdentifier:nil detailTextBlock:nil selectBlock:nil];
                headerItem.enabled = NO;
                [rows insertObject:headerItem atIndex:0];

                YTSettingsSectionItem *sectionItem = [YTSettingsSectionItemClass itemWithTitle:title accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:shortTitle pickerSectionTitle:nil rows:rows selectedItemIndex:0 parentResponder:[self parentResponder]];
                    [settingsViewController pushViewController:picker];
                    return YES;
                }];
                [sectionItems addObject:sectionItem];
            } else {
                [sectionItems addObjectsFromArray:rows];
            }
        }
        [sectionItems sortUsingDescriptors:@[titleSortDescriptor]];

        // Import settings
        YTSettingsSectionItem *import = [YTSettingsSectionItemClass itemWithTitle:LOC(@"IMPORT_SETTINGS")
            titleDescription:[NSString stringWithFormat:LOC(@"IMPORT_SETTINGS_DESC"), @"YT(Cold|Hot|Global)Config.*: (0|1)"]
            accessibilityIdentifier:nil
            detailTextBlock:nil
            selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                NSArray *lines = [pasteboard.string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                NSMutableDictionary *importedSettings = [NSMutableDictionary dictionaryWithCapacity:lines.count];
                NSMutableArray *reportedSettings = [NSMutableArray arrayWithCapacity:lines.count];

                for (NSString *line in lines) {
                    NSTextCheckingResult *match = [importRegex firstMatchInString:line options:0 range:NSMakeRange(0, [line length])];
                    if (!match) continue;
                    NSString *key = [line substringWithRange:[match rangeAtIndex:1]];
                    id cacheValue = [cache valueForKeyPath:key];
                    if (cacheValue == nil) continue;
                    NSString *valueString = [line substringWithRange:[match rangeAtIndex:2]];
                    int integerValue = [valueString integerValue];
                    if (integerValue == 0 && ![cacheValue boolValue]) continue;
                    if (integerValue == 1 && [cacheValue boolValue]) continue;
                    importedSettings[key] = @(integerValue);
                    [reportedSettings addObject:[NSString stringWithFormat:@"%@: %d", key, integerValue]];
                }

                if (reportedSettings.count == 0) {
                    YTAlertView *alertView = [YTAlertViewClass infoDialog];
                    alertView.title = LOC(@"SETTINGS_TO_IMPORT");
                    alertView.subtitle = LOC(@"NOTHING_TO_IMPORT");
                    [alertView show];
                    return NO;
                }

                [reportedSettings insertObject:[NSString stringWithFormat:LOC(@"SETTINGS_TO_IMPORT_DESC"), reportedSettings.count] atIndex:0];

                YTAlertView *alertView = [YTAlertViewClass confirmationDialogWithAction:^{
                    for (NSString *key in importedSettings) {
                        setValueFromImport(key, [importedSettings[key] boolValue]);
                    }
                    updateAllKeys();
                } actionTitle:LOC(@"IMPORT")];
                alertView.title = LOC(@"SETTINGS_TO_IMPORT");
                alertView.subtitle = [reportedSettings componentsJoinedByString:@"\n"];
                [alertView show];
                return YES;
            }];
        [sectionItems insertObject:import atIndex:0];

        // Copy current settings
        YTSettingsSectionItem *copyAll = [YTSettingsSectionItemClass itemWithTitle:LOC(@"COPY_CURRENT_SETTINGS")
            titleDescription:LOC(@"COPY_CURRENT_SETTINGS_DESC")
            accessibilityIdentifier:nil
            detailTextBlock:nil
            selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                // Pre-calculate total count for capacity
                NSUInteger totalCount = 0;
                for (NSString *classKey in cache) {
                    totalCount += [cache[classKey] count];
                }
                NSMutableArray *content = [NSMutableArray arrayWithCapacity:totalCount + 5]; // +5 for header items
                for (NSString *classKey in cache) {
                    [cache[classKey] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *value, BOOL* stop) {
                        [content addObject:[NSString stringWithFormat:@"%@.%@: %d", classKey, key, [value boolValue]]];
                    }];
                }
                [content sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                [content insertObject:[NSString stringWithFormat:@"Device model: %@", [UIDevice machineName]] atIndex:0];
                [content insertObject:[NSString stringWithFormat:@"App version: %@", [%c(YTVersionUtils) appVersion]] atIndex:0];
                [content insertObject:EXCLUDED_METHODS atIndex:0];
                [content insertObject:INCLUDED_CLASSES atIndex:0];
                [content insertObject:[NSString stringWithFormat:@"YTABConfig version: %@", @(OS_STRINGIFY(TWEAK_VERSION))] atIndex:0];
                pasteboard.string = [content componentsJoinedByString:@"\n"];
                [[%c(GOOHUDManagerInternal) sharedInstance] showMessageMainThread:[%c(YTHUDMessage) messageWithText:LOC(@"COPIED_TO_CLIPBOARD")]];
                return YES;
            }];
        [sectionItems insertObject:copyAll atIndex:0];

        // View modified settings
        YTSettingsSectionItem *modified = [YTSettingsSectionItemClass itemWithTitle:LOC(@"VIEW_MODIFIED_SETTINGS")
            titleDescription:LOC(@"VIEW_MODIFIED_SETTINGS_DESC")
            accessibilityIdentifier:nil
            detailTextBlock:nil
            selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                updateAllKeys();
                // Filter keys with prefix using NSPredicate for better performance
                NSPredicate *prefixPredicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", Prefix];
                NSSet *filteredKeys = [allKeysSet filteredSetUsingPredicate:prefixPredicate];

                NSMutableDictionary <NSString *, NSString *> *modifiedKeysMap = [NSMutableDictionary dictionaryWithCapacity:[filteredKeys count]];

                for (NSString *key in filteredKeys) {
                    NSString *displayKey = [key substringFromIndex:prefixLength + 1];
                    modifiedKeysMap[displayKey] = key;
                }

                NSArray *sortedDisplayKeys = [[modifiedKeysMap allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                NSMutableArray <YTSettingsSectionItem *> *modifiedRows = [NSMutableArray arrayWithCapacity:sortedDisplayKeys.count + 2]; // +2 for copy and info items

                // Copy to clipboard item
                YTSettingsSectionItem *copyItem = [YTSettingsSectionItemClass itemWithTitle:LOC(@"COPY_TO_CLIPBOARD")
                    titleDescription:nil
                    accessibilityIdentifier:nil
                    detailTextBlock:nil
                    selectBlock:^BOOL (YTSettingsCell *copyCell, NSUInteger arg1) {
                        NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:sortedDisplayKeys.count];
                        for (NSString *displayKey in sortedDisplayKeys) {
                            NSString *fullKey = modifiedKeysMap[displayKey];
                            [contentArray addObject:[NSString stringWithFormat:@"%@: %d", displayKey, [defaults boolForKey:fullKey]]];
                        }
                        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                        pasteboard.string = [contentArray componentsJoinedByString:@"\n"];
                        [[%c(GOOHUDManagerInternal) sharedInstance] showMessageMainThread:[%c(YTHUDMessage) messageWithText:LOC(@"COPIED_TO_CLIPBOARD")]];
                        return YES;
                    }];
                [modifiedRows addObject:copyItem];

                // Remove removed settings item
                NSMutableArray *removedFullKeys = [NSMutableArray array];
                for (NSString *displayKey in sortedDisplayKeys) {
                    NSArray *components = [displayKey componentsSeparatedByString:@"."];
                    if (components.count > 1) {
                        NSString *classKey = components[0];
                        NSString *methodKey = [displayKey substringFromIndex:classKey.length + 1];
                        if (!cache[classKey][methodKey]) {
                            [removedFullKeys addObject:modifiedKeysMap[displayKey]];
                        }
                    }
                }

                if (removedFullKeys.count > 0) {
                    YTSettingsSectionItem *removeRemovedItem = [YTSettingsSectionItemClass itemWithTitle:LOC(@"REMOVE_REMOVED_SETTINGS")
                        titleDescription:nil
                        accessibilityIdentifier:nil
                        detailTextBlock:nil
                        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                            YTAlertView *alertView = [YTAlertViewClass confirmationDialogWithAction:^{
                                for (NSString *key in removedFullKeys) {
                                    [defaults removeObjectForKey:key];
                                }
                                allKeysNeedsUpdate = YES;
                                updateAllKeys();
                                [settingsViewController.navigationController popViewControllerAnimated:YES];
                            } actionTitle:deleteText];
                            alertView.title = LOC(@"REMOVE_REMOVED_SETTINGS");
                            alertView.subtitle = [NSString stringWithFormat:LOC(@"REMOVE_REMOVED_SETTINGS_DESC"), (long)removedFullKeys.count];
                            [alertView show];
                            return YES;
                        }];
                    [modifiedRows addObject:removeRemovedItem];
                }

                // General information item
                NSString *infoDescription = [NSString stringWithFormat:LOC(@"TOTAL_MODIFIED_SETTINGS"), sortedDisplayKeys.count];
                YTSettingsSectionItem *infoItem = [YTSettingsSectionItemClass itemWithTitle:nil
                    titleDescription:infoDescription
                    accessibilityIdentifier:nil
                    detailTextBlock:nil
                    selectBlock:nil];
                infoItem.enabled = NO;
                [modifiedRows addObject:infoItem];

                // Boolean toggles for each modified setting
                for (NSString *displayKey in sortedDisplayKeys) {
                    NSString *fullKey = modifiedKeysMap[displayKey];
                    NSArray *components = [displayKey componentsSeparatedByString:@"."];
                    NSString *method = components.count > 1 ? components[1] : displayKey;

                    BOOL isRemoved = NO;
                    if (components.count > 1) {
                        NSString *classKey = components[0];
                        NSString *methodKey = [displayKey substringFromIndex:classKey.length + 1];
                        if (!cache[classKey][methodKey])
                            isRemoved = YES;
                    }

                    NSString *title = isRemoved ? [NSString stringWithFormat:@"%@ %@", displayKey, [tweakBundle localizedStringForKey:@"REMOVED" value:@"(Removed)" table:nil]] : displayKey;
                    YTSettingsSectionItem *toggleItem = [YTSettingsSectionItemClass switchItemWithTitle:title
                        titleDescription:isPhone && displayKey.length > 26 ? displayKey : nil
                        accessibilityIdentifier:nil
                        switchOn:[defaults boolForKey:fullKey]
                        switchBlock:^BOOL (YTSettingsCell *toggleCell, BOOL enabled) {
                            [defaults setBool:enabled forKey:fullKey];
                            if (components.count > 1) {
                                [cache setValue:@(enabled) forKeyPath:displayKey];
                            }
                            return YES;
                        }
                        selectBlock:^BOOL (YTSettingsCell *toggleCell, NSUInteger arg1) {
                            YTAlertView *alertView = [YTAlertViewClass confirmationDialog];
                            alertView.title = method;
                            alertView.subtitle = displayKey;
                            [alertView addTitle:LOC(@"COPY_TO_CLIPBOARD") withAction:^{
                                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                pasteboard.string = displayKey;
                                [[%c(GOOHUDManagerInternal) sharedInstance] showMessageMainThread:[%c(YTHUDMessage) messageWithText:LOC(@"COPIED_TO_CLIPBOARD")]];
                            }];
                            [alertView addTitle:deleteText withAction:^{
                                [defaults removeObjectForKey:fullKey];
                                allKeysNeedsUpdate = YES;
                                updateAllKeys();
                            }];
                            [alertView addCancelButton:NULL];
                            [alertView show];
                            return NO;
                        }
                        settingItemId:0];
                    toggleItem.enabled = !isRemoved;
                    [modifiedRows addObject:toggleItem];
                }

                NSString *navTitle = LOC(@"MODIFIED_SETTINGS_TITLE");
                YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:navTitle pickerSectionTitle:nil rows:modifiedRows selectedItemIndex:0 parentResponder:[self parentResponder]];
                [settingsViewController pushViewController:picker];
                return YES;
            }];
        [sectionItems insertObject:modified atIndex:0];

        // Reset and kill
        YTSettingsSectionItem *reset = [YTSettingsSectionItemClass itemWithTitle:LOC(@"RESET_KILL")
            titleDescription:LOC(@"RESET_KILL_DESC")
            accessibilityIdentifier:nil
            detailTextBlock:nil
            selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                YTAlertView *alertView = [YTAlertViewClass confirmationDialogWithAction:^{
                    updateAllKeys();
                    NSPredicate *prefixPredicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", Prefix];
                    NSSet *keysToDelete = [allKeysSet filteredSetUsingPredicate:prefixPredicate];
                    for (NSString *key in keysToDelete) {
                        [defaults removeObjectForKey:key];
                    }
                    exit(0);
                } actionTitle:yesText];
                alertView.title = LOC(@"WARNING");
                alertView.subtitle = LOC(@"APPLY_DESC");
                [alertView show];
                return YES;
            }];
        [sectionItems insertObject:reset atIndex:0];

        // Grouped settings
        YTSettingsSectionItem *group = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"GROUPED")
            titleDescription:nil
            accessibilityIdentifier:nil
            switchOn:groupedSettings()
            switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                YTAlertView *alertView = [YTAlertViewClass confirmationDialogWithAction:^{
                        [defaults setBool:enabled forKey:GroupedKey];
                        exit(0);
                    }
                    actionTitle:yesText
                    cancelAction:^{
                        [cell setSwitchOn:!enabled animated:YES];
                        [defaults setBool:!enabled forKey:GroupedKey];
                    }
                    cancelTitle:cancelText];
                alertView.title = LOC(@"WARNING");
                alertView.subtitle = LOC(@"APPLY_DESC");
                [alertView show];
                return YES;
            }
            settingItemId:0];
        [sectionItems insertObject:group atIndex:0];
    }

    // Open megathread
    YTSettingsSectionItem *thread = [YTSettingsSectionItemClass itemWithTitle:LOC(@"OPEN_MEGATHREAD")
        titleDescription:LOC(@"OPEN_MEGATHREAD_DESC")
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/PoomSmart/YTABConfig/discussions"]];
        }];
    [sectionItems insertObject:thread atIndex:0];

    // Killswitch
    YTSettingsSectionItem *master = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"ENABLED")
        titleDescription:LOC(@"ENABLED_DESC")
        accessibilityIdentifier:nil
        switchOn:tweakEnabled()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [defaults setBool:enabled forKey:EnabledKey];
            YTAlertView *alertView = [YTAlertViewClass confirmationDialogWithAction:^{ exit(0); }
                actionTitle:yesText
                cancelAction:^{
                    [cell setSwitchOn:!enabled animated:YES];
                    [defaults setBool:!enabled forKey:EnabledKey];
                }
                cancelTitle:cancelText];
            alertView.title = LOC(@"WARNING");
            alertView.subtitle = LOC(@"APPLY_DESC");
            [alertView show];
            return YES;
        }
        settingItemId:0];
    [sectionItems insertObject:master atIndex:0];

    if (tweakEnabled()) {
        NSString *titleDescription =[NSString stringWithFormat:@"YTABConfig %@, %d feature flags.", @(OS_STRINGIFY(TWEAK_VERSION)), totalSettings];
        YTSettingsSectionItem *info = [YTSettingsSectionItemClass itemWithTitle:nil
            titleDescription:titleDescription
            accessibilityIdentifier:nil
            detailTextBlock:nil
            selectBlock:nil];
        info.enabled = NO;
        [sectionItems insertObject:info atIndex:0];
    }

    YTSettingsViewController *delegate = [self valueForKey:@"_dataDelegate"];
    NSString *title = @"A/B";
    if ([delegate respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)]) {
        YTIIcon *icon = [%c(YTIIcon) new];
        icon.iconType = YT_EXPERIMENT;
        [delegate setSectionItems:sectionItems
            forCategory:YTABCSection
            title:title
            icon:icon
            titleDescription:nil
            headerHidden:NO];
    } else
        [delegate setSectionItems:sectionItems
            forCategory:YTABCSection
            title:title
            titleDescription:nil
            headerHidden:NO];
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == YTABCSection) {
        [self updateYTABCSectionWithEntry:entry];
        return;
    }
    %orig;
}

%end

void SearchHook() {
    %init(Search);
}

%ctor {
    defaults = [NSUserDefaults standardUserDefaults];
    prefixLength = [Prefix length];
    keyCache = [NSMutableDictionary new];
    categoryCache = [NSMutableDictionary new];
    titleSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    importRegex = [NSRegularExpression regularExpressionWithPattern:@"^(YT.*Config\\..*):\\s*(\\d)$" options:0 error:nil];

    // Clear caches on memory warning to reduce memory footprint
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
        clearCaches();
    }];

    %init;
}
