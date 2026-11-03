#import "YTLite.h"

@interface YTSettingsSectionItemManager (YTLite)
- (void)updateYTLiteSectionWithEntry:(id)entry;
@end

static const NSInteger YTLiteSection = 789;
FOUNDATION_EXPORT NSArray <NSString *> *YTLSponsorBlockCategories(void);
static const char kYTLSettingKey;

#import "YTLFeatureMap.h"

static BOOL YTLFeatureAvailable(NSString *key) {
    static NSDictionary <NSString *, NSArray <NSString *> *> *gates;
    static NSMutableDictionary <NSString *, NSNumber *> *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gates = YTLFeatureGates();
        cache = [NSMutableDictionary dictionary];
    });

    NSArray <NSString *> *requirements = gates[key];
    if (requirements.count == 0) return YES;

    NSNumber *cached = cache[key];
    if (cached) return cached.boolValue;

    BOOL available = NO;
    for (NSString *requirement in requirements) {
        NSArray <NSString *> *parts = [requirement componentsSeparatedByString:@" "];
        if (parts.count != 2 || [parts[1] length] < 2) continue;

        Class cls = YTLClass(parts[0]);
        SEL sel = NSSelectorFromString([parts[1] substringFromIndex:1]);
        BOOL isClassMethod = [parts[1] hasPrefix:@"+"];

        if (cls && (isClassMethod ? [cls respondsToSelector:sel] : [cls instancesRespondToSelector:sel])) {
            available = YES;
            break;
        }
    }

    cache[key] = @(available);
    return available;
}

static NSString *SafeLabel(NSArray <NSString *> *labels, NSString *key) {
    NSInteger index = ytlInt(key);
    return (index >= 0 && index < (NSInteger)labels.count) ? labels[index] : labels.firstObject;
}

static NSString *cachedCacheSize = nil;
static BOOL isComputingCacheSize = NO;

static NSString *ComputeCacheSize() {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:cachePath error:nil];

    unsigned long long int folderSize = 0;
    for (NSString *fileName in filesArray) {
        NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        if ([fileAttributes.fileType isEqualToString:NSFileTypeRegular]) folderSize += [fileAttributes fileSize];
    }

    NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
    formatter.countStyle = NSByteCountFormatterCountStyleFile;

    return [formatter stringFromByteCount:folderSize];
}

static NSString *GetCacheSize(YTSettingsViewController *settingsViewController) {
    if (!isComputingCacheSize) {
        isComputingCacheSize = YES;
        __weak YTSettingsViewController *weakSettings = settingsViewController;
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
            NSString *size = ComputeCacheSize();
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL changed = ![size isEqualToString:cachedCacheSize];
                cachedCacheSize = size;
                isComputingCacheSize = NO;
                if (changed) [weakSettings reloadData];
            });
        });
    }

    return cachedCacheSize ?: @"…";
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

%hook YTSettingsCell
- (void)layoutSubviews {
    %orig;

    BOOL isYTLite = [self.accessibilityIdentifier isEqualToString:@"YTLiteSectionItem"];
    YTTouchFeedbackController *feedback = YTLValue(self, @"_touchFeedbackController");
    ABCSwitch *abcSwitch = YTLValue(self, @"_switch");

    if (isYTLite) {
        feedback.feedbackColor = [UIColor colorWithRed:0.75 green:0.50 blue:0.90 alpha:1.0];
        abcSwitch.onTintColor = [UIColor colorWithRed:0.75 green:0.50 blue:0.90 alpha:1.0];
    }
}
%end

%hook YTSettingsSectionItemManager
%new
- (YTSettingsSectionItem *)switchWithTitle:(NSString *)title key:(NSString *)key {
    Class YTSettingsSectionItemClass = YTLClass(@"YTSettingsSectionItem");
    Class YTAlertViewClass = YTLClass(@"YTAlertView");
    NSString *titleDesc = [NSString stringWithFormat:@"%@Desc", title];

    YTSettingsSectionItem *item = [YTSettingsSectionItemClass switchItemWithTitle:LOC(title)
    titleDescription:LOC(titleDesc)
    accessibilityIdentifier:@"YTLiteSectionItem"
    switchOn:ytlBool(key)
    switchBlock:^BOOL(YTSettingsCell *cell, BOOL enabled) {
        if ([key isEqualToString:@"shortsOnlyMode"] && enabled) {
            YTAlertView *alertView = [YTAlertViewClass confirmationDialogWithAction:^{
                ytlSetBool(enabled, @"shortsOnlyMode");
            }
            actionTitle:LOC(@"Yes")
            cancelAction:^{
                [cell setSwitchOn:!enabled animated:YES];
            }
            cancelTitle:LOC(@"No")];
            alertView.title = LOC(@"Warning");
            alertView.subtitle = LOC(@"ShortsOnlyWarning");
            [alertView show];
        }

        else {
            ytlSetBool(enabled, key);

            if ([key isEqualToString:@"shortsOnlyMode"]) {
                UIViewController *rootVC = [[[UIApplication sharedApplication] delegate] window].rootViewController;
                if ([rootVC isKindOfClass:YTLClass(@"YTAppViewController")]) [(YTAppViewController *)rootVC showPivotBar];
            }

            NSArray *keys = @[@"removeLabels", @"removeIndicators", @"reExplore", @"addExplore", @"removeShorts", @"removeSubscriptions", @"removeUploads", @"removeLibrary"];
            if ([keys containsObject:key]) {
                [[[YTLClass(@"YTHeaderContentComboViewController") alloc] init] refreshPivotBar];
            }
        }

        return YES;
    }
    settingItemId:0];

    objc_setAssociatedObject(item, &kYTLSettingKey, key, OBJC_ASSOCIATION_COPY_NONATOMIC);
    return item;
}

