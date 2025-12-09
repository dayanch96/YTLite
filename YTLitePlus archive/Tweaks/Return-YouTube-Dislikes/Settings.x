#import <PSHeader/Misc.h>
#import <YouTubeHeader/YTSettingsCell.h>
#import <YouTubeHeader/YTSettingsGroupData.h>
#import <YouTubeHeader/YTSettingsSectionItem.h>
#import <YouTubeHeader/YTSettingsSectionItemManager.h>
#import <YouTubeHeader/YTSettingsViewController.h>
#import "Settings.h"
#import "TweakSettings.h"

static const NSInteger RYDSection = 1080;

@interface YTSettingsSectionItemManager (RYD)
- (void)updateRYDSectionWithEntry:(id)entry;
@end

NSBundle *RYDBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"RYD" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:tweakBundlePath ?: PS_ROOT_PATH_NS(@"/Library/Application Support/RYD.bundle")];
    });
    return bundle;
}

%hook YTSettingsGroupData

- (NSArray <NSNumber *> *)orderedCategories {
    if (self.type != 1 || class_getClassMethod(objc_getClass("YTSettingsGroupData"), @selector(tweaks)))
        return %orig;
    NSMutableArray *mutableCategories = %orig.mutableCopy;
    [mutableCategories insertObject:@(RYDSection) atIndex:0];
    return mutableCategories.copy;
}

%end

%hook YTAppSettingsPresentationData

+ (NSArray <NSNumber *> *)settingsCategoryOrder {
    NSArray <NSNumber *> *order = %orig;
    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound) {
        NSMutableArray <NSNumber *> *mutableOrder = [order mutableCopy];
        [mutableOrder insertObject:@(RYDSection) atIndex:insertIndex + 1];
        order = mutableOrder.copy;
    }
    return order;
}

%end

%hook YTSettingsSectionItemManager

%new(v@:@)
- (void)updateRYDSectionWithEntry:(id)entry {
    NSMutableArray *sectionItems = [NSMutableArray array];
    NSBundle *tweakBundle = RYDBundle();
    YTSettingsViewController *delegate = [self valueForKey:@"_dataDelegate"];
    YTSettingsSectionItem *enabled = [%c(YTSettingsSectionItem) switchItemWithTitle:LOC(@"ENABLED")
        titleDescription:nil
        accessibilityIdentifier:nil
        switchOn:TweakEnabled()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:EnabledKey];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:enabled];
    YTSettingsSectionItem *vote = [%c(YTSettingsSectionItem) switchItemWithTitle:LOC(@"ENABLE_VOTE_SUBMIT")
        titleDescription:[NSString stringWithFormat:LOC(@"ENABLE_VOTE_SUBMIT_DESC"), @(API_URL)]
        accessibilityIdentifier:nil
        switchOn:VoteSubmissionEnabled()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            enableVoteSubmission(enabled);
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:vote];
    YTSettingsSectionItem *exactDislike = [%c(YTSettingsSectionItem) switchItemWithTitle:LOC(@"EXACT_DISLIKE_NUMBER")
        titleDescription:[NSString stringWithFormat:LOC(@"EXACT_DISLIKE_NUMBER_DESC"), @"12.3K", [NSNumberFormatter localizedStringFromNumber:@(12345) numberStyle:NSNumberFormatterDecimalStyle]]
        accessibilityIdentifier:nil
        switchOn:ExactDislikeNumber()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:ExactDislikeKey];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:exactDislike];
    YTSettingsSectionItem *exactLike = [%c(YTSettingsSectionItem) switchItemWithTitle:LOC(@"EXACT_LIKE_NUMBER")
        titleDescription:nil
        accessibilityIdentifier:nil
        switchOn:ExactLikeNumber()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:ExactLikeKey];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:exactLike];
    YTSettingsSectionItem *rawData = [%c(YTSettingsSectionItem) switchItemWithTitle:LOC(@"RAW_DATA")
        titleDescription:LOC(@"RAW_DATA_DESC")
        accessibilityIdentifier:nil
        switchOn:UseRawData()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:UseRawDataKey];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:rawData];
    NSString *settingsTitle = LOC(@"SETTINGS_TITLE");
    if ([delegate respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)]) {
        YTIIcon *icon = [%c(YTIIcon) new];
        icon.iconType = YT_DISLIKE;
        [delegate setSectionItems:sectionItems forCategory:RYDSection title:settingsTitle icon:icon titleDescription:nil headerHidden:NO];
    } else
        [delegate setSectionItems:sectionItems forCategory:RYDSection title:settingsTitle titleDescription:nil headerHidden:NO];
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == RYDSection) {
        [self updateRYDSectionWithEntry:entry];
        return;
    }
    %orig;
}

%end
