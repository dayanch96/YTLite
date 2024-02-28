#import "YTLite.h"

@interface YTSettingsSectionItemManager (YTLite)
- (void)updateYTLiteSectionWithEntry:(id)entry;
@end

static const NSInteger YTLiteSection = 789;

static NSString *GetCacheSize() {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:cachePath error:nil];

    unsigned long long int folderSize = 0;
    for (NSString *fileName in filesArray) {
        NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        folderSize += [fileAttributes fileSize];
    }

    NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
    formatter.countStyle = NSByteCountFormatterCountStyleFile;

    return [formatter stringFromByteCount:folderSize];
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
    YTTouchFeedbackController *feedback = [self valueForKey:@"_touchFeedbackController"];
    ABCSwitch *abcSwitch = [self valueForKey:@"_switch"];

    if (isYTLite) {
        feedback.feedbackColor = [UIColor colorWithRed:0.75 green:0.50 blue:0.90 alpha:1.0];
        abcSwitch.onTintColor = [UIColor colorWithRed:0.75 green:0.50 blue:0.90 alpha:1.0];
    }
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

%new
- (void)updateIntegerPrefsForKey:(NSString *)key intValue:(NSInteger)intValue {
    NSString *prefsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"YTLite.plist"];
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:prefsPath];

    if (!prefs) prefs = [NSMutableDictionary dictionary];

    [prefs setObject:@(intValue) forKey:key];
    [prefs writeToFile:prefsPath atomically:NO];

    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.dvntm.ytlite.prefschanged"), NULL, NULL, YES);
}

