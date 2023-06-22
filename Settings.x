#import "YTLite.h"

@interface YTSettingsSectionItemManager (YTLite)
- (void)updateYTLiteSectionWithEntry:(id)entry;
@end

static const NSInteger YTLiteSection = 789;

static void resetYTLiteSettings() {
    NSString *prefsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"YTLite.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:prefsPath error:nil];
}

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

%new
- (void)updateIntegerPrefsForKey:(NSString *)key intValue:(NSInteger)intValue {
    NSString *prefsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"YTLite.plist"];
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:prefsPath];

    if (!prefs) prefs = [NSMutableDictionary dictionary];

    [prefs setObject:@(intValue) forKey:key];
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

    YTSettingsSectionItem *space = [%c(YTSettingsSectionItem) itemWithTitle:nil accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) { return YES; }];

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

        if (kAdvancedMode) {
            YTSettingsSectionItem *addStickyNavbar = createSwitchItem(LOC(@"StickyNavbar"), LOC(@"StickyNavbarDesc"), @"stickyNavbar", &kStickyNavbar, selfObject);
            rows = [rows arrayByAddingObject:addStickyNavbar];

            YTSettingsSectionItem *addNoSubbar = createSwitchItem(LOC(@"NoSubbar"), LOC(@"NoSubbarDesc"), @"noSubbar", &kNoSubbar, selfObject);
            rows = [rows arrayByAddingObject:addNoSubbar];

            YTSettingsSectionItem *addNoYTLogo = createSwitchItem(LOC(@"NoYTLogo"), LOC(@"NoYTLogoDesc"), @"noYTLogo", &kNoYTLogo, selfObject);
            rows = [rows arrayByAddingObject:addNoYTLogo];
        }

        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"Navbar") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:navbar];

    if (kAdvancedMode) {
        YTSettingsSectionItem *overlay = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Overlay")
            accessibilityIdentifier:nil
            detailTextBlock:^NSString *() {
                return @"‣";
            }
            selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                NSArray <YTSettingsSectionItem *> *rows = @[
                createSwitchItem(LOC(@"HideAutoplay"), LOC(@"HideAutoplayDesc"), @"hideAutoplay", &kHideAutoplay, selfObject),
                createSwitchItem(LOC(@"HideSubs"), LOC(@"HideSubsDesc"), @"hideSubs", &kHideSubs, selfObject),
                createSwitchItem(LOC(@"NoHUDMsgs"), LOC(@"NoHUDMsgsDesc"), @"noHUDMsgs", &kNoHUDMsgs, selfObject),
                createSwitchItem(LOC(@"HidePrevNext"), LOC(@"HidePrevNextDesc"), @"hidePrevNext", &kHidePrevNext, selfObject),
                createSwitchItem(LOC(@"ReplacePrevNext"), LOC(@"ReplacePrevNextDesc"), @"replacePrevNext", &kReplacePrevNext, selfObject),
                createSwitchItem(LOC(@"NoDarkBg"), LOC(@"NoDarkBgDesc"), @"noDarkBg", &kNoDarkBg, selfObject),
                createSwitchItem(LOC(@"NoEndScreenCards"), LOC(@"NoEndScreenCardsDesc"), @"noEndScreenCards", &kEndScreenCards, selfObject),
                createSwitchItem(LOC(@"NoFullscreenActions"), LOC(@"NoFullscreenActionsDesc"), @"noFullscreenActions", &kNoFullscreenActions, selfObject),
                createSwitchItem(LOC(@"NoRelatedVids"), LOC(@"NoRelatedVidsDesc"), @"noRelatedVids", &kNoRelatedVids, selfObject),
                createSwitchItem(LOC(@"NoPromotionCards"), LOC(@"NoPromotionCardsDesc"), @"noPromotionCards", &kNoPromotionCards, selfObject),
                createSwitchItem(LOC(@"NoWatermarks"), LOC(@"NoWatermarksDesc"), @"noWatermarks", &kNoWatermarks, selfObject)
            ];

            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"Overlay") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];
        [sectionItems addObject:overlay];

        YTSettingsSectionItem *player = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Player")
            accessibilityIdentifier:nil
            detailTextBlock:^NSString *() {
                return @"‣";
            }
            selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                NSArray <YTSettingsSectionItem *> *rows = @[
                createSwitchItem(LOC(@"Miniplayer"), LOC(@"MiniplayerDesc"), @"miniplayer", &kMiniplayer, selfObject),
                createSwitchItem(LOC(@"DisableAutoplay"), LOC(@"DisableAutoplayDesc"), @"disableAutoplay", &kDisableAutoplay, selfObject),
                createSwitchItem(LOC(@"NoContentWarning"), LOC(@"NoContentWarningDesc"), @"noContentWarning", &kNoContentWarning, selfObject),
                createSwitchItem(LOC(@"ClassicQuality"), LOC(@"ClassicQualityDesc"), @"classicQuality", &kClassicQuality, selfObject),
                createSwitchItem(LOC(@"DontSnap2Chapter"), LOC(@"DontSnap2ChapterDesc"), @"dontSnapToChapter", &kDontSnapToChapter, selfObject),
                createSwitchItem(LOC(@"RedProgressBar"), LOC(@"RedProgressBarDesc"), @"redProgressBar", &kRedProgressBar, selfObject),
                createSwitchItem(LOC(@"NoHints"), LOC(@"NoHintsDesc"), @"noHints", &kNoHints, selfObject),
                createSwitchItem(LOC(@"NoFreeZoom"), LOC(@"NoFreeZoomDesc"), @"noFreeZoom", &kNoFreeZoom, selfObject),
                createSwitchItem(LOC(@"ExitFullscreen"), LOC(@"ExitFullscreenDesc"), @"exitFullscreen", &kExitFullscreen, selfObject),
                createSwitchItem(LOC(@"NoDoubleTap2Seek"), LOC(@"NoDoubleTap2SeekDesc"), @"noDoubleTapToSeek", &kNoDoubleTapToSeek, selfObject)
            ];

            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"Player") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];
        [sectionItems addObject:player];

        YTSettingsSectionItem *shorts = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Shorts")
            accessibilityIdentifier:nil
            detailTextBlock:^NSString *() {
                return @"‣";
            }
            selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                NSArray <YTSettingsSectionItem *> *rows = @[
                createSwitchItem(LOC(@"HideShorts"), LOC(@"HideShortsDesc"), @"hideShorts", &kHideShorts, selfObject),
                createSwitchItem(LOC(@"ShortsProgress"), LOC(@"ShortsProgressDesc"), @"shortsProgress", &kShortsProgress, selfObject),
                createSwitchItem(LOC(@"ResumeShorts"), LOC(@"ResumeShortsDesc"), @"resumeShorts", &kResumeShorts, selfObject),
                createSwitchItem(LOC(@"HideShortsLogo"), LOC(@"HideShortsLogoDesc"), @"hideShortsLogo", &kHideShortsLogo, selfObject),
                createSwitchItem(LOC(@"HideShortsSearch"), LOC(@"HideShortsSearchDesc"), @"hideShortsSearch", &kHideShortsSearch, selfObject),
                createSwitchItem(LOC(@"HideShortsCamera"), LOC(@"HideShortsCameraDesc"), @"hideShortsCamera", &kHideShortsCamera, selfObject),
                createSwitchItem(LOC(@"HideShortsMore"), LOC(@"HideShortsMoreDesc"), @"hideShortsMore", &kHideShortsMore, selfObject),
                createSwitchItem(LOC(@"HideShortsSubscriptions"), LOC(@"HideShortsSubscriptionsDesc"), @"hideShortsSubscriptions", &kHideShortsSubscriptions, selfObject),
                createSwitchItem(LOC(@"HideShortsLike"), LOC(@"HideShortsLikeDesc"), @"hideShortsLike", &kHideShortsLike, selfObject),
                createSwitchItem(LOC(@"HideShortsDislike"), LOC(@"HideShortsDislikeDesc"), @"hideShortsDislike", &kHideShortsDislike, selfObject),
                createSwitchItem(LOC(@"HideShortsComments"), LOC(@"HideShortsCommentsDesc"), @"hideShortsComments", &kHideShortsComments, selfObject),
                createSwitchItem(LOC(@"HideShortsRemix"), LOC(@"HideShortsRemixDesc"), @"hideShortsRemix", &kHideShortsRemix, selfObject),
                createSwitchItem(LOC(@"HideShortsShare"), LOC(@"HideShortsShareDesc"), @"hideShortsShare", &kHideShortsShare, selfObject),
                createSwitchItem(LOC(@"HideShortsAvatars"), LOC(@"HideShortsAvatarsDesc"), @"hideShortsAvatars", &kHideShortsAvatars, selfObject),
                createSwitchItem(LOC(@"HideShortsThanks"), LOC(@"HideShortsThanksDesc"), @"hideShortsThanks", &kHideShortsThanks, selfObject),
                createSwitchItem(LOC(@"HideShortsChannelName"), LOC(@"HideShortsChannelNameDesc"), @"hideShortsChannelName", &kHideShortsChannelName, selfObject),
                createSwitchItem(LOC(@"HideShortsDescription"), LOC(@"HideShortsDescriptionDesc"), @"hideShortsDescription", &kHideShortsDescription, selfObject),
                createSwitchItem(LOC(@"HideShortsAudioTrack"), LOC(@"HideShortsAudioTrackDesc"), @"hideShortsAudioTrack", &kHideShortsAudioTrack, selfObject)
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"Shorts") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];
        [sectionItems addObject:shorts];
    }

    YTSettingsSectionItem *tabbar = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Tabbar")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            return @"‣";
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
            createSwitchItem(LOC(@"RemoveLabels"), LOC(@"RemoveLabelsDesc"), @"removeLabels", &kRemoveLabels, selfObject),
            createSwitchItem(LOC(@"ReExplore"), LOC(@"ReExploreDesc"), @"reExplore", &kReExplore, selfObject),
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

    if (kAdvancedMode) {
        [sectionItems addObject:space];

        YTSettingsSectionItem *startup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Startup")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (kPivotIndex) {
                case 1:
                    return LOC(@"ShortsTab");
                case 2:
                    return LOC(@"Subscriptions");
                case 3:
                    return LOC(@"Library");
                case 0:
                default:
                    return LOC(@"Home");
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"Home") titleDescription:nil selectBlock:^BOOL (YTSettingsCell *home, NSUInteger arg1) {
                    kPivotIndex = 0;
                    [settingsViewController reloadData];
                    [self updateIntegerPrefsForKey:@"pivotIndex" intValue:kPivotIndex];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"ShortsTab") titleDescription:nil selectBlock:^BOOL (YTSettingsCell *shorts, NSUInteger arg1) {
                    if (kRemoveShorts) {
                        YTAlertView *alertView = [%c(YTAlertView) infoDialog];
                        alertView.title = LOC(@"Warning");
                        alertView.subtitle = LOC(@"TabIsHidden");
                        [alertView show];
                        return NO;
                    } else {
                        kPivotIndex = 1;
                        [settingsViewController reloadData];
                        [self updateIntegerPrefsForKey:@"pivotIndex" intValue:kPivotIndex];
                        return YES;
                    }
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"Subscriptions") titleDescription:nil selectBlock:^BOOL (YTSettingsCell *subscriptions, NSUInteger arg1) {
                    if (kRemoveSubscriptions) {
                        YTAlertView *alertView = [%c(YTAlertView) infoDialog];
                        alertView.title = LOC(@"Warning");
                        alertView.subtitle = LOC(@"TabIsHidden");
                        [alertView show];
                        return NO;
                    } else {
                        kPivotIndex = 2;
                        [settingsViewController reloadData];
                        [self updateIntegerPrefsForKey:@"pivotIndex" intValue:kPivotIndex];
                        return YES;
                    }
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"Library") titleDescription:nil selectBlock:^BOOL (YTSettingsCell *library, NSUInteger arg1) {
                    if (kRemoveLibrary) {
                        YTAlertView *alertView = [%c(YTAlertView) infoDialog];
                        alertView.title = LOC(@"Warning");
                        alertView.subtitle = LOC(@"TabIsHidden");
                        [alertView show];
                        return NO;
                    } else {
                        kPivotIndex = 3;
                        [settingsViewController reloadData];
                        [self updateIntegerPrefsForKey:@"pivotIndex" intValue:kPivotIndex];
                        return YES;
                    }
                }]
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"Startup") pickerSectionTitle:nil rows:rows selectedItemIndex:kPivotIndex parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];
        [sectionItems addObject:startup];
    }
    
    [sectionItems addObject:space];

    YTSettingsSectionItem *ps = [%c(YTSettingsSectionItem) itemWithTitle:@"PoomSmart" titleDescription:@"YouTube-X, YTNoPremium, YTClassicVideoQuality, YTShortsProgress, YTReExplore, SkipContentWarning, YouTubeHeaders" accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/PoomSmart/"]];
    }];

    YTSettingsSectionItem *miro = [%c(YTSettingsSectionItem) itemWithTitle:@"MiRO92" titleDescription:@"YTNoShorts" accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/MiRO92/"]];
    }];

    YTSettingsSectionItem *dayanch96 = [%c(YTSettingsSectionItem) itemWithTitle:@"Dayanch96" titleDescription:LOC(@"Developer") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/Dayanch96/"]];
    }];

    YTSettingsSectionItem *reset = [%c(YTSettingsSectionItem) itemWithTitle:LOC(@"ResetSettings") titleDescription:nil accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        YTAlertView *alertView = [%c(YTAlertView) confirmationDialogWithAction:^{
            resetYTLiteSettings();
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
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            return @(OS_STRINGIFY(TWEAK_VERSION));
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[ps, miro, dayanch96, space, createSwitchItem(LOC(@"Advanced"), nil, @"advancedMode", &kAdvancedMode, selfObject), reset];

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