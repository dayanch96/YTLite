//
//  YTHFSSettings.x
//
//  Created by Joshua Seltzer on 12/11/22.
//
//

#import "YTHFSHeaders.h"
#import "YTHFSPrefsManager.h"

@interface YTSettingsSectionItemManager (YTHFS)

// create a new method that will be used to add the tweak's settings
- (void)YTHFSUpdateHoldForSpeedSectionWithEntry:(id)entry;

@end

// define the section number that is used to indicate the tweak's settings
#define kYTHFSHoldForSpeedSection      2168

%hook YTAppSettingsPresentationData

// set the order of the settings and insert our custom settings for the tweak
+ (NSArray *)settingsCategoryOrder
{
    NSArray *order = %orig;
    NSMutableArray *mutableOrder = [order mutableCopy];
    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound) {
        [mutableOrder insertObject:@(kYTHFSHoldForSpeedSection) atIndex:insertIndex + 1];
    }
    return [mutableOrder copy];
}

%end

%hook YTSettingsSectionItemManager

// override to add our custom entries for the hold for speed section in the settings
- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry
{
    if (category == kYTHFSHoldForSpeedSection) {
        [self YTHFSUpdateHoldForSpeedSectionWithEntry:entry];
        return;
    }
    %orig;
}

// logic which creates the section items for the tweak's preferences
%new
- (void)YTHFSUpdateHoldForSpeedSectionWithEntry:(id)entry {
    NSMutableArray *mainSectionItems = [NSMutableArray array];
    Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);
    YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];

    // create a settings section to enable or disable the hold gesture
    YTSettingsSectionItem *holdGestureSection = [YTSettingsSectionItemClass switchItemWithTitle:[YTHFSPrefsManager localizedStringForKey:@"HOLD_GESTURE" withDefaultValue:@"Hold gesture"]
        titleDescription:[YTHFSPrefsManager localizedStringForKey:@"HOLD_GESTURE_DESC" withDefaultValue:@"Tap and hold anywhere in the video player to toggle the playback speed between \"Normal\" (i.e. 1.0x) and the selected toggle speed.\n\nPlease be aware that by enabling this feature, the stock tap and hold gesture will be disabled."]
        accessibilityIdentifier:nil
        switchOn:[YTHFSPrefsManager holdGestureEnabled]
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [YTHFSPrefsManager setHoldGestureEnabled:enabled];
            return YES;
        }
        settingItemId:0];
    [mainSectionItems addObject:holdGestureSection];

    // create a settings section to automatically apply the selected speed
    YTSettingsSectionItem *autoApplySpeedSection = [YTSettingsSectionItemClass switchItemWithTitle:[YTHFSPrefsManager localizedStringForKey:@"AUTO_APPLY_SPEED" withDefaultValue:@"Automatically apply speed"]
        titleDescription:[YTHFSPrefsManager localizedStringForKey:@"AUTO_APPLY_SPEED_DESC" withDefaultValue:@"When enabled, the selected playback speed will automatically be applied when a new video player is launched."]
        accessibilityIdentifier:nil
        switchOn:[YTHFSPrefsManager autoApplyRateEnabled]
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [YTHFSPrefsManager setAutoApplyRateEnabled:enabled];
            return YES;
        }
        settingItemId:1];
    [mainSectionItems addObject:autoApplySpeedSection];

    // create a settings section that allows the selection of the playback rate
    NSString *playbackRateTitle = [YTHFSPrefsManager localizedStringForKey:@"TOGGLE_SPEED" withDefaultValue:@"Toggle speed"];
    YTSettingsSectionItem *toggleRateSection = [YTSettingsSectionItemClass itemWithTitle:playbackRateTitle
        titleDescription:[YTHFSPrefsManager localizedStringForKey:@"TOGGLE_SPEED_DESC" withDefaultValue:@"The speed that the video player will toggle between when the hold gesture is invoked."]
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            return [YTHFSPrefsManager playbackRateStringForValue:[YTHFSPrefsManager togglePlaybackRate]];
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            // create a new section item for each toggle rate option that the user can select
            NSMutableArray *playbackRateSectionRows = [NSMutableArray array];
            for (NSInteger currentRow = kYTHFSPlaybackRateOption025; currentRow <= kYTHFSPlaybackRateOption500; ++currentRow) {
                CGFloat playbackRateForRow = [YTHFSPrefsManager playbackRateValueForOption:currentRow];
                YTSettingsSectionItem *rateSection = [YTSettingsSectionItemClass checkmarkItemWithTitle:[YTHFSPrefsManager playbackRateStringForValue:playbackRateForRow]
                    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                        [YTHFSPrefsManager setTogglePlaybackRate:playbackRateForRow];
                        [settingsViewController reloadData];
                        return YES;
                    }];
                [playbackRateSectionRows addObject:rateSection];
            }
            YTSettingsPickerViewController *playbackRatePicker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:playbackRateTitle
                pickerSectionTitle:[playbackRateTitle uppercaseString]
                rows:playbackRateSectionRows
                selectedItemIndex:[YTHFSPrefsManager playbackRateOptionForValue:[YTHFSPrefsManager togglePlaybackRate]]
                parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:playbackRatePicker];
            return YES;
        }];
    [mainSectionItems addObject:toggleRateSection];

    // create a settings section that allows the selection of the hold duration
    NSString *holdDurationTitle = [YTHFSPrefsManager localizedStringForKey:@"HOLD_DURATION" withDefaultValue:@"Hold duration"];
    YTSettingsSectionItem *holdDurationSection = [YTSettingsSectionItemClass itemWithTitle:holdDurationTitle
        titleDescription:[YTHFSPrefsManager localizedStringForKey:@"HOLD_DURATION_DESC" withDefaultValue:@"The amount of time (in seconds) that is required for the hold gesture to toggle the speed of the video player."]
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            return [YTHFSPrefsManager holdDurationStringForValue:[YTHFSPrefsManager holdDuration]];
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            // create a new section item for each hold duration option that the user can select
            NSMutableArray *holdDurationSectionRows = [NSMutableArray array];
            for (NSInteger currentRow = kYTHFSHoldDurationOption025; currentRow <= kYTHFSHoldDurationOption200; ++currentRow) {
                CGFloat holdDurationForRow = [YTHFSPrefsManager holdDurationValueForOption:currentRow];
                YTSettingsSectionItem *holdDurationSection = [YTSettingsSectionItemClass checkmarkItemWithTitle:[YTHFSPrefsManager holdDurationStringForValue:holdDurationForRow]
                    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                        [YTHFSPrefsManager setHoldDuration:holdDurationForRow];
                        [settingsViewController reloadData];
                        return YES;
                    }];
                [holdDurationSectionRows addObject:holdDurationSection];
            }
            YTSettingsPickerViewController *holdDurationPicker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:holdDurationTitle
                pickerSectionTitle:[holdDurationTitle uppercaseString]
                rows:holdDurationSectionRows
                selectedItemIndex:[YTHFSPrefsManager holdDurationOptionForValue:[YTHFSPrefsManager holdDuration]]
                parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:holdDurationPicker];
            return YES;
        }];
    [mainSectionItems addObject:holdDurationSection];

    // create a settings section to completely disable the stock tap and hold gestures
    YTSettingsSectionItem *disableStockGesturesSection = [YTSettingsSectionItemClass switchItemWithTitle:[YTHFSPrefsManager localizedStringForKey:@"DISABLE_STOCK_GESTURES" withDefaultValue:@"Disable stock gestures"]
        titleDescription:[YTHFSPrefsManager localizedStringForKey:@"DISABLE_STOCK_GESTURES_DESC" withDefaultValue:@"Disable the stock tap and hold gestures in the video player.\n\nPlease be aware that if the hold gesture is enabled, the stock gestures will automatically be disabled."]
        accessibilityIdentifier:nil
        switchOn:[YTHFSPrefsManager disableStockGesturesEnabled]
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [YTHFSPrefsManager setDisableStockGesturesEnabled:enabled];
            return YES;
        }
        settingItemId:4];
    [mainSectionItems addObject:disableStockGesturesSection];

    // if available, add a settings section to enable or disable haptic feedback
    if ([YTHFSPrefsManager supportsHapticFeedback]) {
        YTSettingsSectionItem *hapticFeedbackSection = [YTSettingsSectionItemClass switchItemWithTitle:[YTHFSPrefsManager localizedStringForKey:@"HAPTIC_FEEDBACK" withDefaultValue:@"Haptic feedback"]
            titleDescription:[YTHFSPrefsManager localizedStringForKey:@"HAPTIC_FEEDBACK_DESC" withDefaultValue:@"Use haptic feedback to indicate that the speed of the video player was toggled."]
            accessibilityIdentifier:nil
            switchOn:[YTHFSPrefsManager hapticFeedbackEnabled]
            switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                [YTHFSPrefsManager setHapticFeedbackEnabled:enabled];
                return YES;
            }
            settingItemId:5];
        [mainSectionItems addObject:hapticFeedbackSection];
    }

    // add all of our settings item to the main settings list
    if ([settingsViewController respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)]) {
        YTIIcon *icon = [%c(YTIIcon) new];
        icon.iconType = 530; // TUNE
        [settingsViewController setSectionItems:mainSectionItems
                                    forCategory:kYTHFSHoldForSpeedSection
                                          title:[YTHFSPrefsManager localizedStringForKey:@"HOLD_FOR_SPEED" withDefaultValue:@"Hold for speed"]
                                           icon:icon
                               titleDescription:nil
                                   headerHidden:NO];
    } else {
        [settingsViewController setSectionItems:mainSectionItems
                                    forCategory:kYTHFSHoldForSpeedSection
                                          title:[YTHFSPrefsManager localizedStringForKey:@"HOLD_FOR_SPEED" withDefaultValue:@"Hold for speed"]
                               titleDescription:nil
                                   headerHidden:NO];
    }
}

%end
