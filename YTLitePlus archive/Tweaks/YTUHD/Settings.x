#import <PSHeader/Misc.h>
#import <VideoToolbox/VideoToolbox.h>
#import <YouTubeHeader/YTHotConfig.h>
#import <YouTubeHeader/YTSettingsPickerViewController.h>
#import <YouTubeHeader/YTSettingsSectionItem.h>
#import <YouTubeHeader/YTSettingsSectionItemManager.h>
#import <YouTubeHeader/YTSettingsViewController.h>
#import "Header.h"

#define LOC(x) [tweakBundle localizedStringForKey:x value:nil table:nil]

BOOL UseVP9() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:UseVP9Key];
}

BOOL AllVP9() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:AllVP9Key];
}

int DecodeThreads() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:DecodeThreadsKey];
}

BOOL SkipLoopFilter() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:SkipLoopFilterKey];
}

BOOL LoopFilterOptimization() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:LoopFilterOptimizationKey];
}

BOOL RowThreading() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:RowThreadingKey];
}

NSBundle *YTUHDBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YTUHD" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:tweakBundlePath ?: PS_ROOT_PATH_NS(@"/Library/Application Support/YTUHD.bundle")];
    });
    return bundle;
}

%hook YTSettingsSectionItemManager

- (void)updateVideoQualitySectionWithEntry:(id)entry {
    YTHotConfig *hotConfig = [self valueForKey:@"_hotConfig"];
    YTIMediaQualitySettingsHotConfig *mediaQualitySettingsHotConfig = [hotConfig hotConfigGroup].mediaHotConfig.mediaQualitySettingsHotConfig;
    BOOL defaultValue = mediaQualitySettingsHotConfig.enablePersistentVideoQualitySettings;
    mediaQualitySettingsHotConfig.enablePersistentVideoQualitySettings = YES;
    %orig;
    mediaQualitySettingsHotConfig.enablePersistentVideoQualitySettings = defaultValue;
}

%end

static void addSectionItem(YTSettingsViewController *settingsViewController, NSMutableArray <YTSettingsSectionItem *> *sectionItems, NSInteger category) {
    if (category != 14) return;
    NSBundle *tweakBundle = YTUHDBundle();
    BOOL hasVP9 = VTIsHardwareDecodeSupported(kCMVideoCodecType_VP9);
    Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);

    // Use VP9
    YTSettingsSectionItem *vp9 = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"USE_VP9")
        titleDescription:[NSString stringWithFormat:@"%@\n\n%@: %d", LOC(@"USE_VP9_DESC"), LOC(@"HW_VP9_SUPPORT"), hasVP9]
        accessibilityIdentifier:nil
        switchOn:UseVP9()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:UseVP9Key];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:vp9];

    // All VP9
    YTSettingsSectionItem *allVP9 = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"ALL_VP9")
        titleDescription:LOC(@"ALL_VP9_DESC")
        accessibilityIdentifier:nil
        switchOn:AllVP9()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:AllVP9Key];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:allVP9];

    // Decode threads
    NSString *decodeThreadsTitle = LOC(@"DECODE_THREADS");
    YTSettingsSectionItem *decodeThreads = [YTSettingsSectionItemClass itemWithTitle:decodeThreadsTitle
        titleDescription:LOC(@"DECODE_THREADS_DESC")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            return [NSString stringWithFormat:@"%d", DecodeThreads()];
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSMutableArray <YTSettingsSectionItem *> *rows = [NSMutableArray array];
            for (int i = 1; i <= NSProcessInfo.processInfo.activeProcessorCount; ++i) {
                NSString *title = [NSString stringWithFormat:@"%d", i];
                NSString *titleDescription = i == 2 ? LOC(@"DECODE_THREADS_DEFAULT_VALUE") : nil;
                YTSettingsSectionItem *thread = [YTSettingsSectionItemClass checkmarkItemWithTitle:title titleDescription:titleDescription selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:i forKey:DecodeThreadsKey];
                    [settingsViewController reloadData];
                    return YES;
                }];
                [rows addObject:thread];
            }
            NSUInteger index = DecodeThreads() - 1;
            if (index >= NSProcessInfo.processInfo.activeProcessorCount) {
                index = 1;
                [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:DecodeThreadsKey];
            }
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:decodeThreadsTitle pickerSectionTitle:nil rows:rows selectedItemIndex:index parentResponder:[settingsViewController parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];
    [sectionItems addObject:decodeThreads];

    // Skip loop filter
    YTSettingsSectionItem *skipLoopFilter = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"SKIP_LOOP_FILTER")
        titleDescription:nil
        accessibilityIdentifier:nil
        switchOn:SkipLoopFilter()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:SkipLoopFilterKey];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:skipLoopFilter];

    // Loop filter optimization
    YTSettingsSectionItem *loopFilterOptimization = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"LOOP_FILTER_OPTIMIZATION")
        titleDescription:nil
        accessibilityIdentifier:nil
        switchOn:LoopFilterOptimization()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:LoopFilterOptimizationKey];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:loopFilterOptimization];

    // Row threading
    YTSettingsSectionItem *rowThreading = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"ROW_THREADING")
        titleDescription:nil
        accessibilityIdentifier:nil
        switchOn:RowThreading()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:RowThreadingKey];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:rowThreading];
}

%hook YTSettingsViewController

- (void)setSectionItems:(NSMutableArray <YTSettingsSectionItem *> *)sectionItems forCategory:(NSInteger)category title:(NSString *)title titleDescription:(NSString *)titleDescription headerHidden:(BOOL)headerHidden {
    addSectionItem(self, sectionItems, category);
    %orig;
}

- (void)setSectionItems:(NSMutableArray <YTSettingsSectionItem *> *)sectionItems forCategory:(NSInteger)category title:(NSString *)title icon:(YTIIcon *)icon titleDescription:(NSString *)titleDescription headerHidden:(BOOL)headerHidden {
    addSectionItem(self, sectionItems, category);
    %orig;
}

%end