static YTSettingsSectionItem *createSwitchItem(NSString *title, NSString *key, BOOL *value, id selfObject) {
    Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);
    Class YTAlertViewClass = %c(YTAlertView);

    YTSettingsSectionItem *item = [YTSettingsSectionItemClass switchItemWithTitle:LOC(title)
        titleDescription:LOC([NSString stringWithFormat:@"%@Desc", title])
        accessibilityIdentifier:@"YTLiteSectionItem"
        switchOn:*value
        switchBlock:^BOOL(YTSettingsCell *cell, BOOL enabled) {
            if ([key isEqualToString:@"shortsOnlyMode"]) {
                YTAlertView *alertView = [YTAlertViewClass confirmationDialogWithAction:^{
                    [selfObject updatePrefsForKey:@"shortsOnlyMode" enabled:enabled];
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
                [selfObject updatePrefsForKey:key enabled:enabled];
            }

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

    YTSettingsSectionItem *space = [%c(YTSettingsSectionItem) itemWithTitle:nil accessibilityIdentifier:@"YTLiteSectionItem" detailTextBlock:nil selectBlock:nil];

    YTSettingsSectionItem *general = [YTSettingsSectionItemClass itemWithTitle:LOC(@"General")
        accessibilityIdentifier:@"YTLiteSectionItem"
        detailTextBlock:^NSString *() {
            return @"‣";
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
            createSwitchItem(@"RemoveAds", @"noAds", &kNoAds, selfObject),
            createSwitchItem(@"BackgroundPlayback", @"backgroundPlayback", &kBackgroundPlayback, selfObject)
        ];

        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"General") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:general];

    YTSettingsSectionItem *navbar = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Navbar")
        accessibilityIdentifier:@"YTLiteSectionItem"
        detailTextBlock:^NSString *() {
            return @"‣";
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
            createSwitchItem(@"RemoveCast", @"noCast", &kNoCast, selfObject),
            createSwitchItem(@"RemoveNotifications", @"removeNotifsButton", &kNoNotifsButton, selfObject),
            createSwitchItem(@"RemoveSearch", @"removeSearchButton", &kNoSearchButton, selfObject),
            createSwitchItem(@"RemoveVoiceSearch", @"removeVoiceSearchButton", &kNoVoiceSearchButton, selfObject)
        ];

        if (kAdvancedMode) {
            YTSettingsSectionItem *addStickyNavbar = createSwitchItem(@"StickyNavbar", @"stickyNavbar", &kStickyNavbar, selfObject);
            rows = [rows arrayByAddingObject:addStickyNavbar];

            YTSettingsSectionItem *addNoSubbar = createSwitchItem(@"NoSubbar", @"noSubbar", &kNoSubbar, selfObject);
            rows = [rows arrayByAddingObject:addNoSubbar];

            YTSettingsSectionItem *addNoYTLogo = createSwitchItem(@"NoYTLogo", @"noYTLogo", &kNoYTLogo, selfObject);
            rows = [rows arrayByAddingObject:addNoYTLogo];
        }

        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"Navbar") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:navbar];

    if (kAdvancedMode) {
        YTSettingsSectionItem *overlay = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Overlay")
            accessibilityIdentifier:@"YTLiteSectionItem"
            detailTextBlock:^NSString *() {
                return @"‣";
            }
            selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                NSArray <YTSettingsSectionItem *> *rows = @[
                createSwitchItem(@"HideAutoplay", @"hideAutoplay", &kHideAutoplay, selfObject),
                createSwitchItem(@"HideSubs", @"hideSubs", &kHideSubs, selfObject),
                createSwitchItem(@"NoHUDMsgs", @"noHUDMsgs", &kNoHUDMsgs, selfObject),
                createSwitchItem(@"HidePrevNext", @"hidePrevNext", &kHidePrevNext, selfObject),
                createSwitchItem(@"ReplacePrevNext", @"replacePrevNext", &kReplacePrevNext, selfObject),
                createSwitchItem(@"NoDarkBg", @"noDarkBg", &kNoDarkBg, selfObject),
                createSwitchItem(@"NoEndScreenCards", @"endScreenCards", &kEndScreenCards, selfObject),
                createSwitchItem(@"NoFullscreenActions", @"noFullscreenActions", &kNoFullscreenActions, selfObject),
                createSwitchItem(@"PersistentProgressBar", @"persistentProgressBar", &kPersistentProgressBar, selfObject),
                createSwitchItem(@"NoRelatedVids", @"noRelatedVids", &kNoRelatedVids, selfObject),
                createSwitchItem(@"NoPromotionCards", @"noPromotionCards", &kNoPromotionCards, selfObject),
                createSwitchItem(@"NoWatermarks", @"noWatermarks", &kNoWatermarks, selfObject)
            ];

            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"Overlay") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
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
                createSwitchItem(@"Miniplayer", @"miniplayer", &kMiniplayer, selfObject),
                createSwitchItem(@"PortraitFullscreen", @"portraitFullscreen", &kPortraitFullscreen, selfObject),
                createSwitchItem(@"CopyWithTimestamp", @"copyWithTimestamp", &kCopyWithTimestamp, selfObject),
                createSwitchItem(@"DisableAutoplay", @"disableAutoplay", &kDisableAutoplay, selfObject),
                createSwitchItem(@"DisableAutoCaptions", @"disableAutoCaptions", &kDisableAutoCaptions, selfObject),
                createSwitchItem(@"NoContentWarning", @"noContentWarning", &kNoContentWarning, selfObject),
                createSwitchItem(@"ClassicQuality", @"classicQuality", &kClassicQuality, selfObject),
                createSwitchItem(@"ExtraSpeedOptions", @"extraSpeedOptions", &kExtraSpeedOptions, selfObject),
                createSwitchItem(@"DontSnap2Chapter", @"dontSnapToChapter", &kDontSnapToChapter, selfObject),
                createSwitchItem(@"RedProgressBar", @"redProgressBar", &kRedProgressBar, selfObject),
                createSwitchItem(@"NoPlayerRemixButton", @"noPlayerRemixButton", &kNoPlayerRemixButton, selfObject),
                createSwitchItem(@"NoPlayerClipButton", @"noPlayerClipButton", &kNoPlayerClipButton, selfObject),
                createSwitchItem(@"NoPlayerDownloadButton", @"noPlayerDownloadButton", &kNoPlayerDownloadButton, selfObject),
                createSwitchItem(@"NoHints", @"noHints", &kNoHints, selfObject),
                createSwitchItem(@"NoFreeZoom", @"noFreeZoom", &kNoFreeZoom, selfObject),
                createSwitchItem(@"AutoFullscreen", @"autoFullscreen", &kAutoFullscreen, selfObject),
                createSwitchItem(@"ExitFullscreen", @"exitFullscreen", &kExitFullscreen, selfObject),
                createSwitchItem(@"NoDoubleTap2Seek", @"noDoubleTapToSeek", &kNoDoubleTapToSeek, selfObject)
            ];

            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"Player") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
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
                createSwitchItem(@"ShortsOnlyMode", @"shortsOnlyMode", &kShortsOnlyMode, selfObject),
                createSwitchItem(@"HideShorts", @"hideShorts", &kHideShorts, selfObject),
                createSwitchItem(@"ShortsProgress", @"shortsProgress", &kShortsProgress, selfObject),
                createSwitchItem(@"PinchToFullscreenShorts", @"pinchToFullscreenShorts", &kPinchToFullscreenShorts, selfObject),
                createSwitchItem(@"ShortsToRegular", @"shortsToRegular", &kShortsToRegular, selfObject),
                createSwitchItem(@"ResumeShorts", @"resumeShorts", &kResumeShorts, selfObject),
                createSwitchItem(@"HideShortsLogo", @"hideShortsLogo", &kHideShortsLogo, selfObject),
                createSwitchItem(@"HideShortsSearch", @"hideShortsSearch", &kHideShortsSearch, selfObject),
                createSwitchItem(@"HideShortsCamera", @"hideShortsCamera", &kHideShortsCamera, selfObject),
                createSwitchItem(@"HideShortsMore", @"hideShortsMore", &kHideShortsMore, selfObject),
                createSwitchItem(@"HideShortsSubscriptions", @"hideShortsSubscriptions", &kHideShortsSubscriptions, selfObject),
                createSwitchItem(@"HideShortsLike", @"hideShortsLike", &kHideShortsLike, selfObject),
                createSwitchItem(@"HideShortsDislike", @"hideShortsDislike", &kHideShortsDislike, selfObject),
                createSwitchItem(@"HideShortsComments", @"hideShortsComments", &kHideShortsComments, selfObject),
                createSwitchItem(@"HideShortsRemix", @"hideShortsRemix", &kHideShortsRemix, selfObject),
                createSwitchItem(@"HideShortsShare", @"hideShortsShare", &kHideShortsShare, selfObject),
                createSwitchItem(@"HideShortsAvatars", @"hideShortsAvatars", &kHideShortsAvatars, selfObject),
                createSwitchItem(@"HideShortsThanks", @"hideShortsThanks", &kHideShortsThanks, selfObject),
                createSwitchItem(@"HideShortsSource", @"hideShortsSource", &kHideShortsSource, selfObject),
                createSwitchItem(@"HideShortsChannelName", @"hideShortsChannelName", &kHideShortsChannelName, selfObject),
                createSwitchItem(@"HideShortsDescription", @"hideShortsDescription", &kHideShortsDescription, selfObject),
                createSwitchItem(@"HideShortsAudioTrack", @"hideShortsAudioTrack", &kHideShortsAudioTrack, selfObject),
                createSwitchItem(@"NoPromotionCards", @"hideShortsPromoCards", &kHideShortsPromoCards, selfObject)
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"Shorts") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
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
            createSwitchItem(@"RemoveLabels", @"removeLabels", &kRemoveLabels, selfObject),
            createSwitchItem(@"RemoveIndicators", @"removeIndicators", &kRemoveIndicators, selfObject),
            createSwitchItem(@"ReExplore", @"reExplore", &kReExplore, selfObject),
            createSwitchItem(@"AddExplore", @"addExplore", &kAddExplore, selfObject),
            createSwitchItem(@"HideShortsTab", @"removeShorts", &kRemoveShorts, selfObject),
            createSwitchItem(@"HideSubscriptionsTab", @"removeSubscriptions", &kRemoveSubscriptions, selfObject),
            createSwitchItem(@"HideUploadButton", @"removeUploads", &kRemoveUploads, selfObject),
            createSwitchItem(@"HideLibraryTab", @"removeLibrary", &kRemoveLibrary, selfObject)
        ];

        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"Tabbar") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:tabbar];

    if (kAdvancedMode) {
        YTSettingsSectionItem *other = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Other")
            accessibilityIdentifier:@"YTLiteSectionItem"
            detailTextBlock:^NSString *() {
                return @"‣";
            }
            selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                NSArray <YTSettingsSectionItem *> *rows = @[
                createSwitchItem(@"CopyVideoInfo", @"copyVideoInfo", &kCopyVideoInfo, selfObject),
                createSwitchItem(@"PostManager", @"postManager", &kPostManager, selfObject),
                createSwitchItem(@"SaveProfilePhoto", @"saveProfilePhoto", &kSaveProfilePhoto, selfObject),
                createSwitchItem(@"CommentManager", @"commentManager", &kCommentManager, selfObject),
                createSwitchItem(@"FixAlbums", @"fixAlbums", &kFixAlbums, selfObject),
                createSwitchItem(@"RemovePlayNext", @"removePlayNext", &kRemovePlayNext, selfObject),
                createSwitchItem(@"RemoveDownloadMenu", @"removeDownloadMenu", &kRemoveDownloadMenu, selfObject),
                createSwitchItem(@"RemoveWatchLaterMenu", @"removeWatchLaterMenu", &kRemoveWatchLaterMenu, selfObject),
                createSwitchItem(@"RemoveSaveToPlaylistMenu", @"removeSaveToPlaylistMenu", &kRemoveSaveToPlaylistMenu, selfObject),
                createSwitchItem(@"RemoveShareMenu", @"removeShareMenu", &kRemoveShareMenu, selfObject),
                createSwitchItem(@"RemoveNotInterestedMenu", @"removeNotInterestedMenu", &kRemoveNotInterestedMenu, selfObject),
                createSwitchItem(@"RemoveDontRecommendMenu", @"removeDontRecommendMenu", &kRemoveDontRecommendMenu, selfObject),
                createSwitchItem(@"RemoveReportMenu", @"removeReportMenu", &kRemoveReportMenu, selfObject),
                createSwitchItem(@"NoContinueWatching", @"noContinueWatching", &kNoContinueWatching, selfObject),
                createSwitchItem(@"NoSearchHistory", @"noSearchHistory", &kNoSearchHistory, selfObject),
                createSwitchItem(@"NoRelatedWatchNexts", @"noRelatedWatchNexts", &kNoRelatedWatchNexts, selfObject),
                createSwitchItem(@"StickSortComments", @"stickSortComments", &kStickSortComments, selfObject),
                createSwitchItem(@"HideSortComments", @"hideSortComments", &kHideSortComments, selfObject),
                createSwitchItem(@"PlaylistOldMinibar", @"playlistOldMinibar", &kPlaylistOldMinibar, selfObject),
                createSwitchItem(@"DisableRTL", @"disableRTL", &kDisableRTL, selfObject)
            ];

            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"Other") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];
        [sectionItems addObject:other];

        [sectionItems addObject:space];

        YTSettingsSectionItem *wifiQuality = [YTSettingsSectionItemClass itemWithTitle:LOC(@"PlaybackQualityOnWiFi")
        accessibilityIdentifier:@"YTLiteSectionItem"
        detailTextBlock:^NSString *() {
            NSString *qualityLabel = kWiFiQualityIndex == 1 ? LOC(@"Best") :
                                     kWiFiQualityIndex == 2 ? @"2160p60" :
                                     kWiFiQualityIndex == 3 ? @"2160p" :
                                     kWiFiQualityIndex == 4 ? @"1440p60" :
                                     kWiFiQualityIndex == 5 ? @"1440p" :
                                     kWiFiQualityIndex == 6 ? @"1080p60" :
                                     kWiFiQualityIndex == 7 ? @"1080p" :
                                     kWiFiQualityIndex == 8 ? @"720p60" :
                                     kWiFiQualityIndex == 9 ? @"720p" :
                                     kWiFiQualityIndex == 10 ? @"480p" :
                                     kWiFiQualityIndex == 11 ? @"360p" :
                                     LOC(@"Default");

            return qualityLabel;
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSMutableArray <YTSettingsSectionItem *> *rows = [NSMutableArray array];
            NSArray *qualityTitles = @[LOC(@"Default"), LOC(@"Best"), @"2160p60", @"2160p", @"1440p60", @"1440p", @"1080p60", @"1080p", @"720p60", @"720p", @"480p", @"360p"];

            for (NSUInteger i = 0; i < qualityTitles.count; i++) {
                NSString *title = qualityTitles[i];
                YTSettingsSectionItem *item = [YTSettingsSectionItemClass checkmarkItemWithTitle:title titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    kWiFiQualityIndex = (int)arg1;
                    [settingsViewController reloadData];
                    [self updateIntegerPrefsForKey:@"wifiQualityIndex" intValue:kWiFiQualityIndex];
                    return YES;
                }];
                [rows addObject:item];
            }

            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"SelectQuality") pickerSectionTitle:nil rows:rows selectedItemIndex:kWiFiQualityIndex parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];
        [sectionItems addObject:wifiQuality];

        YTSettingsSectionItem *cellQuality = [YTSettingsSectionItemClass itemWithTitle:LOC(@"PlaybackQualityOnCellular")
        accessibilityIdentifier:@"YTLiteSectionItem"
        detailTextBlock:^NSString *() {
            NSString *qualityLabel = kCellQualityIndex == 1 ? LOC(@"Best") :
                                     kCellQualityIndex == 2 ? @"2160p60" :
                                     kCellQualityIndex == 3 ? @"2160p" :
                                     kCellQualityIndex == 4 ? @"1440p60" :
                                     kCellQualityIndex == 5 ? @"1440p" :
                                     kCellQualityIndex == 6 ? @"1080p60" :
                                     kCellQualityIndex == 7 ? @"1080p" :
                                     kCellQualityIndex == 8 ? @"720p60" :
                                     kCellQualityIndex == 9 ? @"720p" :
                                     kCellQualityIndex == 10 ? @"480p" :
                                     kCellQualityIndex == 11 ? @"360p" :
                                     LOC(@"Default");

            return qualityLabel;
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSMutableArray <YTSettingsSectionItem *> *rows = [NSMutableArray array];
            NSArray *qualityTitles = @[LOC(@"Default"), LOC(@"Best"), @"2160p60", @"2160p", @"1440p60", @"1440p", @"1080p60", @"1080p", @"720p60", @"720p", @"480p", @"360p"];

            for (NSUInteger i = 0; i < qualityTitles.count; i++) {
                NSString *title = qualityTitles[i];
                YTSettingsSectionItem *item = [YTSettingsSectionItemClass checkmarkItemWithTitle:title titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    kCellQualityIndex = (int)arg1;
                    [settingsViewController reloadData];
                    [self updateIntegerPrefsForKey:@"cellQualityIndex" intValue:kCellQualityIndex];
                    return YES;
                }];
                [rows addObject:item];
            }

            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"SelectQuality") pickerSectionTitle:nil rows:rows selectedItemIndex:kCellQualityIndex parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];
        [sectionItems addObject:cellQuality];

        YTSettingsSectionItem *startup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Startup")
        accessibilityIdentifier:@"YTLiteSectionItem"
        detailTextBlock:^NSString *() {
            NSString *tabLabel = kPivotIndex == 1 ? LOC(@"Explore") :
                                 kPivotIndex == 2 ? LOC(@"ShortsTab") :
                                 kPivotIndex == 3 ? LOC(@"Subscriptions") :
                                 kPivotIndex == 4 ? LOC(@"Library") :
                                 LOC(@"Home");

            return tabLabel;
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSMutableArray <YTSettingsSectionItem *> *rows = [NSMutableArray array];
            NSArray *tabTitles = @[LOC(@"Home"), LOC(@"Explore"), LOC(@"ShortsTab"), LOC(@"Subscriptions"), LOC(@"Library")];

            for (NSUInteger i = 0; i < tabTitles.count; i++) {
                NSString *title = tabTitles[i];
                YTSettingsSectionItem *item = [YTSettingsSectionItemClass checkmarkItemWithTitle:title titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    if (([title isEqualToString:LOC(@"Explore")] && !kReExplore && !kAddExplore) ||
                        ([title isEqualToString:LOC(@"ShortsTab")] && kRemoveShorts) ||
                        ([title isEqualToString:LOC(@"Subscriptions")] && kRemoveSubscriptions) ||
                        ([title isEqualToString:LOC(@"Library")] && kRemoveLibrary)) {
                            YTAlertView *alertView = [%c(YTAlertView) infoDialog];
                            alertView.title = LOC(@"Warning");
                            alertView.subtitle = LOC(@"TabIsHidden");
                            [alertView show];
                            return NO;
                    } else {
                        kPivotIndex = (int)arg1;
                        [settingsViewController reloadData];
                        [self updateIntegerPrefsForKey:@"pivotIndex" intValue:kPivotIndex];
                        return YES;
                    }
                }];
                [rows addObject:item];
            }

            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"Startup") pickerSectionTitle:nil rows:rows selectedItemIndex:kPivotIndex parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];
        [sectionItems addObject:startup];
    }
    
    [sectionItems addObject:space];

    YTSettingsSectionItem *ps = [%c(YTSettingsSectionItem) itemWithTitle:@"PoomSmart" titleDescription:@"YouTube-X, YTNoPremium, YTClassicVideoQuality, YTShortsProgress, YTReExplore, SkipContentWarning, YTAutoFullscreen, YouTubeHeaders" accessibilityIdentifier:@"YTLiteSectionItem" detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/PoomSmart/"]];
    }];

    YTSettingsSectionItem *miro = [%c(YTSettingsSectionItem) itemWithTitle:@"MiRO92" titleDescription:@"YTNoShorts" accessibilityIdentifier:@"YTLiteSectionItem" detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/MiRO92/"]];
    }];

    YTSettingsSectionItem *tonymillion = [%c(YTSettingsSectionItem) itemWithTitle:@"Tony Million" titleDescription:@"Reachability" accessibilityIdentifier:@"YTLiteSectionItem" detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/tonymillion/Reachability"]];
    }];

    YTSettingsSectionItem *stalker = [%c(YTSettingsSectionItem) itemWithTitle:@"Stalker" titleDescription:LOC(@"ChineseSimplified") accessibilityIdentifier:@"YTLiteSectionItem" detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/xiangfeidexiaohuo"]];
    }];

    YTSettingsSectionItem *clement = [%c(YTSettingsSectionItem) itemWithTitle:@"Clement" titleDescription:LOC(@"ChineseTraditional") accessibilityIdentifier:@"YTLiteSectionItem" detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://twitter.com/a100900900"]];
    }];

    YTSettingsSectionItem *balackburn = [%c(YTSettingsSectionItem) itemWithTitle:@"Balackburn" titleDescription:LOC(@"French") accessibilityIdentifier:@"YTLiteSectionItem" detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/Balackburn"]];
    }];

    YTSettingsSectionItem *decibelios = [%c(YTSettingsSectionItem) itemWithTitle:@"DeciBelioS" titleDescription:LOC(@"Spanish") accessibilityIdentifier:@"YTLiteSectionItem" detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/Deci8BelioS"]];
    }];

    YTSettingsSectionItem *skeids = [%c(YTSettingsSectionItem) itemWithTitle:@"SKEIDs" titleDescription:LOC(@"Japanese") accessibilityIdentifier:@"YTLiteSectionItem" detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/SKEIDs"]];
    }];

    YTSettingsSectionItem *hiepvk = [%c(YTSettingsSectionItem) itemWithTitle:@"Hiepvk" titleDescription:LOC(@"Vietnamese") accessibilityIdentifier:@"YTLiteSectionItem" detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/hiepvk"]];
    }];

    YTSettingsSectionItem *dayanch96 = [%c(YTSettingsSectionItem) itemWithTitle:@"Dayanch96" titleDescription:LOC(@"Developer") accessibilityIdentifier:@"YTLiteSectionItem" detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/Dayanch96/"]];
    }];

    YTSettingsSectionItem *support = [%c(YTSettingsSectionItem) itemWithTitle:LOC(@"SupportDevelopment") accessibilityIdentifier:@"YTLiteSectionItem" detailTextBlock:^NSString *() { return @"♡"; } selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        YTDefaultSheetController *sheetController = [%c(YTDefaultSheetController) sheetControllerWithMessage:LOC(@"SupportDevelopment") subMessage:LOC(@"SupportDevelopmentDesc") delegate:nil parentResponder:nil];
        YTActionSheetHeaderView *headerView = [sheetController valueForKey:@"_headerView"];
        YTFormattedStringLabel *subtitle = [headerView valueForKey:@"_subtitleLabel"];
        subtitle.numberOfLines = 0;
        [headerView showHeaderDivider];

        [sheetController addAction:[%c(YTActionSheetAction) actionWithTitle:@"PayPal" iconImage:[self resizedImageNamed:@"paypal"] secondaryIconImage:nil accessibilityIdentifier:nil handler:^ {
            [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://paypal.me/dayanch96"]];
        }]];

        [sheetController addAction:[%c(YTActionSheetAction) actionWithTitle:@"Github Sponsors" iconImage:[self resizedImageNamed:@"github"] secondaryIconImage:nil accessibilityIdentifier:nil handler:^ {
            [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/sponsors/dayanch96"]];
        }]];

        [sheetController addAction:[%c(YTActionSheetAction) actionWithTitle:@"Buy Me a Coffee" iconImage:[self resizedImageNamed:@"coffee"] secondaryIconImage:nil accessibilityIdentifier:nil handler:^ {
            [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://www.buymeacoffee.com/dayanch96"]];
        }]];

        UIViewController *currentController = UIApplication.sharedApplication.windows.firstObject.rootViewController;
        [sheetController presentFromViewController:currentController.presentedViewController animated:YES completion:nil];

        return YES;
    }];

    YTSettingsSectionItem *cache = [%c(YTSettingsSectionItem) itemWithTitle:LOC(@"ClearCache") titleDescription:nil accessibilityIdentifier:@"YTLiteSectionItem" detailTextBlock:^NSString *() { return GetCacheSize(); } selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
            [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
        });
        [[%c(YTToastResponderEvent) eventWithMessage:LOC(@"Done") firstResponder:[self parentResponder]] send];
        return YES;
    }];

    YTSettingsSectionItem *reset = [%c(YTSettingsSectionItem) itemWithTitle:LOC(@"ResetSettings") titleDescription:nil accessibilityIdentifier:@"YTLiteSectionItem" detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        YTAlertView *alertView = [%c(YTAlertView) confirmationDialogWithAction:^{
            NSString *prefsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"YTLite.plist"];
            [[NSFileManager defaultManager] removeItemAtPath:prefsPath error:nil];

            [[UIApplication sharedApplication] performSelector:@selector(suspend)];
            [NSThread sleepForTimeInterval:1.0];
            exit(0);
        }
        actionTitle:LOC(@"Yes")
        cancelTitle:LOC(@"No")];
        alertView.title = LOC(@"Warning");
        alertView.subtitle = LOC(@"ResetMessage");
        [alertView show];
        return YES;
    }];

    YTSettingsSectionItem *version = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Version")
        accessibilityIdentifier:@"YTLiteSectionItem"
        detailTextBlock:^NSString *() {
            return @(OS_STRINGIFY(TWEAK_VERSION));
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[ps, miro, tonymillion, dayanch96, stalker, clement, balackburn, decibelios, skeids, hiepvk, space, createSwitchItem(@"Advanced", @"advancedMode", &kAdvancedMode, selfObject), cache, reset];

        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"About") pickerSectionTitle:LOC(@"Credits") rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
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
        UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[YTLiteBundle() pathForResource:iconName ofType:@"png"]]];
        iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        iconImageView.clipsToBounds = YES;
        iconImageView.frame = imageView.bounds;

        [imageView addSubview:iconImageView];
        [imageView.layer renderInContext:rendererContext.CGContext];
    }];

    return image;
}
%end
