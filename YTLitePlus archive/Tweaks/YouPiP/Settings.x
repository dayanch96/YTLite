#import <version.h>
#import "Header.h"
#import <YouTubeHeader/YTAppSettingsSectionItemActionController.h>
#import <YouTubeHeader/YTHotConfig.h>
#import <YouTubeHeader/YTSettingsGroupData.h>
#import <YouTubeHeader/YTSettingsSectionItem.h>
#import <YouTubeHeader/YTSettingsSectionItemManager.h>
#import <YouTubeHeader/YTSettingsViewController.h>

#define LOC(x) [tweakBundle localizedStringForKey:x value:nil table:nil]

static const NSInteger YouPiPSection = 200;

@interface YTSettingsSectionItemManager (YouPiP)
- (void)updateYouPiPSectionWithEntry:(id)entry;
@end

extern BOOL TweakEnabled();
extern BOOL UsePiPButton();
extern BOOL UseTabBarPiPButton();
extern BOOL UseAllPiPMethod();
extern BOOL NoMiniPlayerPiP();
extern BOOL LegacyPiP();
extern BOOL NonBackgroundable();

extern NSBundle *YouPiPBundle();

%hook YTAppSettingsPresentationData

+ (NSArray <NSNumber *> *)settingsCategoryOrder {
    NSArray <NSNumber *> *order = %orig;
    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound) {
        NSMutableArray <NSNumber *> *mutableOrder = order.mutableCopy;
        [mutableOrder insertObject:@(YouPiPSection) atIndex:insertIndex + 1];
        order = mutableOrder.copy;
    }
    return order;
}

%end

%hook YTSettingsGroupData

- (NSArray <NSNumber *> *)orderedCategories {
    if (self.type != 1 || class_getClassMethod(objc_getClass("YTSettingsGroupData"), @selector(tweaks)))
        return %orig;
    NSMutableArray *mutableCategories = %orig.mutableCopy;
    [mutableCategories insertObject:@(YouPiPSection) atIndex:0];
    return mutableCategories.copy;
}

%end

%hook YTSettingsSectionItemManager

%new(v@:@)
- (void)updateYouPiPSectionWithEntry:(id)entry {
    YTSettingsViewController *delegate = [self valueForKey:@"_dataDelegate"];
    NSMutableArray *sectionItems = [NSMutableArray array];
    NSBundle *tweakBundle = YouPiPBundle();
    YTSettingsSectionItem *enabled = [%c(YTSettingsSectionItem) switchItemWithTitle:LOC(@"ENABLED")
        titleDescription:LOC(@"ENABLED_DESC")
        accessibilityIdentifier:nil
        switchOn:TweakEnabled()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:EnabledKey];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:enabled];
    YTSettingsSectionItem *activationMethod = [%c(YTSettingsSectionItem) switchItemWithTitle:LOC(@"USE_PIP_BUTTON")
        titleDescription:LOC(@"USE_PIP_BUTTON_DESC")
        accessibilityIdentifier:nil
        switchOn:UsePiPButton()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:PiPActivationMethodKey];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:activationMethod];
    YTSettingsSectionItem *activationMethod2 = [%c(YTSettingsSectionItem) switchItemWithTitle:LOC(@"USE_TAB_BAR_PIP_BUTTON")
        titleDescription:LOC(@"USE_TAB_BAR_PIP_BUTTON_DESC")
        accessibilityIdentifier:nil
        switchOn:UseTabBarPiPButton()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:PiPActivationMethod2Key];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:activationMethod2];
    YTSettingsSectionItem *allActivationMethod = [%c(YTSettingsSectionItem) switchItemWithTitle:LOC(@"USE_ALL_PIP")
        titleDescription:LOC(@"USE_ALL_PIP_DESC")
        accessibilityIdentifier:nil
        switchOn:UseAllPiPMethod()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:PiPAllActivationMethodKey];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:allActivationMethod];
    YTSettingsSectionItem *miniPlayer = [%c(YTSettingsSectionItem) switchItemWithTitle:LOC(@"DISABLE_PIP_MINI_PLAYER")
        titleDescription:LOC(@"DISABLE_PIP_MINI_PLAYER_DESC")
        accessibilityIdentifier:nil
        switchOn:NoMiniPlayerPiP()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:NoMiniPlayerPiPKey];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:miniPlayer];
    if (IS_IOS_OR_NEWER(iOS_14_0)) {
        YTSettingsSectionItem *legacyPiP = [%c(YTSettingsSectionItem) switchItemWithTitle:LOC(@"LEGACY_PIP")
            titleDescription:LOC(@"LEGACY_PIP_DESC")
            accessibilityIdentifier:nil
            switchOn:LegacyPiP()
            switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:CompatibilityModeKey];
                return YES;
            }
            settingItemId:0];
        [sectionItems addObject:legacyPiP];
    }
    YTAppSettingsSectionItemActionController *sectionItemActionController = [delegate valueForKey:@"_sectionItemActionController"];
    YTSettingsSectionItemManager *sectionItemManager = [sectionItemActionController valueForKey:@"_sectionItemManager"];
    YTHotConfig *hotConfig = [sectionItemManager valueForKey:@"_hotConfig"];
    YTIIosMediaHotConfig *iosMediaHotConfig = hotConfig.hotConfigGroup.mediaHotConfig.iosMediaHotConfig;
    if ([iosMediaHotConfig respondsToSelector:@selector(setEnablePipForNonBackgroundableContent:)]) {
        YTSettingsSectionItem *nonBackgroundable = [%c(YTSettingsSectionItem) switchItemWithTitle:LOC(@"NON_BACKGROUNDABLE_PIP")
            titleDescription:LOC(@"NON_BACKGROUNDABLE_PIP_DESC")
            accessibilityIdentifier:nil
            switchOn:NonBackgroundable()
            switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:NonBackgroundableKey];
                return YES;
            }
            settingItemId:0];
        [sectionItems addObject:nonBackgroundable];
    }
    if ([delegate respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)]) {
        YTIIcon *icon = [%c(YTIIcon) new];
        icon.iconType = YT_PICTURE_IN_PICTURE;
        [delegate setSectionItems:sectionItems forCategory:YouPiPSection title:LOC(@"SETTINGS_TITLE") icon:icon titleDescription:nil headerHidden:NO];
    } else
        [delegate setSectionItems:sectionItems forCategory:YouPiPSection title:LOC(@"SETTINGS_TITLE") titleDescription:nil headerHidden:NO];
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == YouPiPSection) {
        [self updateYouPiPSectionWithEntry:entry];
        return;
    }
    %orig;
}

%end