%new
- (NSArray <YTSettingsSectionItem *> *)availableRows:(NSArray <YTSettingsSectionItem *> *)rows {
    NSIndexSet *indexes = [rows indexesOfObjectsPassingTest:^BOOL(YTSettingsSectionItem *item, NSUInteger idx, BOOL *stop) {
        NSString *key = objc_getAssociatedObject(item, &kYTLSettingKey);
        return !key || YTLFeatureAvailable(key);
    }];
    return [rows objectsAtIndexes:indexes];
}

%new
- (YTSettingsSectionItem *)linkWithTitle:(NSString *)title description:(NSString *)description link:(NSString *)link {
    return [YTLClass(@"YTSettingsSectionItem") itemWithTitle:title
    titleDescription:description
    accessibilityIdentifier:@"YTLiteSectionItem"
    detailTextBlock:nil
    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return [YTLClass(@"YTUIUtils") openURL:[NSURL URLWithString:link]];
    }];
}

%new(v@:@)
- (void)updateYTLiteSectionWithEntry:(id)entry {
    NSMutableArray *sectionItems = [NSMutableArray array];
    Class YTSettingsSectionItemClass = YTLClass(@"YTSettingsSectionItem");
    YTSettingsViewController *settingsViewController = YTLValue(self, @"_settingsViewControllerDelegate");

    YTSettingsSectionItem *space = [YTLClass(@"YTSettingsSectionItem") itemWithTitle:nil accessibilityIdentifier:@"YTLiteSectionItem" detailTextBlock:nil selectBlock:nil];

    YTSettingsSectionItem *general = [YTSettingsSectionItemClass itemWithTitle:LOC(@"General")
        accessibilityIdentifier:@"YTLiteSectionItem"
        detailTextBlock:^NSString *() {
            return @"‣";
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
            [self switchWithTitle:@"RemoveAds" key:@"noAds"],
            [self switchWithTitle:@"BackgroundPlayback" key:@"backgroundPlayback"],
            [self switchWithTitle:@"OLEDMode" key:@"oledMode"],
            [self switchWithTitle:@"AutoClearCache" key:@"autoClearCache"],
            [self switchWithTitle:@"DownloadButton" key:@"downloadButton"]
        ];

        YTSettingsPickerViewController *picker = [[YTLClass(@"YTSettingsPickerViewController") alloc] initWithNavTitle:LOC(@"General") pickerSectionTitle:nil rows:[self availableRows:rows] selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];

    [sectionItems addObject:general];

    YTSettingsSectionItem *sponsorBlock = [YTSettingsSectionItemClass itemWithTitle:@"SponsorBlock"
        accessibilityIdentifier:@"YTLiteSectionItem"
        detailTextBlock:^NSString *() {
            return ytlBool(@"sponsorBlock") ? @"‣" : LOC(@"Disabled");
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSMutableArray <YTSettingsSectionItem *> *rows = [NSMutableArray arrayWithObjects:
                [self switchWithTitle:@"SponsorBlock" key:@"sponsorBlock"],
                [self switchWithTitle:@"SBNotify" key:@"sbNotify"],
                nil];
            for (NSString *category in YTLSponsorBlockCategories()) {
                [rows addObject:[self switchWithTitle:[@"SB_" stringByAppendingString:category] key:[@"sb_" stringByAppendingString:category]]];
            }

            YTSettingsPickerViewController *picker = [[YTLClass(@"YTSettingsPickerViewController") alloc] initWithNavTitle:@"SponsorBlock" pickerSectionTitle:nil rows:[self availableRows:rows] selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];

    [sectionItems addObject:sponsorBlock];

    YTSettingsSectionItem *navbar = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Navbar")
    accessibilityIdentifier:@"YTLiteSectionItem"
    detailTextBlock:^NSString *() {
        return @"‣";
    }
    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            [self switchWithTitle:@"RemoveCast" key:@"noCast"],
            [self switchWithTitle:@"RemoveNotifications" key:@"noNotifsButton"],
            [self switchWithTitle:@"RemoveSearch" key:@"noSearchButton"],
            [self switchWithTitle:@"RemoveVoiceSearch" key:@"noVoiceSearchButton"]
        ];

        if (ytlBool(@"advancedMode")) {
            rows = [rows arrayByAddingObjectsFromArray:@[
                [self switchWithTitle:@"StickyNavbar" key:@"stickyNavbar"],
                [self switchWithTitle:@"NoSubbar" key:@"noSubbar"],
                [self switchWithTitle:@"NoYTLogo" key:@"noYTLogo"],
                [self switchWithTitle:@"PremiumYTLogo" key:@"premiumYTLogo"]
            ]];
        }

        YTSettingsPickerViewController *picker = [[YTLClass(@"YTSettingsPickerViewController") alloc] initWithNavTitle:LOC(@"Navbar") pickerSectionTitle:nil rows:[self availableRows:rows] selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];

    [sectionItems addObject:navbar];

    if (ytlBool(@"advancedMode")) {
        YTSettingsSectionItem *overlay = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Overlay")
        accessibilityIdentifier:@"YTLiteSectionItem"
        detailTextBlock:^NSString *() {
            return @"‣";
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [self switchWithTitle:@"HideAutoplay" key:@"hideAutoplay"],
                [self switchWithTitle:@"HideSubs" key:@"hideSubs"],
                [self switchWithTitle:@"NoHUDMsgs" key:@"noHUDMsgs"],
                [self switchWithTitle:@"HidePrevNext" key:@"hidePrevNext"],
                [self switchWithTitle:@"ReplacePrevNext" key:@"replacePrevNext"],
                [self switchWithTitle:@"NoDarkBg" key:@"noDarkBg"],
                [self switchWithTitle:@"NoEndScreenCards" key:@"endScreenCards"],
                [self switchWithTitle:@"NoFullscreenActions" key:@"noFullscreenActions"],
                [self switchWithTitle:@"PersistentProgressBar" key:@"persistentProgressBar"],
                [self switchWithTitle:@"StockVolumeHUD" key:@"stockVolumeHUD"],
                [self switchWithTitle:@"NoRelatedVids" key:@"noRelatedVids"],
                [self switchWithTitle:@"NoPromotionCards" key:@"noPromotionCards"],
                [self switchWithTitle:@"NoWatermarks" key:@"noWatermarks"],
                [self switchWithTitle:@"VideoEndTime" key:@"videoEndTime"],
                [self switchWithTitle:@"24hrFormat" key:@"24hrFormat"]
            ];

            YTSettingsPickerViewController *picker = [[YTLClass(@"YTSettingsPickerViewController") alloc] initWithNavTitle:LOC(@"Overlay") pickerSectionTitle:nil rows:[self availableRows:rows] selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];

        [sectionItems addObject:overlay];

        YTSettingsSectionItem *player = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Player")
        accessibilityIdentifier:@"YTLiteSectionItem"
        detailTextBlock:^NSString *() {
            return @"‣";
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [self switchWithTitle:@"Miniplayer" key:@"miniplayer"],
                [self switchWithTitle:@"PortraitFullscreen" key:@"portraitFullscreen"],
                [self switchWithTitle:@"CopyWithTimestamp" key:@"copyWithTimestamp"],
                [self switchWithTitle:@"DisableAutoplay" key:@"disableAutoplay"],
                [self switchWithTitle:@"DisableAutoCaptions" key:@"disableAutoCaptions"],
                [self switchWithTitle:@"NoContentWarning" key:@"noContentWarning"],
                [self switchWithTitle:@"ClassicQuality" key:@"classicQuality"],
                [self switchWithTitle:@"ExtraSpeedOptions" key:@"extraSpeedOptions"],
                [self switchWithTitle:@"RememberPlaybackSpeed" key:@"rememberPlaybackSpeed"],
                [self switchWithTitle:@"DontSnap2Chapter" key:@"dontSnapToChapter"],
                [self switchWithTitle:@"NoTwoFingerSnapToChapter" key:@"noTwoFingerSnapToChapter"],
                [self switchWithTitle:@"PauseOnOverlay" key:@"pauseOnOverlay"],
                [self switchWithTitle:@"RedProgressBar" key:@"redProgressBar"],
                [self switchWithTitle:@"NoPlayerRemixButton" key:@"noPlayerRemixButton"],
                [self switchWithTitle:@"NoPlayerClipButton" key:@"noPlayerClipButton"],
                [self switchWithTitle:@"NoPlayerDownloadButton" key:@"noPlayerDownloadButton"],
                [self switchWithTitle:@"NoHints" key:@"noHints"],
                [self switchWithTitle:@"NoFreeZoom" key:@"noFreeZoom"],
                [self switchWithTitle:@"AutoFullscreen" key:@"autoFullscreen"],
                [self switchWithTitle:@"ExitFullscreen" key:@"exitFullscreen"],
                [self switchWithTitle:@"NoDoubleTap2Seek" key:@"noDoubleTapToSeek"]
            ];

            YTSettingsPickerViewController *picker = [[YTLClass(@"YTSettingsPickerViewController") alloc] initWithNavTitle:LOC(@"Player") pickerSectionTitle:nil rows:[self availableRows:rows] selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];

        [sectionItems addObject:player];

        YTSettingsSectionItem *shorts = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Shorts")
        accessibilityIdentifier:@"YTLiteSectionItem"
        detailTextBlock:^NSString *() {
            return @"‣";
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [self switchWithTitle:@"ShortsOnlyMode" key:@"shortsOnlyMode"],
                [self switchWithTitle:@"AutoSkipShorts" key:@"autoSkipShorts"],
                [self switchWithTitle:@"HideShorts" key:@"hideShorts"],
                [self switchWithTitle:@"ShortsProgress" key:@"shortsProgress"],
                [self switchWithTitle:@"PinchToFullscreenShorts" key:@"pinchToFullscreenShorts"],
                [self switchWithTitle:@"ShortsToRegular" key:@"shortsToRegular"],
                [self switchWithTitle:@"ResumeShorts" key:@"resumeShorts"],
                [self switchWithTitle:@"HideShortsLogo" key:@"hideShortsLogo"],
                [self switchWithTitle:@"HideShortsSearch" key:@"hideShortsSearch"],
                [self switchWithTitle:@"HideShortsCamera" key:@"hideShortsCamera"],
                [self switchWithTitle:@"HideShortsMore" key:@"hideShortsMore"],
                [self switchWithTitle:@"HideShortsSubscriptions" key:@"hideShortsSubscriptions"],
                [self switchWithTitle:@"HideShortsLike" key:@"hideShortsLike"],
                [self switchWithTitle:@"HideShortsDislike" key:@"hideShortsDislike"],
                [self switchWithTitle:@"HideShortsComments" key:@"hideShortsComments"],
                [self switchWithTitle:@"HideShortsRemix" key:@"hideShortsRemix"],
                [self switchWithTitle:@"HideShortsShare" key:@"hideShortsShare"],
                [self switchWithTitle:@"HideShortsAvatars" key:@"hideShortsAvatars"],
                [self switchWithTitle:@"HideShortsThanks" key:@"hideShortsThanks"],
                [self switchWithTitle:@"HideShortsSource" key:@"hideShortsSource"],
                [self switchWithTitle:@"HideShortsChannelName" key:@"hideShortsChannelName"],
                [self switchWithTitle:@"HideShortsDescription" key:@"hideShortsDescription"],
                [self switchWithTitle:@"HideShortsAudioTrack" key:@"hideShortsAudioTrack"],
                [self switchWithTitle:@"NoPromotionCards" key:@"hideShortsPromoCards"]
            ];

            YTSettingsPickerViewController *picker = [[YTLClass(@"YTSettingsPickerViewController") alloc] initWithNavTitle:LOC(@"Shorts") pickerSectionTitle:nil rows:[self availableRows:rows] selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];

        [sectionItems addObject:shorts];
    }

    YTSettingsSectionItem *tabbar = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Tabbar")
    accessibilityIdentifier:@"YTLiteSectionItem"
    detailTextBlock:^NSString *() {
        return @"‣";
    }
    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            [self switchWithTitle:@"RemoveLabels" key:@"removeLabels"],
            [self switchWithTitle:@"RemoveIndicators" key:@"removeIndicators"],
            [self switchWithTitle:@"ReExplore" key:@"reExplore"],
            [self switchWithTitle:@"AddExplore" key:@"addExplore"],
            [self switchWithTitle:@"HideShortsTab" key:@"removeShorts"],
            [self switchWithTitle:@"HideSubscriptionsTab" key:@"removeSubscriptions"],
            [self switchWithTitle:@"HideUploadButton" key:@"removeUploads"],
            [self switchWithTitle:@"HideLibraryTab" key:@"removeLibrary"]
        ];

        YTSettingsPickerViewController *picker = [[YTLClass(@"YTSettingsPickerViewController") alloc] initWithNavTitle:LOC(@"Tabbar") pickerSectionTitle:nil rows:[self availableRows:rows] selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];

    [sectionItems addObject:tabbar];

    if (ytlBool(@"advancedMode")) {
        YTSettingsSectionItem *other = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Other")
        accessibilityIdentifier:@"YTLiteSectionItem"
        detailTextBlock:^NSString *() {
            return @"‣";
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [self switchWithTitle:@"CopyVideoInfo" key:@"copyVideoInfo"],
                [self switchWithTitle:@"PostManager" key:@"postManager"],
                [self switchWithTitle:@"SaveProfilePhoto" key:@"saveProfilePhoto"],
                [self switchWithTitle:@"CommentManager" key:@"commentManager"],
                [self switchWithTitle:@"FixAlbums" key:@"fixAlbums"],
                [self switchWithTitle:@"NativeShare" key:@"nativeShare"],
                [self switchWithTitle:@"RemovePlayNext" key:@"removePlayNext"],
                [self switchWithTitle:@"RemoveDownloadMenu" key:@"removeDownloadMenu"],
                [self switchWithTitle:@"RemoveWatchLaterMenu" key:@"removeWatchLaterMenu"],
                [self switchWithTitle:@"RemoveSaveToPlaylistMenu" key:@"removeSaveToPlaylistMenu"],
                [self switchWithTitle:@"RemoveShareMenu" key:@"removeShareMenu"],
                [self switchWithTitle:@"RemoveNotInterestedMenu" key:@"removeNotInterestedMenu"],
                [self switchWithTitle:@"RemoveDontRecommendMenu" key:@"removeDontRecommendMenu"],
                [self switchWithTitle:@"RemoveReportMenu" key:@"removeReportMenu"],
                [self switchWithTitle:@"NoContinueWatching" key:@"noContinueWatching"],
                [self switchWithTitle:@"NoSearchHistory" key:@"noSearchHistory"],
                [self switchWithTitle:@"NoRelatedWatchNexts" key:@"noRelatedWatchNexts"],
                [self switchWithTitle:@"StickSortComments" key:@"stickSortComments"],
                [self switchWithTitle:@"HideSortComments" key:@"hideSortComments"],
                [self switchWithTitle:@"PlaylistOldMinibar" key:@"playlistOldMinibar"],
                [self switchWithTitle:@"DisableRTL" key:@"disableRTL"]
            ];

            YTSettingsPickerViewController *picker = [[YTLClass(@"YTSettingsPickerViewController") alloc] initWithNavTitle:LOC(@"Other") pickerSectionTitle:nil rows:[self availableRows:rows] selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];

        [sectionItems addObject:other];

        [sectionItems addObject:space];

        YTSettingsSectionItem *speed = [YTSettingsSectionItemClass itemWithTitle:LOC(@"HoldToSpeed")
        accessibilityIdentifier:@"YTLiteSectionItem"
        detailTextBlock:^NSString *() {
            NSArray *speedLabels = @[LOC(@"Disabled"), LOC(@"Default"), @"0.25×", @"0.5×", @"0.75×", @"1.0×", @"1.25×", @"1.5×", @"1.75×", @"2.0×", @"3.0×", @"4.0×", @"5.0×"];
            return SafeLabel(speedLabels, @"speedIndex");
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSMutableArray <YTSettingsSectionItem *> *rows = [NSMutableArray array];
            NSArray *speedLabels = @[LOC(@"Disable"), LOC(@"Default"), @"0.25×", @"0.5×", @"0.75×", @"1.0×", @"1.25×", @"1.5×", @"1.75×", @"2.0×", @"3.0×", @"4.0×", @"5.0×"];

            for (NSUInteger i = 0; i < speedLabels.count; i++) {
                NSString *title = speedLabels[i];
                YTSettingsSectionItem *item = [YTSettingsSectionItemClass checkmarkItemWithTitle:title titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    ytlSetInt((int)arg1, @"speedIndex");
                    [settingsViewController reloadData];
                    return YES;
                }];

                [rows addObject:item];
            }

            YTSettingsPickerViewController *picker = [[YTLClass(@"YTSettingsPickerViewController") alloc] initWithNavTitle:LOC(@"HoldToSpeed") pickerSectionTitle:nil rows:rows selectedItemIndex:ytlInt(@"speedIndex") parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];

        [sectionItems addObject:speed];

        YTSettingsSectionItem *autoSpeed = [YTSettingsSectionItemClass itemWithTitle:LOC(@"DefaultPlaybackRate")
        accessibilityIdentifier:@"YTLiteSectionItem"
        detailTextBlock:^NSString *() {
            NSArray *speedLabels = @[@"0.25×", @"0.5×", @"0.75×", @"1.0×", @"1.25×", @"1.5×", @"1.75×", @"2.0×", @"3.0×", @"4.0×", @"5.0×"];
            return SafeLabel(speedLabels, @"autoSpeedIndex");
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSMutableArray <YTSettingsSectionItem *> *rows = [NSMutableArray array];
            NSArray *speedLabels = @[@"0.25×", @"0.5×", @"0.75×", @"1.0×", @"1.25×", @"1.5×", @"1.75×", @"2.0×", @"3.0×", @"4.0×", @"5.0×"];

            for (NSUInteger i = 0; i < speedLabels.count; i++) {
                NSString *title = speedLabels[i];
                YTSettingsSectionItem *item = [YTSettingsSectionItemClass checkmarkItemWithTitle:title titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    ytlSetInt((int)arg1, @"autoSpeedIndex");
                    [settingsViewController reloadData];
                    return YES;
                }];
                [rows addObject:item];
            }

            YTSettingsPickerViewController *picker = [[YTLClass(@"YTSettingsPickerViewController") alloc] initWithNavTitle:LOC(@"DefaultPlaybackRate") pickerSectionTitle:nil rows:rows selectedItemIndex:ytlInt(@"autoSpeedIndex") parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];

        [sectionItems addObject:autoSpeed];

        YTSettingsSectionItem *wifiQuality = [YTSettingsSectionItemClass itemWithTitle:LOC(@"PlaybackQualityOnWiFi")
        accessibilityIdentifier:@"YTLiteSectionItem"
        detailTextBlock:^NSString *() {
            NSArray *qualityLabels = @[LOC(@"Default"), LOC(@"Best"), @"2160p60", @"2160p", @"1440p60", @"1440p", @"1080p60", @"1080p", @"720p60", @"720p", @"480p", @"360p"];
            return SafeLabel(qualityLabels, @"wiFiQualityIndex");
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSMutableArray <YTSettingsSectionItem *> *rows = [NSMutableArray array];
            NSArray *qualityLabels = @[LOC(@"Default"), LOC(@"Best"), @"2160p60", @"2160p", @"1440p60", @"1440p", @"1080p60", @"1080p", @"720p60", @"720p", @"480p", @"360p"];

            for (NSUInteger i = 0; i < qualityLabels.count; i++) {
                NSString *title = qualityLabels[i];
                YTSettingsSectionItem *item = [YTSettingsSectionItemClass checkmarkItemWithTitle:title titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    ytlSetInt((int)arg1, @"wiFiQualityIndex");
                    [settingsViewController reloadData];
                    return YES;
                }];

                [rows addObject:item];
            }

            YTSettingsPickerViewController *picker = [[YTLClass(@"YTSettingsPickerViewController") alloc] initWithNavTitle:LOC(@"SelectQuality") pickerSectionTitle:nil rows:rows selectedItemIndex:ytlInt(@"wiFiQualityIndex") parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];

        [sectionItems addObject:wifiQuality];

        YTSettingsSectionItem *cellQuality = [YTSettingsSectionItemClass itemWithTitle:LOC(@"PlaybackQualityOnCellular")
        accessibilityIdentifier:@"YTLiteSectionItem"
        detailTextBlock:^NSString *() {
            NSArray *qualityLabels = @[LOC(@"Default"), LOC(@"Best"), @"2160p60", @"2160p", @"1440p60", @"1440p", @"1080p60", @"1080p", @"720p60", @"720p", @"480p", @"360p"];
            return SafeLabel(qualityLabels, @"cellQualityIndex");
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSMutableArray <YTSettingsSectionItem *> *rows = [NSMutableArray array];
            NSArray *qualityLabels = @[LOC(@"Default"), LOC(@"Best"), @"2160p60", @"2160p", @"1440p60", @"1440p", @"1080p60", @"1080p", @"720p60", @"720p", @"480p", @"360p"];

            for (NSUInteger i = 0; i < qualityLabels.count; i++) {
                NSString *title = qualityLabels[i];
                YTSettingsSectionItem *item = [YTSettingsSectionItemClass checkmarkItemWithTitle:title titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    ytlSetInt((int)arg1, @"cellQualityIndex");
                    [settingsViewController reloadData];
                    return YES;
                }];

                [rows addObject:item];
            }

            YTSettingsPickerViewController *picker = [[YTLClass(@"YTSettingsPickerViewController") alloc] initWithNavTitle:LOC(@"SelectQuality") pickerSectionTitle:nil rows:rows selectedItemIndex:ytlInt(@"cellQualityIndex") parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];

        [sectionItems addObject:cellQuality];

        YTSettingsSectionItem *startup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Startup")
        accessibilityIdentifier:@"YTLiteSectionItem"
        detailTextBlock:^NSString *() {
            NSArray *tabLabels = @[LOC(@"Home"), LOC(@"Explore"), LOC(@"ShortsTab"), LOC(@"Subscriptions"), LOC(@"Library")];
            return SafeLabel(tabLabels, @"pivotIndex");
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSMutableArray <YTSettingsSectionItem *> *rows = [NSMutableArray array];
            NSArray *tabLabels = @[LOC(@"Home"), LOC(@"Explore"), LOC(@"ShortsTab"), LOC(@"Subscriptions"), LOC(@"Library")];

            for (NSUInteger i = 0; i < tabLabels.count; i++) {
                NSString *title = tabLabels[i];
                YTSettingsSectionItem *item = [YTSettingsSectionItemClass checkmarkItemWithTitle:title titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    if (([title isEqualToString:LOC(@"Explore")] && !ytlBool(@"reExplore") && !ytlBool(@"addExplore")) ||
                        ([title isEqualToString:LOC(@"ShortsTab")] && ytlBool(@"removeShorts")) ||
                        ([title isEqualToString:LOC(@"Subscriptions")] && ytlBool(@"removeSubscriptions")) ||
                        ([title isEqualToString:LOC(@"Library")] && ytlBool(@"removeLibrary"))) {
                            YTAlertView *alertView = [YTLClass(@"YTAlertView") infoDialog];
                            alertView.title = LOC(@"Warning");
                            alertView.subtitle = LOC(@"TabIsHidden");
                            [alertView show];
                            return NO;
                    } else {
                        ytlSetInt((int)arg1, @"pivotIndex");
                        [settingsViewController reloadData];
                        return YES;
                    }
                }];

                [rows addObject:item];
            }

            YTSettingsPickerViewController *picker = [[YTLClass(@"YTSettingsPickerViewController") alloc] initWithNavTitle:LOC(@"Startup") pickerSectionTitle:nil rows:rows selectedItemIndex:ytlInt(@"pivotIndex") parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];

        [sectionItems addObject:startup];
    }
    
    [sectionItems addObject:space];

    YTSettingsSectionItem *support = [YTLClass(@"YTSettingsSectionItem") itemWithTitle:LOC(@"SupportDevelopment") accessibilityIdentifier:@"YTLiteSectionItem" detailTextBlock:^NSString *() { return @"♡"; } selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        YTDefaultSheetController *sheetController = [YTLClass(@"YTDefaultSheetController") sheetControllerWithMessage:LOC(@"SupportDevelopment") subMessage:LOC(@"SupportDevelopmentDesc") delegate:nil parentResponder:nil];
        YTActionSheetHeaderView *headerView = YTLValue(sheetController, @"_headerView");
        YTFormattedStringLabel *subtitle = YTLValue(headerView, @"_subtitleLabel");
        subtitle.numberOfLines = 0;
        [headerView showHeaderDivider];

        [sheetController addAction:[YTLClass(@"YTActionSheetAction") actionWithTitle:@"PayPal" iconImage:[self resizedImageNamed:@"paypal"] secondaryIconImage:nil accessibilityIdentifier:nil handler:^ {
            [YTLClass(@"YTUIUtils") openURL:[NSURL URLWithString:@"https://paypal.me/dayanch96"]];
        }]];

        [sheetController addAction:[YTLClass(@"YTActionSheetAction") actionWithTitle:@"Github Sponsors" iconImage:[self resizedImageNamed:@"github"] secondaryIconImage:nil accessibilityIdentifier:nil handler:^ {
            [YTLClass(@"YTUIUtils") openURL:[NSURL URLWithString:@"https://github.com/sponsors/dayanch96"]];
        }]];

        [sheetController addAction:[YTLClass(@"YTActionSheetAction") actionWithTitle:@"Buy Me a Coffee" iconImage:[self resizedImageNamed:@"coffee"] secondaryIconImage:nil accessibilityIdentifier:nil handler:^ {
            [YTLClass(@"YTUIUtils") openURL:[NSURL URLWithString:@"https://www.buymeacoffee.com/dayanch96"]];
        }]];

        [sheetController addAction:[YTLClass(@"YTActionSheetAction") actionWithTitle:@"USDT (TRC20)" iconImage:[self resizedImageNamed:@"usdt"] secondaryIconImage:nil accessibilityIdentifier:nil handler:^ {
            [UIPasteboard generalPasteboard].string = @"TEdKJdKwc1Bbu8Py4um8qPQ6MbproEqNJw";
            [[YTLClass(@"YTToastResponderEvent") eventWithMessage:LOC(@"Copied") firstResponder:[self parentResponder]] send];
        }]];

        [sheetController addAction:[YTLClass(@"YTActionSheetAction") actionWithTitle:@"BNB Smart Chain (BEP20)" iconImage:[self resizedImageNamed:@"bnb"] secondaryIconImage:nil accessibilityIdentifier:nil handler:^ {
            [UIPasteboard generalPasteboard].string = @"0xc6f9fddb30ce10d70e6497950f44c8e10b72bcd6";
            [[YTLClass(@"YTToastResponderEvent") eventWithMessage:LOC(@"Copied") firstResponder:[self parentResponder]] send];
        }]];

        [sheetController addAction:[YTLClass(@"YTActionSheetAction") actionWithTitle:@"Boosty" iconImage:[self resizedImageNamed:@"boosty"] secondaryIconImage:nil accessibilityIdentifier:nil handler:^ {
            [YTLClass(@"YTUIUtils") openURL:[NSURL URLWithString:@"https://boosty.to/dayanch96"]];
        }]];

        [sheetController presentFromViewController:[YTLClass(@"YTUIUtils") topViewControllerForPresenting] animated:YES completion:nil];

        return YES;
    }];

    YTSettingsSectionItem *thanks = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Contributors")
    accessibilityIdentifier:@"YTLiteSectionItem"
    detailTextBlock:^NSString *() {
        return @"‣";
    }
    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            [self linkWithTitle:@"Dayanch96" description:LOC(@"Developer") link:@"https://github.com/Dayanch96/"],
            [self linkWithTitle:@"Dan Pashin" description:LOC(@"SpecialThanks") link:@"https://github.com/danpashin/"],
            space,
            [self linkWithTitle:@"Balackburn" description:LOC(@"French") link:@"https://github.com/Balackburn"]
        ];

        YTSettingsPickerViewController *picker = [[YTLClass(@"YTSettingsPickerViewController") alloc] initWithNavTitle:LOC(@"About") pickerSectionTitle:LOC(@"Credits") rows:[self availableRows:rows] selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];

    YTSettingsSectionItem *sources = [YTSettingsSectionItemClass itemWithTitle:LOC(@"OpenSourceLibs")
    accessibilityIdentifier:@"YTLiteSectionItem"
    detailTextBlock:^NSString *() {
        return @"‣";
    }
    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            [self linkWithTitle:@"PoomSmart" description:@"YouTube-X, YTNoPremium, YTClassicVideoQuality, YTShortsProgress, YTReExplore, SkipContentWarning, YTAutoFullscreen, YouTubeHeaders" link:@"https://github.com/PoomSmart/"],
            [self linkWithTitle:@"MiRO92" description:@"YTNoShorts" link:@"https://github.com/MiRO92/YTNoShorts"],
            [self linkWithTitle:@"Tony Million" description:@"Reachability" link:@"https://github.com/tonymillion/Reachability"],
            [self linkWithTitle:@"jkhsjdhjs" description:@"YouTube Native Share" link:@"https://github.com/jkhsjdhjs/youtube-native-share"]
        ];

        YTSettingsPickerViewController *picker = [[YTLClass(@"YTSettingsPickerViewController") alloc] initWithNavTitle:LOC(@"About") pickerSectionTitle:LOC(@"Credits") rows:[self availableRows:rows] selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];

    YTSettingsSectionItem *version = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Version")
        accessibilityIdentifier:@"YTLiteSectionItem"
        detailTextBlock:^NSString *() {
            return @(OS_STRINGIFY(TWEAK_VERSION));
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [self switchWithTitle:@"Advanced" key:@"advancedMode"],

                [YTLClass(@"YTSettingsSectionItem") itemWithTitle:LOC(@"ClearCache") titleDescription:nil accessibilityIdentifier:@"YTLiteSectionItem" detailTextBlock:^NSString *() { return GetCacheSize(settingsViewController); } selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
                        for (NSString *item in [fileManager contentsOfDirectoryAtPath:cachePath error:nil]) {
                            [fileManager removeItemAtPath:[cachePath stringByAppendingPathComponent:item] error:nil];
                        }

                        dispatch_async(dispatch_get_main_queue(), ^{
                            cachedCacheSize = nil;
                            [settingsViewController reloadData];
                            [[YTLClass(@"YTToastResponderEvent") eventWithMessage:LOC(@"Done") firstResponder:[self parentResponder]] send];
                        });
                    });

                    return YES;
                }],

                [YTLClass(@"YTSettingsSectionItem") itemWithTitle:LOC(@"ResetSettings") titleDescription:nil accessibilityIdentifier:@"YTLiteSectionItem" detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    YTAlertView *alertView = [YTLClass(@"YTAlertView") confirmationDialogWithAction:^{
                        [YTLUserDefaults resetUserDefaults];
                        [[YTLUserDefaults standardUserDefaults] synchronize];

                        [[UIApplication sharedApplication] performSelector:@selector(suspend)];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            exit(0);
                        });
                    }
                    actionTitle:LOC(@"Yes")
                    cancelTitle:LOC(@"No")];
                    alertView.title = LOC(@"Warning");
                    alertView.subtitle = LOC(@"ResetMessage");
                    [alertView show];

                    return YES;
                }]
            ];

        YTSettingsPickerViewController *picker = [[YTLClass(@"YTSettingsPickerViewController") alloc] initWithNavTitle:LOC(@"About") pickerSectionTitle:nil rows:[self availableRows:rows] selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];

    [sectionItems addObject:thanks];

    [sectionItems addObject:sources];

    [sectionItems addObject:support];

    [sectionItems addObject:version];

    BOOL isNew = [settingsViewController respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)];
    isNew ? [settingsViewController setSectionItems:sectionItems forCategory:YTLiteSection title:@"YTLite" icon:nil titleDescription:nil headerHidden:NO]
          : [settingsViewController setSectionItems:sectionItems forCategory:YTLiteSection title:@"YTLite" titleDescription:nil headerHidden:NO];

}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == YTLiteSection) {
        [self updateYTLiteSectionWithEntry:entry];
        return;
    } %orig;
}

%new
- (UIImage *)resizedImageNamed:(NSString *)iconName {

    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(32, 32)];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        UIView *imageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSBundle.ytl_defaultBundle pathForResource:iconName ofType:@"png"]]];
        iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        iconImageView.clipsToBounds = YES;
        iconImageView.frame = imageView.bounds;

        [imageView addSubview:iconImageView];
        [imageView.layer renderInContext:rendererContext.CGContext];
    }];

    return image;
}
%end
